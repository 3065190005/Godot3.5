extends Node2D

export(int,"NONE","RED","BLACK") var m_color;

var m_main_scene = null;
var m_desk_manager = null;

func _ready():
	m_main_scene = get_parent();
	m_desk_manager = m_main_scene.m_desk_manager;
	
	
func _process(_delta):
	if(m_desk_manager.m_winner != null):
		return;
		
	if(Input.is_action_just_pressed("ui_click")):
		player_click();

remote func rpc_player_click(point_pos):
	if(!is_network_master()):
		m_main_scene.player_clicked(point_pos);
	

func player_click():
	if(is_network_master() && is_self_move()):
		var pixel_pos = get_global_mouse_position() * 2;
		var point_pos = Global.pixel_to_point(pixel_pos);
		m_main_scene.player_clicked(point_pos);
		rpc_id(Global.m_another_id, "rpc_player_click",point_pos);


func is_self_move():
	if(m_desk_manager.m_motion_color == m_color):
		return true;
	else:
		return false;
