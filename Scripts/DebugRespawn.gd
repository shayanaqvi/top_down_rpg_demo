extends Node2D
#------------------------------------------------------------------------------
onready var enemies = $Enemies
#------------------------------------------------------------------------------
func _ready():
	enemies.hide()
	yield(get_tree().create_timer(1), "timeout")
	enemies.show()

func _process(delta):
	if Input.is_action_pressed("debug_respawn"):
		get_tree().reload_current_scene()

func _on_Enemy_body_entered():
	pass
