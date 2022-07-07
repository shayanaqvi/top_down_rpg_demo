extends Node
#------------------------------------------------------------------------------
export var maxPlayerHealth: int = 25
var playerHealth = maxPlayerHealth

export var maxPlayerActionPoints: int = 2
var playerActionPoints = maxPlayerActionPoints

export var maxPlayerManaPoints: int = 1
var playerManaPoints = maxPlayerManaPoints

export var maxEnemyHealth: int = 15
var enemyHealth = maxEnemyHealth

export var maxEnemyActionPoints = 1
var enemyActionPoints = maxEnemyActionPoints

export var enemyName = ""

export var previousScene: PackedScene

var enemyTurn = false

onready var playerHealthLabel = $UserCombatInterface/PlayerStatsPanel/HBoxContainer/HealthVBox/HealthLabel
onready var playerHealthValue = $UserCombatInterface/PlayerStatsPanel/HBoxContainer/HealthVBox/HealthValue

onready var playerActionPointsLabel = $UserCombatInterface/PlayerStatsPanel/HBoxContainer/ActionPointsVBox/ActionPointsLabel
onready var playerActionPointsValue = $UserCombatInterface/PlayerStatsPanel/HBoxContainer/ActionPointsVBox/ActionPointsValue

onready var playerManaPointsLabel = $UserCombatInterface/PlayerStatsPanel/HBoxContainer/ManaPointsVBox/ManaPointsLabel
onready var playerManaPointsValue = $UserCombatInterface/PlayerStatsPanel/HBoxContainer/ManaPointsVBox/ManaPointsValue

onready var swordButton = $UserCombatInterface/Sword
onready var magicButton = $UserCombatInterface/Magic
onready var healButton = $UserCombatInterface/Heal
onready var defendButton = $UserCombatInterface/Defend
onready var spareButton1 = $UserCombatInterface/Button3
onready var spareButton2 = $UserCombatInterface/Button4

onready var enemyHealthLabel = $UserCombatInterface/EnemyStatsPanel/HBoxContainer/HealthVBox/HealthLabel
onready var enemyHealthValue = $UserCombatInterface/EnemyStatsPanel/HBoxContainer/HealthVBox/HealthValue

onready var playerAnimationPlayer = $PlayerAnimations
onready var enemyAnimationPlayer = $EnemyAnimations

onready var playerSprite = find_node("PlayerSprite")
onready var enemySprite = find_node("EnemySprite")

onready var swordSprite = $Sword
onready var magicSprite = $Magic
onready var magicEffectSprite = $MagicEffect
onready var healSprite = $Heal
onready var healEffectSprite = $HealEffect

onready var textboxLabel = $UserCombatInterface/Textbox/Text

var enemyDamageDealt = round(rand_range(1, 3))

var enemyTurnIsRunning: bool
var hidePlayerUI: bool
#------------------------------------------------------------------------------
signal enemyTurnEnded
#------------------------------------------------------------------------------
func _ready():
	playerActionPoints = maxPlayerActionPoints
	enemyActionPoints = maxEnemyActionPoints
	
	playerSprite.position = Vector2(55, 95)
	swordSprite.position = Vector2(70, 95)
	
	swordSprite.hide()
	magicSprite.hide()
	magicEffectSprite.hide()
	healSprite.hide()
	healEffectSprite.hide()
	
	textboxLabel.text = ""
	
	defendButton.disabled = true
	spareButton1.disabled = true
	spareButton2.disabled = false

func _process(delta):
	playerHealthValue.text = str(playerHealth)
	playerActionPointsValue.text = str(playerActionPoints)
	playerManaPointsValue.text = str(playerManaPoints)
	enemyHealthValue.text = str(enemyHealth)

	if playerSprite.position == Vector2(55, 95):
		playerAnimationPlayer.play("PlayerIdle")

	if enemySprite.position == Vector2(199, 33):
		enemyAnimationPlayer.play("EnemyIdle")
	
	if playerHealth <= 0:
		textboxLabel.text = enemyName + " killed you!"
		playerHealthValue.text = "0"
		playerSprite.frame = 4
		yield(get_tree().create_timer(0.2), "timeout")
		playerSprite.frame = 5
		yield(get_tree().create_timer(0.2), "timeout")
		playerSprite.hide()
		yield(get_tree().create_timer(1), "timeout")
		hidePlayerUI = true
		get_tree().change_scene_to(previousScene)
		
	
	if enemyHealth <= 0:
		textboxLabel.text = "You killed " + enemyName + "!"
		enemyHealthValue.text = "0"
		enemySprite.frame = 4
		yield(get_tree().create_timer(0.2), "timeout")
		enemySprite.frame = 5
		yield(get_tree().create_timer(0.2), "timeout")
		enemySprite.hide()
		hidePlayerUI = true
		yield(get_tree().create_timer(1), "timeout")
		get_tree().change_scene_to(previousScene)
	
	if hidePlayerUI == true:
		swordButton.hide()
		magicButton.hide()
		healButton.hide()
		defendButton.hide()
		spareButton1.hide()
		spareButton2.hide()
	elif hidePlayerUI == false:
		swordButton.show()
		magicButton.show()
		healButton.show()
		defendButton.show()
		spareButton1.show()
		spareButton2.show()
	
	if enemyTurnIsRunning == true:
		hidePlayerUI = true
		playerActionPoints = maxPlayerActionPoints
	
	if playerHealth >= 25:
		playerHealth = maxPlayerHealth
	
	if playerManaPoints > 5:
		playerManaPoints = 5
	elif playerManaPoints < 0:
		playerManaPoints = 0
	
	player_turn()

func player_turn():
	yield(get_tree().create_timer(3), "timeout")

	if playerActionPoints == 0:
		enemy_turn()

func enemy_turn():
	enemyTurnIsRunning = true
	hidePlayerUI = true
	yield(get_tree().create_timer(0.65), "timeout")
	enemyActionPoints = maxEnemyActionPoints
	
	if enemyActionPoints != 0:
		enemy_attack()
	elif enemyActionPoints == 0:
		player_turn()

func sword_attack():
	if playerActionPoints != 0:
		playerActionPoints -= 1
		enemyHealth -= 3
		playerManaPoints += round(rand_range(0, 2))
		textboxLabel.text = "You dealt 3 damage!"
		swordSprite.show()
		playerAnimationPlayer.play("PlayerAttack")

func magic_attack():
	if playerManaPoints >= 2:
		hidePlayerUI = true
		
		magicSprite.show()
		magicEffectSprite.show()
		
		playerAnimationPlayer.play("PlayerMagicAttack")
		yield(get_tree().create_timer(0.2), "timeout")
		textboxLabel.text = "You dealt 4 damage!"
		enemyAnimationPlayer.play("EnemyDamage")
		
		enemyHealth -= 4
		playerActionPoints -= 1
		playerManaPoints -= 2
		yield(get_tree().create_timer(0.6), "timeout")
		yield(get_tree().create_timer(0.8), "timeout")
		hidePlayerUI = false
		textboxLabel.text = ""
	else:
		textboxLabel.text = "Not enough Mana Points! A minimum of 2 is required."
		yield(get_tree().create_timer(2), "timeout")
		textboxLabel.text = ""

func heal_player():
	hidePlayerUI = true
	healSprite.show()
	healEffectSprite.show()
	playerAnimationPlayer.play("PlayerHeal")
	yield(get_tree().create_timer(0.15), "timeout")
	playerHealth += 5
	playerManaPoints -= 1
	playerActionPoints -= 1
	yield(get_tree().create_timer(0.9 - 0.15), "timeout")
	hidePlayerUI = false

func player_defend():
	pass

func enemy_attack():
	if enemyActionPoints != 0:
		hidePlayerUI = true
		
		enemyActionPoints -= 1
		playerHealth -= 3
		textboxLabel.text = enemyName + " dealt " + str(enemyDamageDealt) + " damage."
		enemyAnimationPlayer.play("EnemyAttack")
		yield(get_tree().create_timer(0.2), "timeout")
		playerAnimationPlayer.play("PlayerDamage")

		yield(get_tree().create_timer(1), "timeout")
		hidePlayerUI = false
		textboxLabel.text = ""
		enemyTurnIsRunning = false

func _on_Sword_pressed():
	hidePlayerUI = true
	sword_attack()
	yield(get_tree().create_timer(0.175), "timeout")
	enemyAnimationPlayer.play("EnemyDamage")
	yield(get_tree().create_timer(0.85 - 0.175), "timeout")
	textboxLabel.text = ""
	hidePlayerUI = false

func _on_Magic_pressed():
	magic_attack()

func _on_Heal_pressed():
	heal_player()

func _on_Defend_pressed():
	player_defend()
