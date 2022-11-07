extends KinematicBody2D
var m_speed = 300;
var m_color = null;

onready var m_body = $Body;
var m_velocity = Vector2.ZERO;

var m_bullet = preload("res://Scene/Bullet.tscn");

var m_heath = 100;

func _ready():
	init_data();
	
func _process(_delta):
	var velocity = Vector2.ZERO;
	if(Input.is_action_pressed("ui_up")):
		velocity.y -= 1;
	if(Input.is_action_pressed("ui_down")):
		velocity.y += 1;
	if(Input.is_action_pressed("ui_left")):
		velocity.x -= 1;
	if(Input.is_action_pressed("ui_right")):
		velocity.x += 1;
		
	move(velocity);
	
	if(Input.is_action_pressed("ui_attack") && $AttackCd.time_left <= 0):
		$AttackCd.start();
		attack();
		
	if(m_velocity.x != 0):
		$PLeft.process_material.orbit_velocity = m_velocity.x / 2.7;
		$PRight.process_material.orbit_velocity = m_velocity.x / 2.7;
	else:
		$PLeft.process_material.orbit_velocity = 0;
		$PRight.process_material.orbit_velocity = 0;
		
func _physics_process(_delta):
	move_and_slide(m_velocity * m_speed);
		
func init_data():
	var texture = null;
	var hurt_layer = null;
	var hurt_mask = null;
	match m_color:
		Global.PlayerColor.Blue:
			texture = load("res://Resources/blue_player.png");
			hurt_layer = 4;
			hurt_mask = 2;
		Global.PlayerColor.Red:
			texture = load("res://Resources/red_player.png");
			hurt_layer = 2;
			hurt_mask = 4;
	
	$HurtArea.collision_layer = hurt_layer;
	$HurtArea.collision_mask = hurt_mask;
	m_body.texture = texture;

remote func rpc_move(pos:Vector2,gpos:Vector2):
	var sender = get_tree().get_rpc_sender_id();
	var another = get_network_master();
	if(sender == another):
		m_velocity = pos;
		global_position = gpos;
		
remote func rpc_attack():
	var sender = get_tree().get_rpc_sender_id();
	var another = get_network_master();
	if(sender == another):
		var hins = m_bullet.instance();
		hins.m_color = m_color;
		hins.m_angle = self.global_rotation;
		hins.global_position = $FirePos.global_position;
		hins.scale = Vector2(0.8,0.8);
		get_parent().add_child(hins);
	
func attack():
	if(is_network_master()):
		var hins = m_bullet.instance();
		hins.m_color = m_color;
		hins.m_angle = self.global_rotation;
		hins.global_position = $FirePos.global_position;
		hins.scale = Vector2(0.8,0.8);
		get_parent().add_child(hins);
	var anoId = Global.m_another_id;
	rpc_id(anoId,"rpc_attack");

func move(vec):
	var sub_pos = vec;
	if(is_network_master()):
		m_velocity = sub_pos;
	var anoId = Global.m_another_id;
	rpc_unreliable_id(anoId,"rpc_move",sub_pos,global_position);
	
func on_hurt():
	m_heath -= 5;
