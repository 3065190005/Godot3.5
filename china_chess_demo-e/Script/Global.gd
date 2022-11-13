extends Node2D

var DeskTexture = preload("res://Resources/Texture/environment/background.png");
var space_instance = preload("res://Scene/Space.tscn");
# 像素尺寸最大值 width length
var m_pixel_size : Vector2;

# 逻辑尺寸最大值 width length
var m_point_size : Vector2;

# 像素尺寸与逻辑尺寸差值
var m_size_difference : Vector2;

var m_rect_vec = null;
var m_global_pos = null;

var m_another_id = null;

var m_ipaddress = "127.0.0.1";
var m_port = 16553;


func _ready():
	var main_scene = get_tree().root.get_node("Main");
	var rect_node = main_scene.get_node("DeskRect");
	m_rect_vec = rect_node.rect_size * 2.0;
	m_global_pos = rect_node.rect_position * 2.0;
	
	m_point_size = Vector2(8,9);
	m_pixel_size.x = m_rect_vec.x;
	m_pixel_size.y = m_rect_vec.y;
	
	var width_diff = m_pixel_size.x / m_point_size.x;
	var length_diff = m_pixel_size.y / m_point_size.y;
	
	m_size_difference = Vector2(width_diff, length_diff);
	
	main_scene.queue_free();
	get_tree().root.call_deferred("add_child",space_instance.instance());


func pixel_to_point(pixel_pos:Vector2):	
	pixel_pos -= m_global_pos;
	var vec = pixel_pos / m_size_difference;
	
	if(vec.x - int(vec.x) > 0.5):
		vec.x = int(vec.x) + 1;
	else:
		vec.x = int(vec.x);
		
	if (vec.y - int(vec.y) > 0.5):
		vec.y = int(vec.y) + 1;
	else:
		vec.y = int(vec.y);
		
	vec.x = clamp(vec.x, 0 ,m_point_size.x);
	vec.y = clamp(vec.y, 0 ,m_point_size.y);
	
	return vec;
	
	
func point_to_pixel(point_pos:Vector2):
	var vec = point_pos * m_size_difference;
	vec += m_global_pos;
	return vec;
