extends Resource
class_name PlayerStats
#------------------------------------------------------------------------------
#signal runStateChanged
#------------------------------------------------------------------------------
var score: int
var playerStatsRunState: bool = false
var maxStamina = 0.2
var stamina = maxStamina
var staminaDuration = stamina
var player = null
var playerLocation = null
var playHitSound = false

var enemy = null

var coinArea = null
