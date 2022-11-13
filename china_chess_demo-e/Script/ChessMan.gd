extends Sprite

enum CHESSTYPE{NONE,JV,MA,XIANG,SHI,JIANG,PAO,BING}
enum PLAYERCOLOR{NONE,RED,BLACK}


export(CHESSTYPE) var m_type;
export(PLAYERCOLOR) var m_color;
var m_point_pos := Vector2(0,0);


func get_desk_manager():
	var desk_manager = get_tree().root.get_node("Main").get_node("DeskManager");
	return desk_manager;


func create(pos, type, color):
	m_point_pos = pos;
	m_color = color;
	m_type = type;


func get_chess_texture(type):
	var name = "";
	match type:
		CHESSTYPE.JV:
			name = "che";
		CHESSTYPE.MA:
			name = "ma";
		CHESSTYPE.XIANG:
			name = "xiang";
		CHESSTYPE.SHI:
			name = "shi";
		CHESSTYPE.JIANG:
			name = "shuai";
		CHESSTYPE.PAO:
			name = "pao";
		CHESSTYPE.BING:
			name = "bing";
			
	if(m_color == PLAYERCOLOR.RED):
		name = "redChessMan/r" + name + ".png";
	else:
		name = "blackChessMan/b" + name + ".png";
	return load("res://Resources/Texture/" + name);


func _ready():
	var texture =  get_chess_texture(m_type);
	set_texture(texture);


func can_move(_iskill,pos):
	match m_type:
		CHESSTYPE.JV:
			return moveJv(_iskill,pos);
		CHESSTYPE.MA:
			return moveMa(_iskill,pos);
		CHESSTYPE.XIANG:
			return moveXiang(_iskill,pos);
		CHESSTYPE.SHI:
			return moveShi(_iskill,pos);
		CHESSTYPE.JIANG:
			return moveJiang(_iskill,pos);
		CHESSTYPE.PAO:
			return movePao(_iskill,pos);
		CHESSTYPE.BING:
			return moveBing(_iskill,pos);


func moveJv(_isKill,pos):
	var desk_manager = get_desk_manager();
	var now_pos = m_point_pos;
	var new_pos = pos;
	
	var amount_array = desk_manager.find_all_chess_with_rect(now_pos,new_pos);
	var amount = 0;
	if(amount_array):
		amount = amount_array.size();
	
	if(_isKill && amount != 2):
		return false;
	elif(!_isKill && amount != 1):
		return false;
	return true;
	
	
func moveMa(_isKill,pos):
	var desk_manager = get_desk_manager();
	var now_pos = m_point_pos;
	var new_pos = pos;
	var sub_pos = now_pos - new_pos;
	var dir = abs(sub_pos.x) * 10 + abs(sub_pos.y);
	
	var leg_pos = null;
	if(dir == 12):
		leg_pos = Vector2(now_pos.x,abs((now_pos.y + new_pos.y)/2.0));
	elif(dir == 21):
		leg_pos = Vector2(abs((now_pos.x + new_pos.x)/2.0),now_pos.y);
		
	if(leg_pos != null):
		var finder = desk_manager.find_chess_with_pos(leg_pos);
		if(finder == null || finder.m_color != m_color):
			return true;
					
	return false;
	
	
func moveXiang(_isKill,pos):
	var desk_manager = get_desk_manager();
	var now_pos = m_point_pos;
	var new_pos = pos;
	var sub_pos = now_pos - new_pos;
	var dir = abs(sub_pos.x) * 10 + abs(sub_pos.y);
	
	var leg_pos = null;
	
	if(m_color == PLAYERCOLOR.RED && pos.y > 5):
		return false;
		
	if(m_color == PLAYERCOLOR.BLACK && pos.y < 5):
		return false;
	
	if(dir == 22):
		leg_pos = Vector2(abs((now_pos.x + new_pos.x)/2.0),abs((now_pos.y + new_pos.y)/2.0));
		
	if(leg_pos != null):
		var finder = desk_manager.find_chess_with_pos(leg_pos);
		if(finder == null || finder.m_color != m_color):
			return true;
		
	return false;
	
	
func moveShi(_isKill,pos):
	var desk_manager = get_desk_manager();
	var now_pos = m_point_pos;
	var new_pos = pos;
	var sub_pos = now_pos - new_pos;
	var dir = abs(sub_pos.x) * 10 + abs(sub_pos.y);
	
	var leg_pos = null;
	
	if(pos.x < 3 || pos.x > 5):
		return false;
	
	if(m_color == PLAYERCOLOR.RED && pos.y > 2):
		return false;
		
	if(m_color == PLAYERCOLOR.BLACK && pos.y < 7):
		return false;
	
	if(dir == 11):
		leg_pos = Vector2(abs((now_pos.x + new_pos.x)/2.0),abs((now_pos.y + new_pos.y)/2.0));
		
	if(leg_pos != null):
		var finder = desk_manager.find_chess_with_pos(leg_pos);
		if(finder == null || finder.m_color != m_color):
			return true;
		
	return false;
	
	
func moveJiang(_isKill,pos):
	var desk_manager = get_desk_manager();
	var now_pos = m_point_pos;
	var new_pos = pos;
	var sub_pos = now_pos - new_pos;
	var dir = abs(sub_pos.x) * 10 + abs(sub_pos.y);
	
	var array_j = desk_manager.find_all_chess_with_rect(m_point_pos,pos);
	var finder_j = desk_manager.find_chess_with_pos(pos);
	
	if(array_j != null && array_j.size() == 2):
		if(finder_j != null && finder_j.m_type == CHESSTYPE.JIANG):
			return true;
	
	var leg_pos = null;
	
	if(pos.x < 3 || pos.x > 5):
		return false;
	
	if(m_color == PLAYERCOLOR.RED && pos.y > 2):
		return false;
		
	if(m_color == PLAYERCOLOR.BLACK && pos.y < 7):
		return false;
	
	if(dir == 01):
		leg_pos = Vector2(new_pos.x,abs((now_pos.y + new_pos.y)/2.0));
	elif(dir == 10):
		leg_pos = Vector2(abs((now_pos.x + new_pos.x)/2.0),new_pos.y);
		
	if(leg_pos != null):
		var finder = desk_manager.find_chess_with_pos(leg_pos);
		if(finder == null || finder.m_color != m_color):
			return true;
		
	return false;
	
	
func movePao(_isKill,pos):
	var desk_manager = get_desk_manager();
	var now_pos = m_point_pos;
	var new_pos = pos;
	
	var amount_array = desk_manager.find_all_chess_with_rect(now_pos,new_pos);
	var amount = 0;
	if(amount_array):
		amount = amount_array.size();
	
	if(_isKill && amount != 3):
		return false;
	elif(!_isKill && amount != 1):
		return false;
		
	return true;
	
	
func moveBing(_isKill,pos):
	var desk_manager = get_desk_manager();
	var now_pos = m_point_pos;
	var new_pos = pos;
	var sub_pos = now_pos - new_pos;
	var dir = abs(sub_pos.x) * 10 + abs(sub_pos.y);
	
	if(dir != 10 && dir != 1):
		return false;
	
	var leg_pos = null;
	if(m_color == PLAYERCOLOR.RED):
		if(sub_pos.y == -1 || (abs(sub_pos.x) == 1 && now_pos.y > 4)):
			leg_pos = Vector2(abs(now_pos.x + new_pos.x)/2.0,abs((now_pos.y + new_pos.y)/2.0));
		else:
			return false;
	else:
		if(sub_pos.y == 1 || (abs(sub_pos.x) == 1 && now_pos.y < 5)):
			leg_pos = Vector2(abs(now_pos.x + new_pos.x)/2.0,abs((now_pos.y + new_pos.y)/2.0));
		else:
			return false;
		
	if(leg_pos != null):
		var finder = desk_manager.find_chess_with_pos(leg_pos);
		if(finder == null || finder.m_color != m_color):
			return true;
					
	return false;
