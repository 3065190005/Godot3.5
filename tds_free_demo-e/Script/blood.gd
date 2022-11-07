extends Sprite

var m_png = preload("res://Resources/Environmantal/blood_sprite.png");
var m_tween = Tween.new();

func _ready():
	self.texture = m_png;
	self.z_index = -10; 
	var scale = rand_range(0.6,1);
	self.scale = Vector2(scale,scale);
	self.rotation_degrees = rand_range(0,360);
	self.self_modulate = Color( 1, 1, 1, 5 );
	m_tween.interpolate_property(self, "self_modulate",
		Color( 1, 1, 1, 5 ), Color( 1, 1, 1, 0 ), 3,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	m_tween.connect("tween_completed",self,"dead");
	
	var timer = get_tree().create_timer(3);
	timer.connect("timeout",self,"timerout");

func timerout():
	get_parent().add_child(m_tween);
	m_tween.start();
	
func dead(_va1,_va2):
	m_tween.queue_free();
	queue_free();
