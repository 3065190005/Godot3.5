extends Control

var m_main_scene = preload("res://Scene/Main.tscn");

var difficulty = Global.Difficulty.Easy;

func getDifficulty():
	if(difficulty == Global.Difficulty.Easy):
		return "Easy";
	else:
		return "Hard";

func _ready():
	pass

func _process(_delta):
	$DiffButton.text =  getDifficulty();
	if(Input.is_action_just_released("ui_exit")):
		 get_tree().quit();
	
func _on_StartButton_button_up():
	Global.re_game();
	var scene = m_main_scene.instance();
	scene.m_difficulty = difficulty;
	get_tree().root.add_child(scene);
	self.hide();


func _on_DiffButton_button_up():
	if(difficulty == Global.Difficulty.Easy):
		difficulty = Global.Difficulty.Hard;
	else:
		difficulty = Global.Difficulty.Easy;
