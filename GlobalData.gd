extends Node


###############
## GAME INFO ##
###############

# A.B.C-D
# A : Major build version (Milestones)
# B : Minor build version (production / releases / good for end users)
# C : Development versions (good for devs and enthousiasts who want to test the latest functionalities)
# D : Functionality - a number for every new functionality / functionality change
var GameVersion = "0.0.1-2"

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

# Well... The opposite of gravity... (Might be edited by some maps) MUST ALWAYS BE NORMALIZED
var up = Vector3(0, 1, 0).normalized()

#Calculates the 2D floor vector based on the value of "up"
func anti_up():
	return Vector3(1, 1, 1) - up.abs() # Hardcoded. Won't work if "up" isn't on one of the 6 axis

# The maximum floor angle from which the character can jump.
var max_floor_angle = deg2rad(30)
