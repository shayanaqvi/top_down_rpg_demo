extends KinematicBody2D
#------------------------------------------------------------------------------
export var max_speed = 50
export var speed = 50
export var cameraZoom = Vector2(0.8, 0.8)

export var cameraLimitBottom: int
export var cameraLimitLeft: int
export var cameraLimitTop: int
export var cameraLimitRight: int


onready var playerStats = preload("res://PlayerStats.tres")
onready var animationPlayer = $AnimationPlayer
onready var playerCamera = $Camera2D
onready var playerSprite = $Sprites/PlayerSprite
onready var staminaBar = $PlayerInterface/Stamina
onready var scoreLabel = $PlayerInterface/Panel/ScoreLabel
onready var tween = $Tween
onready var hitSound = $HitSound

var run_state = false
var buttonPressCount = 0
#------------------------------------------------------------------------------
signal runStateEnabled
#------------------------------------------------------------------------------
func _ready():
	staminaBar.max_value = playerStats.maxStamina
	staminaBar.value = playerStats.stamina
	
	playerCamera.limit_bottom = cameraLimitBottom
	playerCamera.limit_left = cameraLimitLeft
	playerCamera.limit_top = cameraLimitTop
	playerCamera.limit_right = cameraLimitRight
	
	playerStats.player = self

func _physics_process(delta):
	move_player()
	
	if playerStats.playerStatsRunState == false:
		playerSprite.scale = Vector2(1.0, 1.0)
		speed = max_speed
		playerCamera.drag_margin_left = 0.2
		playerCamera.drag_margin_right = 0.2
		playerCamera.drag_margin_top = 0.2
		playerCamera.drag_margin_bottom = 0.2
#		playerCamera.zoom = Vector2(0.85, 0.85)
		playerCamera.smoothing_speed = 5
	
	scoreLabel.text = "SCORE: " + str(playerStats.score)
	playerStats.playerLocation = global_position


func move_player():
	var input_dir = Vector2.ZERO
	var a
	
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
		animationPlayer.play("Walk")
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
		animationPlayer.play("Walk")
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
		animationPlayer.play("Walk")
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
		animationPlayer.play("Walk")
	if input_dir == Vector2(0, 0):
		animationPlayer.play("Idle")
	
	if Input.is_action_just_pressed("run"):
		emit_signal("runStateEnabled")
		playerStats.playerStatsRunState = true
		buttonPressCount += 1

	input_dir = input_dir.normalized()
	if input_dir.length() != 0:
		a = input_dir.angle() / (PI/4)
		a = wrapi(int(a), 0, 8)
	move_and_slide(input_dir * speed)

func _on_runStateEnabled():
	if playerStats.playerStatsRunState == true and buttonPressCount == 1:
		
		if playerStats.stamina == 0:
			playerStats.stamina = playerStats.maxStamina
		
		speed = 200
		playerSprite.scale = Vector2(0.9, 0.9)
		playerCamera.drag_margin_left = 0.3 
		playerCamera.drag_margin_right = 0.3
		playerCamera.drag_margin_top = 0.3
		playerCamera.drag_margin_bottom = 0.3
		tween.interpolate_property(playerCamera, "zoom", Vector2(0.85, 0.85), Vector2(0.95, 0.95), playerStats.staminaDuration, Tween.TRANS_QUART, Tween.EASE_OUT)
		tween.start()
#		playerCamera.zoom = Vector2(0.86, 0.86)
		playerCamera.smoothing_speed = 2

		playerStats.stamina -= playerStats.maxStamina
		
		tween.interpolate_property(staminaBar, "value", playerStats.maxStamina, 0, playerStats.staminaDuration, Tween.TRANS_QUART, Tween.EASE_OUT)
		tween.start()
		
		print("timer started")
		yield(get_tree().create_timer(playerStats.staminaDuration), "timeout")
		playerStats.playerStatsRunState = false
		print('timer ended')
		speed = max_speed
		
		tween.interpolate_property(staminaBar, "value", 0, playerStats.maxStamina, 1.5, Tween.TRANS_QUART, Tween.EASE_IN, 0.2)
		tween.start()
		
		tween.interpolate_property(playerCamera, "zoom", Vector2(0.95, 0.95), Vector2(0.85, 0.85), 0.8, Tween.TRANS_QUART, Tween.EASE_OUT, 0.5)
		tween.start()
		
		yield(get_tree().create_timer(1.5), "timeout")
		print('second timer ended')
		buttonPressCount = 0
