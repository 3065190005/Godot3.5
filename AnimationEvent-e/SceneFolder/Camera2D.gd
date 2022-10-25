extends Camera2D

onready var hero = get_parent().get_node("Hero");

func _process(_delta):
	var pos = hero.global_position;
	pos.y = global_position.y;
	self.global_position = pos;
	return;
