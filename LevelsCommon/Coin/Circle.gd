extends Area

var state = 0
onready var coin = get_node('../Circle')

func _process(delta):
	coin.rotate_y(delta*5)
	
	if state == 0:
		var bodies = get_overlapping_bodies()
		for curBody in bodies:
			if curBody.get_parent().get_name() == "Player":
				state = 0.001
				get_tree().get_root().get_node('Level/GameUI').giveCoin()
				
	else:
		coin.rotate_y(delta*15*(2-state))
		coin.transform.origin.y += .4*(1-state)*(1-state)*(1-state)*(1-state)*(1-state)
		coin.scale_object_local(Vector3((1-delta)*(1-state/2), (1-delta)*(1-state/2), (1-delta)*(1-state/2)))
		state += delta
		if state > 1:
			get_parent().queue_free()
		
	
