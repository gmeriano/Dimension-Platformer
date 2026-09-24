extends Node

const DIMENSION_OFFSET = 800

# we scale everything by 3x, and need to account for this in code sometimes for movement / rendering stuff
const ART_SCALAR = 3.0 

const MOVESPEED = 100.0 * ART_SCALAR

var IS_ONLINE_MULTIPLAYER = false
