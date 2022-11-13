extends Node2D

var m_desk_node = load("res://Script/ChessDesk.gd");
var m_player_scene = preload("res://Scene/Player.tscn");
var m_desk_manager = null;

enum PLAYERCOLOR{NONE,RED,BLACK}


func _ready():
	m_desk_manager = m_desk_node.new()
	m_desk_manager.name = "DeskManager";
	add_child(m_desk_manager);
	m_desk_manager.reset_desk();
	
	
func _process(_delta):
	if(m_desk_manager):
		if(m_desk_manager.m_motion_color == PLAYERCOLOR.RED):
			$MotionPlayer.text = "Red";
			$MotionPlayer.self_modulate = Color(1,0,0,1);
		else:
			$MotionPlayer.text = "Black";
			$MotionPlayer.self_modulate = Color(0,0,0,1);
			
	
	
func reset_game():
	network_callback_init();
	player_controller_init();	
	
	
func game_over(winner):
	if(winner == PLAYERCOLOR.BLACK):
		$MotionPlayer.text = "Black is winner";
	elif(winner == PLAYERCOLOR.RED):
		$MotionPlayer.text = "Red is winner";
		
	set_process(false);
	get_tree().create_timer(5).connect("timeout",self,"change_scene");



func change_scene():
	Global.m_another_id = null;
	network_disconnect_reset();
	
	get_tree().change_scene("res://Scene/Space.tscn");
	queue_free();
	
	get_tree().network_peer = null;
	
func play_audio(string):
	if(string == "move"):
		$ChessAudio.stream = load("res://Resources/sound/move.mp3");
	elif(string == "kill"):
		$ChessAudio.stream = load("res://Resources/sound/kill.mp3");
	$ChessAudio.play();


func player_clicked(point_pos):
	if(m_desk_manager):
		m_desk_manager.on_clicked_point(point_pos);


func player_controller_init():
	var self_id = get_tree().get_network_unique_id();
	var othe_id = Global.m_another_id;
	
	var player1 = m_player_scene.instance();
	var player2 = m_player_scene.instance();
	
	var player1_color = m_desk_manager.PLAYERCOLOR.NONE;
	var player2_color = m_desk_manager.PLAYERCOLOR.NONE;
	
	if(get_tree().is_network_server()):
		player1_color = m_desk_manager.PLAYERCOLOR.RED;
		player2_color = m_desk_manager.PLAYERCOLOR.BLACK;
	else:
		player1_color = m_desk_manager.PLAYERCOLOR.BLACK;
		player2_color = m_desk_manager.PLAYERCOLOR.RED;
	
	player1.m_color = player1_color;
	player2.m_color = player2_color;
	
	player1.set_name(str(self_id));
	player2.set_name(str(othe_id));
	
	player1.set_network_master(self_id);
	player2.set_network_master(othe_id);
	
	add_child(player1);
	add_child(player2);

func network_callback_init():
	get_tree().connect("network_peer_connected", self ,"on_connect_callback");
	get_tree().connect("network_peer_disconnected", self ,"on_disconnect_callback");
	get_tree().connect("connected_to_server", self, "on_connect_success");
	get_tree().connect("connection_failed", self, "on_connect_failed");
	get_tree().connect("server_disconnected", self, "on_connect_failed");
	
	
func network_disconnect_reset():
	get_tree().disconnect("network_peer_connected", self ,"on_connect_callback");
	get_tree().disconnect("network_peer_disconnected", self ,"on_disconnect_callback");
	get_tree().disconnect("connected_to_server", self, "on_connect_success");
	get_tree().disconnect("connection_failed", self, "on_connect_failed");
	get_tree().disconnect("server_disconnected", self, "on_connect_failed");
	
	
func on_connect_callback(id):
	Global.m_another_id = id;
	
	
func on_disconnect_callback(id):
	Global.m_another_id = null;
	network_disconnect_reset();
	
	get_tree().change_scene("res://Scene/Space.tscn");
	queue_free();


func on_connect_success():
	pass
	
	
func on_connect_failed():
	Global.m_another_id = null;
	network_disconnect_reset();
	
	get_tree().change_scene("res://Scene/Space.tscn");
	queue_free();
