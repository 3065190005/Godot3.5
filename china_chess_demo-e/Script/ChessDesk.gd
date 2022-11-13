extends Node2D

var m_chess_man = load("res://Scene/ChessMan.tscn");

enum CHESSTYPE{NONE,JV,MA,XIANG,SHI,JIANG,PAO,BING}
enum PLAYERCOLOR{NONE,RED,BLACK}

onready var m_sprite = get_parent().find_node("ChessDesk");
onready var m_select_sprite = get_parent().find_node("Select");

var m_desk_map = [];

var m_motion_color = PLAYERCOLOR.RED;

var m_select_chess = null;
var m_tween : Tween = null;

var m_winner = null;


#初始化
func _ready():
	var main_scene = get_parent();
	m_tween = main_scene.get_node("Tween");
	m_select_sprite.global_position = Vector2(-500, -500);
	m_tween.connect("tween_all_completed",self,"on_tween_all_completed");
	

func _process(_delta):
	set_select_sprite_pos();
	if(m_winner != null):
		var main_scene = get_parent();
		main_scene.game_over(m_winner);

#创建棋子
func spawn_chess(point_pos:Vector2,type,color):
	var main_scene = get_parent().get_node("GameLayer");
	var chess = m_chess_man.instance();
	chess.create(point_pos,type,color);
	main_scene.add_child(chess);
	chess.global_position = Global.point_to_pixel(point_pos);
	chess.name = str(type) + str(color);
	m_desk_map.push_back(chess);


#创建红棋子
func spawn_red_all_chess():
	for i in 9:
		var type = i + 1;
		if(type > 5):
			type = 10 - type;
		spawn_chess(Vector2(i,0),type,PLAYERCOLOR.RED);
		
	for i in 5:
		spawn_chess(Vector2(i*2,3),CHESSTYPE.BING,PLAYERCOLOR.RED);
		
	spawn_chess(Vector2(1,2),CHESSTYPE.PAO,PLAYERCOLOR.RED);
	spawn_chess(Vector2(7,2),CHESSTYPE.PAO,PLAYERCOLOR.RED);
	

#创建黑棋子
func spawn_black_all_chess():
	for i in 9:
		var type = i + 1;
		if(type > 5):
			type = 10 - type;
		spawn_chess(Vector2(i,9),type,PLAYERCOLOR.BLACK);
		
	for i in 5:
		spawn_chess(Vector2(i*2,6),CHESSTYPE.BING,PLAYERCOLOR.BLACK);
		
	spawn_chess(Vector2(1,7),CHESSTYPE.PAO,PLAYERCOLOR.BLACK);
	spawn_chess(Vector2(7,7),CHESSTYPE.PAO,PLAYERCOLOR.BLACK);


# 创建所有棋子
func spawn_all_chess():
	spawn_red_all_chess();
	spawn_black_all_chess();


# 重置棋盘
func reset_desk():
	for i in m_desk_map:
		i.queue_free();
		
	m_desk_map = [];
	m_motion_color = PLAYERCOLOR.RED;
	
	spawn_all_chess();
	

# 获得指定坐标棋子
func find_chess_with_pos(pos):
	var chess = null;
	for i in m_desk_map:
		if(i.m_point_pos == pos):
			chess = i;
			break;
	return chess;
	

# 获得指定范围所有棋子
func find_all_chess_with_rect(pos1,pos2):
	var ret = [];
	if(pos1.x != pos2.x && pos1.y != pos2.y):
		return null;
		
	if(pos1 == pos2):
		return null;
		
	var pos_min :Vector2;
	var pos_max :Vector2;
	
	if(pos1 > pos2):
		pos_min = pos2;
		pos_max = pos1;
	else:
		pos_min = pos1;
		pos_max = pos2;
		
	if(pos1.x == pos2.x):
		for i in m_desk_map:
			if(i.m_point_pos.y >= pos_min.y && i.m_point_pos.y <= pos_max.y && i.m_point_pos.x == pos1.x):
				ret.push_back(i);
	elif(pos1.y == pos2.y):
		for i in m_desk_map:
			if(i.m_point_pos.x >= pos_min.x && i.m_point_pos.x <= pos_max.x && i.m_point_pos.y == pos1.y):
				ret.push_back(i);
	return ret;
	
	
# 设置选择icon坐标
func set_select_sprite_pos():
	if(m_select_chess):
		var pos = m_select_chess.m_point_pos;
		var pixel_pos = Global.point_to_pixel(pos);
		m_select_sprite.global_position = pixel_pos;
	else:
		m_select_sprite.global_position = Vector2(-500, -500);


# 移除指定坐标棋子
func kill_chess_man(pos):
	var size = m_desk_map.size();
	for i in size:
		if(m_desk_map[i].m_point_pos == pos):
			if(m_desk_map[i].m_type == CHESSTYPE.JIANG):
				m_winner = m_motion_color;
			m_desk_map[i].queue_free();
			m_desk_map.remove(i);
			return true;
	return false;
	

# 移动指定棋子到坐标
func chess_man_move(chess,pos):
	m_tween.interpolate_property(m_select_chess, "global_position",
	Global.point_to_pixel(m_select_chess.m_point_pos), 
	Global.point_to_pixel(pos), 0.13,
	Tween.TRANS_SINE, Tween.EASE_OUT_IN);
	m_select_chess.m_point_pos = pos;
	m_tween.start();
	
	
func play_audio(string):
	var main_scene = get_parent();
	main_scene.play_audio(string);
	pass 

# 玩家点击事件回调
func on_clicked_point(point_pos:Vector2):
	if(m_tween.is_active()):
		return;
	
	# 获取点击位置处的棋子
	var chose_chess = find_chess_with_pos(point_pos);
	
	# 没有选中任何棋子
	if(!m_select_chess && !chose_chess):
		return;
	
	# 选择新的棋子
	if(chose_chess && chose_chess.m_color == m_motion_color):
		m_select_chess = chose_chess;
		return;
	
	# 移动棋子
	var change = false;
	if(m_select_chess && !chose_chess):
		change = m_select_chess.can_move(false,point_pos);
	elif (m_select_chess && chose_chess):
		change = m_select_chess.can_move(true,point_pos);

	# 检测移动成功
	if(change):
		var iskill = false;
		iskill = kill_chess_man(point_pos);
		chess_man_move(m_select_chess,point_pos);
		if(iskill):
			play_audio("kill");
		else:
			play_audio("move");
	else:
		m_select_chess = null

func on_tween_all_completed():
	if(m_motion_color == PLAYERCOLOR.RED):
		m_motion_color = PLAYERCOLOR.BLACK;
	else:
		m_motion_color = PLAYERCOLOR.RED;
	m_select_chess = null;
