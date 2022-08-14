extends Node

var battle_scene

var btl_type = BattleType.Enemy

var btl_troop: Array = [preload("res://src/resources/enemies/Snake.tres").duplicate(), preload("res://src/resources/enemies/Bee.tres").duplicate(), preload("res://src/resources/enemies/Snake.tres").duplicate()]

enum BattleType {
	Gyze,
	MiniBoss,
	Enemy,
	Boss,
	Bear,
	TrueBear,
	FinalBoss,
	LeaderJord
}

enum {
	BattleNone,
	BattleMain,
	BattleFightEnemy,
	BattleSpells,
	BattleSpellEnemy,
	BattleSpellParty,
	BattleItems,
	BattleItemsEnemy,
	BattleItemsParty,
	BattleStats
}

func startBattle(troop: Array, battle_type: int):
	btl_type = battle_type
	btl_troop = []
	for enemy in troop:
		btl_troop.append(ResourcePaths.enemies[enemy].duplicate())
	ScreenStuff.transition()
	yield(ScreenStuff, "t_done")
	ScreenStuff.get_node("TransitionLayer/Transition").hide()
	ScreenStuff.screen_fade.color.a = 1
	var _s = get_tree().change_scene("res://scenes/scenes/Battle.tscn")
	ScreenStuff.fadeIn(Color("000000"), 0.5)

func sortSpeed(a, b):
	if a.batspd > b.batspd:
		return true

func troops_out():
	for enemy in btl_troop:
		if enemy.hp <= 0:
			return true
	return false

func showDamage(target_is_party: bool, id: int, damage: int):
	var new_damage = preload("res://scenes/subscenes/important/Damage.tscn").instance()
	new_damage.text = str(damage)
	add_child(new_damage)
	if !target_is_party:
		var enemy: TextureRect = battle_scene.get_node("EnemyCont").get_child(id).get_child(0)
		new_damage.bounce(Vector2(((enemy.rect_global_position.x + (enemy.rect_size.x * enemy.rect_scale.x)) / 2) - ((new_damage.rect_size.x * new_damage.rect_scale.x)), enemy.rect_global_position.y))
	else:
		var pm: TextureRect = battle_scene.get_node("BattlerCont").get_child(id).get_child(0)
		new_damage.bounce(Vector2(((pm.rect_global_position.x + (pm.rect_size.x * pm.rect_scale.x)) / 2) - ((new_damage.rect_size.x * new_damage.rect_scale.x)), pm.rect_global_position.y))
