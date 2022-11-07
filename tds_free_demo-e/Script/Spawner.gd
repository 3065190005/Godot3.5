extends Sprite

enum SpawnType {ZombieMan};

export(SpawnType) var m_spawn_type;
export var m_max_count = 30;
export var m_spawn_cd_min = 0;
export var m_spawn_cd_max = 0;
export var m_spawn_open = true;
export(Vector2) var m_range_pos_min = Vector2(1,1);
export(Vector2) var m_range_pos_max = Vector2(-1,-1);

var m_spawn_count = 0;

var m_zombie_man = preload("res://Scene/ZombieMan.tscn");

func _ready():
	self.visible = false;
	var cd = rand_range(m_spawn_cd_min,m_spawn_cd_max);
	if(m_spawn_open):
		$Timer.start(cd);
		
func _on_Timer_timeout():
	if(m_spawn_count <= m_max_count && m_spawn_open == true):
		var pos_x = rand_range(m_range_pos_min.x,m_range_pos_max.x);
		var pos_y = rand_range(m_range_pos_min.y,m_range_pos_max.y);
		var cd = rand_range(m_spawn_cd_min,m_spawn_cd_max);
		var global_pos = self.global_position + Vector2(pos_x, pos_y);
		var spawn = m_zombie_man.instance();
		spawn.global_position = global_pos;
		spawn.global_scale = Vector2(0.3,0.3);
		get_parent().add_child(spawn);
		m_spawn_count += 1;
		$Timer.start(cd);
