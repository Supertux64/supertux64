extends Spatial

func _ready():
	get_node("Player/Character/Camera").setInterpolate(Vector3(-100, 100, 100), 2)

func _process(delta):
	if (get_node("Player/Character/Camera").camState != get_node("Player/Character/Camera").state.interpolateTo):
		get_node("Player/Character").usable = true
