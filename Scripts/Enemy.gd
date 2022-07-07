extends KinematicBody2D
#------------------------------------------------------------------------------
onready var animationPlayer = $AnimationPlayer
onready var playerStats = preload("res://PlayerStats.tres")
onready var hitSound = $HitSound
onready var transitionPlayer = $AnimationPlayer2
onready var colorrect = $CanvasLayer/ColorRect

export var next_scene: PackedScene

var targetVelocity = Vector2(rand_range(-32, 32), rand_range(-32, 32))
var speed: int = maxSpeed
var velocity = Vector2.ZERO
var acceleration = 300
var player = null
#------------------------------------------------------------------------------
const maxSpeed = 25
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
func _ready():
	targetVelocity = Vector2(rand_range(-32, 32), rand_range(-32, 32))
	speed = maxSpeed
	player = playerStats.player
	playerStats.enemy = self
	colorrect.visible = false

func _physics_process(delta):
	move_state(delta)


func move_state(delta):
	var a
	
	targetVelocity = targetVelocity.normalized()
	animationPlayer.play("Walk")
	if targetVelocity.length() != 0:
		a = targetVelocity.angle() / (PI/4)
		a = wrapi(int(a), 0, 8)
	move_and_slide(targetVelocity * speed)

func change_direction():
	speed = maxSpeed
	randomize()
	targetVelocity = Vector2(rand_range(-8, 8), rand_range(-8, 8))
#	pass

func _on_AIMovement_area_entered(area):
	change_direction()

func _on_AIMovement_body_entered(body):
	player = body
	if player != null:
		speed += 50
		targetVelocity = position.direction_to(player.position) * speed
		move_and_slide(targetVelocity)
		
	else: 
		targetVelocity = Vector2(rand_range(-32, 32), rand_range(-32, 32))
		speed = maxSpeed

func _on_AIMovement_body_exited(body):
	player = null
	speed = maxSpeed

func _on_AIMovement3_area_entered(area):
	change_direction()

func _on_AIMovement3_body_entered(body):
	if player == playerStats.player:
		hitSound.play()
		yield(get_tree().create_timer(0.25), "timeout")
		colorrect.visible = true
		transitionPlayer.play("Transition")
		yield(get_tree().create_timer(0.5), "timeout")
		get_tree().change_scene("res://Scenes/SkullEnemyCombat.tscn")
	else: 
		targetVelocity = Vector2(rand_range(-32, 32), rand_range(-32, 32))
		speed = maxSpeed

func _on_AIMovement3_body_exited(body):
	playerStats.playHitSound = false
	player = null
	speed = maxSpeed
