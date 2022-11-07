extends Node2D

var Enemy = preload("res://SceneFolder/Enemy.tscn")

var global = global_define;

export var bgm_disabled : bool;

export var pos_v = 100;

func _process(_delta):	
	# 敌人刷新
	if(global.m_enemy_count <= 3):
		var enemy = Enemy.instance();
		var hero = $Hero;
		var hero_pos = hero.global_position.x;
		var pos = rand_range(-300,300);
		
		if(pos <= 0):
			pos = hero_pos - (pos_v + pos);
		else:
			pos = hero_pos + (pos_v + pos);
		
		enemy.set_scale(Vector2(2.3,2.3));
		enemy.position = Vector2(pos,300);
		add_child(enemy);

func _ready():
	self.visible = true;
	
	if(bgm_disabled):
		return;
		
	var tween = get_node("Tween")
	$BGM.play()
	tween.interpolate_property($BGM, "volume_db",
		-80, 0, 4,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

