extends CanvasLayer

onready var ammo = $AmmoCount;
onready var h_ui = $HeathUi;
onready var DeadUi = $DeadUi;
onready var heath_n = $HeathNumber;
onready var alive_t = $AliveTime;
onready var diff_t = $DifficultyTxt;


var survival_time = 0;

func _ready():
	ammo.visible = true;

func _process(_delta):
	# 设置弹药UI
	if(Global.m_shot_ammo == null):
		ammo.text = String("AMMO:") + "null";
	else:
		ammo.text = String("AMMO:") + String(Global.m_shot_ammo.m_ammo_left) + " / " + String(Global.m_shot_ammo.m_ammo_right);
	
	# 设置血条UI
	heath_n.text = String("HEATH:") + String($"../Survivor".m_heath);
	
		# 设置难度显示
	if(get_parent().m_difficulty == Global.Difficulty.Easy):
		diff_t.text = "Difficulty:Easy";
	else:
		diff_t.text = "Difficulty:Hard";
	
	# 设置生存时间
	survival_time += _delta;
	var string = "survival time : %0.3f";
	alive_t.text =  string % survival_time;
	
	# 判断是否触发死亡动画
	var alpha = $"../Survivor".m_heath / 100.0;
	h_ui.self_modulate = Color(1,1,1,1 - alpha);
	if($"../Survivor".m_heath <= 0):
		get_tree().paused = true
		dead_over();

# 死亡动画执行
func dead_over():
	var tween = Tween.new();
	tween.pause_mode = PAUSE_MODE_PROCESS;
	tween.connect("tween_all_completed",$"..","re_game");
	tween.interpolate_property(DeadUi, "self_modulate",
		Color(1,1,1,0), Color(1,1,1,1), 2,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	get_parent().add_child(tween);
	tween.start();
