extends AudioStreamPlayer

onready var playerStats = preload("res://PlayerStats.tres")

var count = 0

func _ready():
	volume_db = -100

func _process(delta):
	if playerStats.playHitSound == true:
		while count <= 0:
			count += 1
			volume_db = 0
			play()
			print('play')
	
	if playerStats.playHitSound == false:
		count = 0
