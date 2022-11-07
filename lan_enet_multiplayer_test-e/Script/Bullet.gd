extends Node2D

var m_color = Global.PlayerColor.Green;
var m_angle = 0;
var m_speed = 500;

func _ready():
	$AudioStreamPlayer2D.pitch_scale = rand_range(0.8,1.2);
	$AudioStreamPlayer2D.play();
	
	if(m_color == Global.PlayerColor.Red):
		$Area2D.collision_layer = 4;
		$Area2D.collision_layer = 2;
		$ColorRect.color = Color(1,0,0,1);
	else:
		$Area2D.collision_layer = 2;
		$Area2D.collision_layer = 4;
		$ColorRect.color = Color(0,0,1,1);
	
	self.global_rotation = m_angle;
	
func _physics_process(delta):	
	self.global_position += Vector2(0,-1).rotated(m_angle) * m_speed * delta;

func _on_Area2D_area_entered(area):
	var body = area.get_parent();
	body.on_hurt();
	queue_free();
	
func on_hurt():
	queue_free();
