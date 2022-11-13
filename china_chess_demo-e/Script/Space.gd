extends Node2D

var main_instance = preload("res://Scene/Main.tscn");

func _ready():
	get_tree().connect("network_peer_connected", self ,"on_connect_callback");
	get_tree().connect("network_peer_disconnected", self ,"on_disconnect_callback");

func updateIpaddress():
	Global.m_ipaddress = $IpText.text;
	Global.m_port = int($PortText.text);

func _on_ClientButton_pressed():
	updateIpaddress();
	var peer = NetworkedMultiplayerENet.new();
	peer.create_client(Global.m_ipaddress, Global.m_port);
	get_tree().network_peer = peer;
	set_button_clicked("waitting for connect server ...");


func _on_ServerButton_pressed():
	updateIpaddress();
	var peer = NetworkedMultiplayerENet.new();
	peer.create_server(Global.m_port,1);
	get_tree().network_peer = peer;
	set_button_clicked("waitting for client connect ...");
	
	
func set_button_clicked(string):
	$IpText.editable = false;
	$PortText.editable = false;
	$ClientButton.disabled = true;
	$ServerButton.disabled = true;
	$StateText.text = string;
	$StateText.show();
	
func on_connect_callback(id):
	var scene = main_instance.instance();
	Global.m_another_id = id;
	get_tree().disconnect("network_peer_connected", self ,"on_connect_callback");
	get_tree().disconnect("network_peer_disconnected", self ,"on_disconnect_callback");
	
	get_tree().root.add_child(scene);
	scene.reset_game();
	queue_free();
	
	
func on_disconnect_callback(id):
	Global.m_another_id = null;
