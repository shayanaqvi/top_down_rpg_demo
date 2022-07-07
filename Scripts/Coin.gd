extends Area2D
#------------------------------------------------------------------------------
onready var animationPlayer = $AnimationPlayer
onready var playerStats = preload("res://PlayerStats.tres")

export var score = 100
#------------------------------------------------------------------------------
#signal scoreUpdated(playerScore)
#------------------------------------------------------------------------------
func _ready():
	animationPlayer.play("CoinFloat")

func _on_body_entered(body):
	if body == playerStats.player:
		animationPlayer.play("Collected")
		playerStats.score += score
		yield(animationPlayer, "animation_finished")
		queue_free()
