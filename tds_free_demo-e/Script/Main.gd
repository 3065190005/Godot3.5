extends Node2D

export(int,"Easy","Hard") var m_difficulty;

var m_blood = preload("res://Script/blood.gd");

var m_bgm_1 = preload("res://Resources/Sound/battle_bgm_1.mp3");
var m_bgm_2 = preload("res://Resources/Sound/battle_bgm_2.mp3");

var m_item_spawn = preload("res://Scene/Items.tscn");

func _ready():
	if(m_difficulty == Global.Difficulty.Easy):
		$Camera2D/WhiteBg.visible = false;
		$CanvasModulate.visible = false;
	else:
		$Camera2D/WhiteBg.visible = true;
		$CanvasModulate.visible = true;
	var random = RandomNumberGenerator.new()
	random.randomize()
	var numb = random.randfn();
	if(numb > 0):
		$BGM.stream = m_bgm_1;
	else:
		$BGM.stream = m_bgm_2;
		
	$BGM.play();

func get_survivor():
	var finder = find_node("Survivor");
	return finder;

func create_blood(pos):
	var blood =  m_blood.new();
	blood.global_position = pos;
	self.add_child(blood);
	
func random_create_item(pos,type):
	var random = RandomNumberGenerator.new()
	random.randomize()
	var numb = random.randfn();
	if(numb > 0.8):
		var adder = m_item_spawn.instance();
		adder.m_item_type = type;
		adder.global_position = pos;
		adder.z_index = 1;
		adder.set_deferred("scale",Vector2(0.3,0.3));
		self.add_child(adder);

func re_game():
	Global.show_enum();
	get_tree().root.remove_child(self);
	queue_free();
	
func _process(_delta):
	if(Input.is_action_just_released("ui_exit")):
		 get_tree().quit();
