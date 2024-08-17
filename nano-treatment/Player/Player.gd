extends CharacterBody2D

#region BASIC MOVEMENT VARAIABLES ---------------- #
@export_group("Basic Movement Variables")
var face_direction := 1
var x_dir := 1
var dashing = false
var wall_sliding_and_climbing := false
const number_of_dashes = 1
var dash_uses = number_of_dashes

@export var dash_speed: float = 900.0
@export var max_speed: float = 560
@export var acceleration: float = 2880
@export var turning_acceleration : float = 9600
@export var deceleration: float = 3200
#endregion --------------------------------------- #

#region GRAVITY ----- #
@export_group("Gravity")
@export var gravity_acceleration : float = 3840
@export var gravity_max : float = 1020
@export var climbing_gravity := 100
#endregion ---------- #

#region JUMP VARIABLES ------------------- #
@export_group("Jump Variables")
@export var jump_force : float = 1400
## Cut the velocity if let go of jump.
@export var jump_cut : float = 0.25
@export var jump_gravity_max : float = 500
## Once you hit a ceiling, the threshold will prevent you from slowly starting to descend / float.
@export var jump_hang_treshold : float = 2.0
## Multiplier used to reduce gravity at the peak of our jump (where velocity is lowest).
@export var jump_hang_gravity_mult : float = 0.1
@export var wall_jump_pushback = 1000;
#endregion ------------------------------- #

#region Timers ---------- #
@export_group("Timers")
## Used to reset jump coyote timer once in the floor.
@export var jump_coyote : float = 0.08
## Used to reset jump buffer timer once user starts pressing the jump button.
@export var jump_buffer : float = 0.1

var jump_coyote_timer : float = 0
var jump_buffer_timer : float = 0
var is_jumping := false

var time_in_wall: float = 0.0

@onready var dash_timer: Timer = $DashTimer
@onready var timer: Timer = $ClimbingTimer
#endregion -------------- #


# All iputs we want to keep track of
func get_input() -> Dictionary:
	return {
		"x": int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		"climb": Input.is_action_pressed("ui_up"),
		"dash": Input.is_action_just_pressed("dash") == true,
		"just_jump": Input.is_action_just_pressed("jump") == true,
		"jump": Input.is_action_pressed("jump") == true,
		"released_jump": Input.is_action_just_released("jump") == true
	}


func _physics_process(delta: float) -> void:
	x_movement(delta)
	jump_logic(delta)
	apply_gravity(delta)
	climbing(delta)
	dash()
	
	timers(delta)
	move_and_slide()


func x_movement(delta: float) -> void:
	x_dir = get_input()["x"]
	
	# Stop if we're not doing movement inputs.
	if x_dir == 0: 
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), deceleration * delta).x
		return
	
	# If we are doing movement inputs and above max speed, don't accelerate nor decelerate
	# Except if we are turning
	# (This keeps our momentum gained from outside or slopes)
	if abs(velocity.x) >= max_speed and sign(velocity.x) == x_dir:
		return
	
	# Are we turning?
	# Deciding between acceleration and turn_acceleration
	var accel_rate : float = acceleration if sign(velocity.x) == x_dir else turning_acceleration
	
	# Accelerate
	velocity.x += x_dir * accel_rate * delta
	
	set_direction(x_dir) # This is purely for visuals


func set_direction(hor_direction) -> void:
	# This is purely for visuals
	# Turning relies on the scale of the player
	# To animate, only scale the sprite
	if hor_direction == 0:
		return
	apply_scale(Vector2(hor_direction * face_direction, 1)) # flip
	face_direction = hor_direction # remember direction


func jump_logic(_delta: float) -> void:
	# Reset our jump requirements
	if is_on_floor():
		jump_coyote_timer = jump_coyote
		is_jumping = false
	if get_input()["just_jump"]:
		jump_buffer_timer = jump_buffer
		# Wall jumping
		if is_on_wall_only():
			velocity.y = -jump_force
			velocity.x = -x_dir * wall_jump_pushback
	
	# Jump if grounded, there is jump input, and we aren't jumping already
	if jump_coyote_timer > 0 and jump_buffer_timer > 0 and not is_jumping:
		is_jumping = true
		jump_coyote_timer = 0
		jump_buffer_timer = 0
		# If falling, account for that lost speed
		if velocity.y > 0:
			velocity.y -= velocity.y
		
		velocity.y = -jump_force
	
	# We're not actually interested in checking if the player is holding the jump button
#	if get_input()["jump"]:pass
	
	# Cut the velocity if let go of jump. This means our jumpheight is variable
	# This should only happen when moving upwards, as doing this while falling would lead to
	# The ability to studder our player mid falling
	if get_input()["released_jump"] and velocity.y < 0:
		velocity.y -= (jump_cut * velocity.y)
	
	# This way we won't start slowly descending / floating once hit a ceiling
	# The value added to the treshold is arbritary,
	# But it solves a problem where jumping into 
	if is_on_ceiling(): velocity.y = jump_hang_treshold + 100.0


func apply_gravity(delta: float) -> void:
	var applied_gravity : float = 0
	
	# No gravity if we are grounded
	if jump_coyote_timer > 0:
		pass
	
	# Normal gravity limit
	if velocity.y <= gravity_max:
		applied_gravity = gravity_acceleration * delta
	
	# If moving upwards while jumping, the limit is jump_gravity_max to achieve lower gravity
	if (is_jumping and velocity.y < 0) and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	# Lower the gravity at the peak of our jump (where velocity is the smallest)
	if is_jumping and abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
	
	velocity.y += applied_gravity


func climbing(delta:float) -> void:
	var climb = get_input()["climb"]
	wall_sliding_and_climbing = is_on_wall_only() and x_dir != 0
	
	if time_in_wall >= 3.0 or dash_uses == 0: wall_sliding_and_climbing = false
	
	if wall_sliding_and_climbing:
		var y_dir := -1.0 if climb else 1.0
		if dashing:
			velocity.y = -1.0 * dash_speed
		else:
			velocity.y += y_dir * climbing_gravity * delta
			velocity.y = min(velocity.y, y_dir * climbing_gravity)


func dash() -> void:
	if is_on_floor(): dash_uses = number_of_dashes
	
	if get_input()["dash"] and dash_uses > 0:
		dashing = true
		dash_timer.start()


func timers(delta: float) -> void:
	# Using timer nodes here would mean unnececary functions and node calls
	# This way everything is contained in just 1 script with no node requirements
	jump_coyote_timer -= delta
	jump_buffer_timer -= delta


func _on_Timer_timeout() -> void:
	if is_on_wall_only():
		time_in_wall += timer.wait_time
		%Label.text = str(time_in_wall)
		#print("Time in wall:", time_in_wall)
	else:
		#print("Exited wall. Total time:", time_in_wall)
		time_in_wall = 0.0
		%Label.text = str(time_in_wall)


func _on_dash_timer_timeout() -> void:
	dash_timer.stop()
	dashing = false
	dash_uses -= 1
