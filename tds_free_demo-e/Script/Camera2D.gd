extends Camera2D

export var scale_time = 4.0;

func _process(_delta):
	camera_pos_update();
	
func camera_pos_update():
	var main_scene = get_parent();
	var survivor = main_scene.get_node("Survivor");
	var self_pos = survivor.global_position;
	var mouse_pos = get_global_mouse_position();
	
	self_pos += (mouse_pos - self_pos) / scale_time;
	self.global_position = self_pos;
