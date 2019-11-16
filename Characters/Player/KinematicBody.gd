extends KinematicBody

var speed = 15
var gravity = 50
var jump_power = 20

var lookingat = Vector3(0,0,1)
var shouldRejump = false

var acceleration = Vector3(0,0,0)
var forward = Vector3(0,0,-1)
enum movementstate{normal,onlycamera,full}
var state=movementstate.normal
var backupMouse=Vector2(0,0)
var lastmouse = Vector2(0,0)

# FOR PLAYER ROTATION
var cur_angle = 0
var dest_angle = 0

# FOR UNDERWATER PLAYER ROTATION
var looking_at_underwater = Vector3(0, 1, 0)

# TO DIVE PROPERLY
var wasUnderwater = false
var divespeed = 0

func _physics_process(delta):
	
	#print(isDiving())
	#print(isSwimming())
	#print(get_node("Camera").get_global_transform().basis.z.y)
	#print(get_node("Camera").get_global_transform().basis.z.normalized().y == 0)
	#print(pow(get_node("Camera").get_global_transform().basis.z.normalized().y, 2) < .1)
	#print(get_node("Camera").get_global_transform().basis)
	
	if Input.is_action_just_pressed("ST_dive"):
		divespeed = -25
	
	#if isDiving() || (isSwimming() && ((get_node("Camera").get_global_transform().basis.z.normalized() * GLOBAL.up).y > 0.8 || pow((get_node("Camera").get_global_transform().basis.z.normalized() * GLOBAL.up).y, 2) < .1)):
	if isDiving() || (isSwimming() && divespeed < -0.1):
		forward = get_node("Camera").get_global_transform().basis.z.normalized() * -1
		
		#print("a")
		
		var dir = Vector3(0,0,0)
		if Input.is_action_pressed("ST_up"):
			dir+=forward
		if Input.is_action_pressed("ST_down"):
			dir-=forward
		if Input.is_action_pressed("ST_left"):
			dir+=(forward * GLOBAL.anti_up()).rotated(GLOBAL.up,deg2rad(90))
		if Input.is_action_pressed("ST_right"):
			dir-=(forward * GLOBAL.anti_up()).rotated(GLOBAL.up,deg2rad(90))
		
		move_and_slide(dir*speed + divespeed * GLOBAL.up, GLOBAL.up)
		divespeed /= 1.1
		
		# getPos()-GLOBAL.up
		# getPos() - get_node("Camera").get_global_transform().basis.y.normalized()*10
		
		# get_node("Camera").get_global_transform().basis.z
		
		#look_at(getPos() - get_node("Camera").get_global_transform().basis.y.normalized() * 10, get_node("Camera").get_global_transform().basis.z.normalized())
		#look_at(getPos() - get_node("Camera").get_global_transform().basis.y.normalized(), -forward)
		
		#look_at(getPos() - get_node("Camera").get_global_transform().basis.y.normalized(), -dir)
		
		looking_at_underwater = (looking_at_underwater*.8 + dir.normalized()*.2).normalized()
		
		look_at(getPos() - looking_at_underwater, GLOBAL.up)
		
	else:
		#print("b")
		#print((get_node("Camera").get_global_transform().basis.z.normalized()))
		
		divespeed = 0
		
		forward = get_node("Camera").get_global_transform().basis.z * -GLOBAL.anti_up()
		forward = forward.normalized()
		
		var dir = Vector3(0,0,0)
		if Input.is_action_pressed("ST_up"):
			dir+=forward
		if Input.is_action_pressed("ST_down"):
			dir-=forward
		if Input.is_action_pressed("ST_left"):
			dir+=forward.rotated(GLOBAL.up,deg2rad(90))
		if Input.is_action_pressed("ST_right"):
			dir-=forward.rotated(GLOBAL.up,deg2rad(90))
		
		if isSwimming():
			move_and_slide(dir*speed*.75 - GLOBAL.up*0.01, GLOBAL.up)
		else:
			move_and_slide(dir*speed - GLOBAL.up*0.01,GLOBAL.up)
		
		# move_and_slide(dir*speed - GLOBAL.up*0.01,GLOBAL.up)
		
		# Now let's manage the player rotation :))))))))
		lookingat += dir
		lookingat /=2
		lookingat = lookingat.normalized()
		
		look_at(getPos()-GLOBAL.up, -lookingat)
		
		# Now let's manage jumps :))))))))))))))))))))))
		if Input.is_action_just_pressed("ST_Jump") || shouldRejump:
			get_node("RayCast").force_raycast_update()
			if is_on_floor() || getPos().y <= 0 || (get_node("RayCast").get_collision_normal().angle_to(GLOBAL.up) < GLOBAL.max_floor_angle && self.test_move(transform, Vector3(0, -1, 0))):
				acceleration = GLOBAL.up * jump_power
				shouldRejump = false
			else:
				shouldRejump = true
		
		if !Input.is_action_pressed("ST_Jump"):
			shouldRejump = false
		
		# Now let's manage gravity :))))))))))))))))))))
		if is_on_floor() || isSwimming():
			if GLOBAL.up.normalized() != acceleration.normalized():
				acceleration = Vector3(0,0,0)
		else:
			acceleration -= GLOBAL.up*gravity*delta
		
		# Required to detect ceilings
		move_and_slide(Vector3(0, 0.02, 0),GLOBAL.up)
		if is_on_ceiling():
			if GLOBAL.up.normalized() == acceleration.normalized():
				acceleration *= -1
		
		# Cancel the last move we did :))))) (To prevent flying up)
		move_and_slide(Vector3(0, -0.2, 0),GLOBAL.up)
		
		move_and_slide(acceleration, GLOBAL.up)
		
		if isSwimming():
			var ocean = _getOceanNode()
			set_global_transform(Transform(get_global_transform().basis, ocean.get_displace(Vector2(getPos().x, getPos().z))))

func _input(event):
	# Mouse in viewport coordinates
	if event is InputEventMouseMotion:
		lastmouse=event.position

# Print the size of the viewport

func _ready():
	set_process_input(true)
	Input.warp_mouse_position(Vector2(500,500))
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func isSwimming():
	var ocean = _getOceanNode()
	var whereItWouldBe = ocean.get_displace(Vector2(getPos().x, getPos().z))
	#print("SWIM : " + str(getPos().y - whereItWouldBe.y))
	return getPos().y <= whereItWouldBe.y + .25 && getPos().y >= whereItWouldBe.y - .5
	
func isDiving():
	var ocean = _getOceanNode()
	var whereItWouldBe = ocean.get_displace(Vector2(getPos().x, getPos().z))
	#print("DIVE : " + str(getPos().y - whereItWouldBe.y))
	wasUnderwater = (wasUnderwater && getPos().y <= whereItWouldBe.y - .1) || getPos().y <= whereItWouldBe.y - .5
	return wasUnderwater

func getPos():
	return get_global_transform().origin

func _getOceanNode():
	return get_parent().get_parent().get_node("OceanCollection").get_node('Ocean');
