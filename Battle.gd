extends Node2D

signal pm_choices_done
signal queue_over

var turn_queue: Dictionary = {}
var queue_id: int

var turn_active: bool = false
var queue_active: bool = false

var preemptive: bool = false
var ambush: bool = false

var curr_menu: int = BattleStuff.BattleMain

# Menu Cursors
onready var troop_curs = $BattleCursor

func _ready():
	preemptive = ImportantStuff.chance(3)
	ambush = ImportantStuff.chance(3) and !preemptive
	
	match BattleStuff.btl_type:
		BattleStuff.BattleType.LeaderJord: AudioManager.playMusic(MusicPaths.paths["SecretBoss"])
	
	for node in $EnemyCont.get_children():
		$EnemyCont.remove_child(node)
		node.queue_free()
	
	for enemy in BattleStuff.btl_troop.size():
		var new_enemy = VBoxContainer.new()
		new_enemy.alignment = BoxContainer.ALIGN_END
		new_enemy.add_child(TextureRect.new())
		$EnemyCont.add_child(new_enemy)
	
	if preemptive:
		partyChoices()
		yield(self, "pm_choices_done")
		turnProcess(true, false)
	elif ambush:
		turnProcess(false, true)
	
	while true:
		yield(self, "queue_over")
		if BattleStuff.troops_out() or PlayerStuff.pms_out():
			break
		partyChoices()
		yield(self, "pm_choices_done")
		turnProcess(true, true)
	
	if PlayerStuff.pms_out():
		gameOver()
	elif BattleStuff.troops_out():
		victory()

func _process(_delta):
	for pm in PlayerStuff.pms.size():
		$BattlerLayer/BattlerCont.get_child(pm).get_node("Name").text = PlayerStuff.pms[pm].name
		$BattlerLayer/BattlerCont.get_child(pm).get_node("HP/Cur").text = str(PlayerStuff.pms[pm].hp)
		$BattlerLayer/BattlerCont.get_child(pm).get_node("HP/Max").text = str(PlayerStuff.pms[pm].maxhp)
		$BattlerLayer/BattlerCont.get_child(pm).get_node("SP/Cur").text = str(PlayerStuff.pms[pm].sp)
		$BattlerLayer/BattlerCont.get_child(pm).get_node("SP/Max").text = str(PlayerStuff.pms[pm].maxsp)
		
		$BattlerCont.get_child(pm).get_node("Sprite").texture = ImagePaths.battlers[PlayerStuff.pms[pm].name]
		if get_node("BattlerLayer/BattlerCont").get_child_count() < pm + 1:
			var new_panel = preload("res://scenes/subscenes/ui/menus/battle/BattlerPanel.tscn").instance()
			$BattlerLayer/BattlerCont.add_child(new_panel)
	
	for extra in range(PlayerStuff.pms.size(), get_node("BattlerLayer/BattlerCont").get_child_count()):
		$BattlerCont.get_child(extra).queue_free()
		$BattlerLayer/BattlerCont.get_child(extra).queue_free()
	
	for enemy in BattleStuff.btl_troop.size():
		$EnemyCont.get_child(enemy).get_child(0).texture = BattleStuff.btl_troop[enemy].sprite
		if turn_active:
			$EnemyCont.get_child(enemy).get_child(0).visible = BattleStuff.btl_troop[enemy].hp > 0
	
	# Menu Stuff
	troop_curs.visible = curr_menu in [BattleStuff.BattleFightEnemy, BattleStuff.BattleItemsEnemy, BattleStuff.BattleSpellEnemy] and !queue_active
	troop_curs.movable = troop_curs.visible
	
	# Confirm Menus #
	if Input.is_action_just_pressed("confirm") and !queue_active:
		match curr_menu:
			BattleStuff.BattleMain:
				pass

func partyChoices():
	for pm in PlayerStuff.pms.size():
		curr_menu = BattleStuff.BattleMain
		if PlayerStuff.pms[pm].hp > 0:
			makeChoice(pm)
			
	emit_signal("pm_choices_done")

func turnProcess(party: bool, enemy: bool):
	queue_active = true
	curr_menu = BattleStuff.BattleNone
	if party:
		for pm in PlayerStuff.pms:
			pass
	if enemy:
		for enemy in BattleStuff.btl_troop:
			pass
	
	queue_id = 0
	
	while true:
		turn_active = true
		for battler in turn_queue.keys():
			if battler.hp <= 0:
				turn_queue.erase(battler)
		turn_active = false
	
	queue_active = false
	
	emit_signal("queue_over")

func gameOver():
	Dialogue.startDialogue("", "%s's party lost..." % PlayerStuff.pms[0].name, false)
	yield(Dialogue, "d_done")
	ScreenStuff.fadeOut(Color("000000"), 0.5)
	yield(ScreenStuff, "fade_out_done")
	var _s = get_tree().change_scene("res://scenes/scenes/GameOver.tscn")
	ScreenStuff.fadeIn(Color(0, 0, 0, 1), 0.5)

func victory():
	pass

func makeChoice(pm: int):
	while true:
		pass
