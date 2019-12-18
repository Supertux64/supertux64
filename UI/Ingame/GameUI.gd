extends Control

var coinCount = 0
var coinDisplay = 0
var step = 5
var positionX = 900
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	positionX = get_node("Coin").rect_position.x


func _process(delta):
	
	if coinCount != coinDisplay:
		step = 0
		if get_node("Coin").rect_position.x > 900:
			get_node("Coin").rect_position.x -= delta*200
		else:
			coinDisplay += 1
			get_node("Coin/Count").text = str(coinDisplay)
	else:
		step += delta
		if step > 3:
			if step < 4:
				get_node("Coin").rect_position.x = 900 + (step-3)*200
			else:
				get_node("Coin").rect_position.x = 1100

func giveCoin(count := 1):
	coinCount += count