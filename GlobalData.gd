extends Node


##############
## SETTINGS ##
##############

# When right-clicking to rotate the camera, switches the left/right sides.
var camReverseHorizontal = true

# When right-clicking to rotate the camera, switches the up/down sides.
var camReverseVertical = false

# Allows camera to be underwater while player is not (and vice versa)
var camCanBeUnderwaterWithoutPlayer = false


######################
## WORLD PROPERTIES ##
######################

var GameVersion = "0.0.1"

# Well... The opposite of gravity... (Might be edited by some maps) MUST ALWAYS BE NORMALIZED
var up = Vector3(0, 1, 0).normalized()

#Calculates the 2D floor vector based on the value of "up"
func anti_up():
	return Vector3(1, 1, 1) - up.abs()

# The maximum floor angle.
var max_floor_angle = deg2rad(30)
