extends Camera

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var parent = get_node("..")
var pos = Vector3(0, 0, -20)
var truepos = pos


var interpSpeed = 0.5

# Gets the movement of the mouse each render frame
onready var mousepos = get_viewport().get_mouse_position()
onready var mousedelta = get_viewport().get_mouse_position()

#USED FOR lockedDirection, fixedHeight, free
var dist = 20
var mindist = 10
var maxdist = 200

# USED FOR fixedHeight
var height = 10

# USED FOR lockedDirection (NORMALIZED : FOR DISTANCE SEE dist)
var distFromPlayer = Vector3(0, 0, -20).normalized()

# free = default; freeform camera
# fixedHeight : like free, but always at a given height
# lockedToPos : always stays at currect position, looks at player
# lockedDirection : always stays at same position difference from the player (good for 2d-like sequences)
# interpolateTo : interpolates to target location/look-at position

enum state{free,fixedHeight,lockedToPos,lockedDirection,interpolateTo}
var camState=state.lockedDirection
var canMoveCamWithMouse = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	mousedelta = get_viewport().get_mouse_position() - mousepos
	mousepos = get_viewport().get_mouse_position()
	
	var camDir = 1
	if GLOBAL.camReverseHorizontal:
		camDir = -1
		
	var camDir2 = 1
	if GLOBAL.camReverseVertical:
		camDir2 = -1
	
	if Input.is_action_pressed("right_mouse") && canMoveCamWithMouse:
		if camState == state.lockedDirection:
			distFromPlayer -= (get_global_transform().basis.z * -GLOBAL.anti_up()).rotated(GLOBAL.up, PI/2)*mousedelta.x*camDir/100
			distFromPlayer += GLOBAL.up*mousedelta.y/100*camDir2
			distFromPlayer = distFromPlayer.normalized()
		else:
			pos -= (get_global_transform().basis.z * -GLOBAL.anti_up()).rotated(GLOBAL.up, PI/2)*mousedelta.x*camDir/10
			pos += GLOBAL.up*mousedelta.y/10*camDir2
	
	if Input.is_action_just_released("ST_zoom_in"):
		dist /= 1.4
		dist = max(dist, mindist)
		
	if Input.is_action_just_released("ST_zoom_out"):
		dist *= 1.4
		dist = min(dist, maxdist)
	
	
	match camState:
		state.free:
			pos -= parent.translation
			pos = pos.normalized()*dist + parent.translation
		state.fixedHeight:
			pos -= parent.translation
			pos *= GLOBAL.anti_up()
			pos = pos.normalized()*dist + GLOBAL.up*height + parent.translation
		state.lockedDirection:
			pos = parent.translation + distFromPlayer.normalized() * dist
	
	# interpSpeed = 1 - (1 / pow(truepos.distance_to(pos), 2))
	
	
	# Manage underwater cam
	var waterY = get_node("../../../OceanCollection/Ocean").get_displace(Vector2(get_global_transform().origin.x, get_global_transform().origin.z)).y
	
	if !GLOBAL.camCanBeUnderwaterWithoutPlayer:
		if get_parent().isDiving():
			pos.y = min(pos.y, waterY - 2)
		else:
			pos.y = max(pos.y, waterY + 2)
			
	
	truepos = truepos * (1-interpSpeed) + pos * interpSpeed
	
	look_at_from_position(truepos, parent.translation, GLOBAL.up)
	
	# Manage underwater visual effects
	_getEnvironment().environment.fog_depth_enabled = waterY > get_global_transform().origin.y

func _getEnvironment():
	return get_node("../../../WorldEnvironment")
