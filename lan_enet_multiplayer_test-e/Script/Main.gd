extends Node2D

var m_player = preload("res://Scene/Player.tscn");

var m_enet = NetworkedMultiplayerENet.new();
var m_ip = Global.m_ip_addr;
var m_port = Global.m_ip_port;

var m_player1  = null;
var m_player2  = null;

func _ready():	
	$UiLayer/PortEdit.hide();
	get_tree().set_network_peer(null);
	$GameLayer/Player1Heath.hide();
	$GameLayer/Player2Heath.hide();
	$BgLayer/TextureRect.hide();
	pass
	
func _process(_delta):
	if(m_player1 == null || m_player2 == null):
		return;
		
	$GameLayer/Player1Heath.text = "P1HP:"+str(m_player1.m_heath);
	$GameLayer/Player2Heath.text = "P2HP:"+str(m_player2.m_heath);
	
	var player1_pos = m_player1.global_position;
	var player2_pos = m_player2.global_position;
	
	var angle_1 = (player2_pos - player1_pos).angle() + Vector2(0,1).angle();
	var angle_2 = (player1_pos - player2_pos).angle() + Vector2(0,1).angle();
	m_player1.rotation = angle_1;
	m_player2.rotation = angle_2;
		
	if(m_player1.m_heath == 0):
		rpc_id(Global.m_another_id,"game_over",2);
		game_over(2);
	elif(m_player2.m_heath == 0):
		rpc_id(Global.m_another_id,"game_over",1);
		game_over(1);
	
remote func ready_game():
	$GameLayer/Player1Heath.show();
	$GameLayer/Player2Heath.show();
	$BgLayer/TextureRect.show();
	
	var player1Id = get_tree().get_network_unique_id();
	var player2Id = Global.m_another_id;
	
	if(!get_tree().is_network_server()):
		player1Id = Global.m_another_id;
		player2Id = get_tree().get_network_unique_id();
	
	var player1 = m_player.instance();
	player1.set_name(str(player1Id));
	player1.set_network_master(player1Id);
	player1.position = $GameLayer/Player1Pos.position;
	player1.m_color = Global.PlayerColor.Red;
	player1.scale = Vector2(0.6,0.6);
	$GameLayer.add_child(player1);
	m_player1 = player1;
	
	var player2 = m_player.instance();
	player2.set_name(str(player2Id));
	player2.set_network_master(player2Id);
	player2.position = $GameLayer/Player2Pos.position;
	player2.m_color = Global.PlayerColor.Blue;
	player2.scale = Vector2(0.6,0.6);
	$GameLayer.add_child(player2);
	m_player2 = player2;
	
	
		
func init_network():	
	var join_state = null;
	var peer = NetworkedMultiplayerENet.new();
	if(!Global.m_is_server):
		join_state = peer.create_client(m_ip,m_port);
	else:
		join_state = peer.create_server(m_port);
		
	if(join_state != OK):
		return false;
				
	get_tree().set_network_peer(peer);

func init_network_single():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connection_failed", self, "_connection_failed")
	get_tree().connect("server_disconnected", self, "_connection_failed")
	
func _player_connected(id):
	Global.m_another_id = id;
	$UiLayer/StateUi.text = "Connected";
	pass
	
func _player_disconnected(id):
	Global.m_another_id = null;
	get_tree().reload_current_scene();
	pass
	
func _connection_failed():
	Global.m_another_id = null;
	get_tree().reload_current_scene();
	pass
	
func _connected_ok():
	ready_game();
	rpc_id(Global.m_another_id,"ready_game");


func _on_ServerBtn_pressed():
	Global.m_is_server = false;
	$UiLayer/ClientBtn.text = "ClientMode";
	$UiLayer/ClientBtn.disabled = true;
	$UiLayer/PortEdit.show();

func _on_StartBtn_pressed():
	$UiLayer/StartBtn.text = "Started";
	while (init_network()):
		print("connect success");
	init_network_single();
	Global.m_ip_addr = $UiLayer/IpEdit.text;
	Global.m_ip_port = int($UiLayer/PortEdit.text);
	
	$UiLayer/PortEdit.hide();
	$UiLayer/StartBtn.hide();
	$UiLayer/ClientBtn.hide();
	$UiLayer/IpEdit.hide();
	
remote func game_over(player):
	get_tree().paused = true;
	if(player != 0):
		$UiLayer/StateUi.text = "player : " + str(player) + " is winner";
	yield (get_tree().create_timer(3),"timeout");
	
	get_tree().paused = false;
	Global.m_another_id = null;
	get_tree().reload_current_scene();
