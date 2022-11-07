extends Node2D

enum WeaponType{FLUSHLIGHT,HANDSHOT,AUTOSHOT};	# 武器类型枚举
enum AnimType{flush,handshot,autoshot};			# 武器动画类型枚举
enum AnimMotion{idle,move,attack,reload,shoot}; # 武器动画动作枚举
enum ItemsType{HANDSHOT,AUTOSHOT};				# 物品类型枚举
enum Difficulty{Easy,Hard};						# 游戏难度

class AmmoClass:
	var m_ammo_left = 0.0;
	var m_ammo_right = 0.0;
	var m_ammo_max = 0.0;
	
	func _init(left,right,m):
		m_ammo_left = left;
		m_ammo_right = right;
		m_ammo_max = m;

export var m_hand_shot_cd = 0.43; 	# hand shot fire cd
export var m_hand_offset = 0.07;  	# hand shot fire offset
export var m_hand_damage = 33;	  	# hand shot fire damage
export var m_hand_distance = 400; 	# hand shot fire run distance
var m_hand_ammo_class := AmmoClass.new(0,0,7);

export var m_auto_shot_cd = 0.12; 	# auto shot fire cd
export var m_auto_offset = 0.2;  	# auto shot fire offset
export var m_auto_damage = 40;	 	# auto shot fire damage
export var m_auto_distance = 800; 	# auto shot fire run distance
export var m_auto_left_ammo = 0;	# auto shot left ammo count
export var m_auto_right_ammo = 0;	# auto shot right ammo count
var m_auto_ammo_class = AmmoClass.new(0,0,35);

var m_shot_cd = 0.0; 			# now shot fire cd
var m_shot_offset = 0.0;  		# now shot range offset
var m_shot_damage = 0.0;  		# now guns bullet damage
var m_shot_distance = 0.0;		# now bullet run distance
var m_shot_ammo :AmmoClass = null;

export var m_zombie_speed_add = 1; # zombie max speed
var m_zombie_speed = 0;

func show_enum():
	get_tree().root.get_node("Menu").show();
	get_tree().paused = false;
	
func re_game():
	m_zombie_speed = 0;
	
	m_hand_ammo_class.m_ammo_left = 0;
	m_hand_ammo_class.m_ammo_right = 0;
	m_hand_ammo_class.m_ammo_max = 7;
	
	m_auto_ammo_class.m_ammo_left = 0;
	m_auto_ammo_class.m_ammo_right = 0;
	m_auto_ammo_class.m_ammo_max = 35;
	
	m_shot_cd = 0.0;
	m_shot_offset = 0.0;
	m_shot_damage = 0.0;
	m_shot_distance = 0.0;
	m_shot_ammo = null;
	
	$Timer.start();
	get_tree().paused = false;
	

func change_weapon(type):
	match (type):
		WeaponType.HANDSHOT:
			m_shot_cd = m_hand_shot_cd;
			m_shot_offset = m_hand_offset;
			m_shot_damage = m_hand_damage;
			m_shot_distance = m_hand_distance;
			m_shot_ammo = m_hand_ammo_class;
		WeaponType.AUTOSHOT:
			m_shot_cd = m_auto_shot_cd;
			m_shot_offset = m_auto_offset;
			m_shot_damage = m_auto_damage;
			m_shot_distance = m_auto_distance;
			m_shot_ammo = m_auto_ammo_class;
		WeaponType.FLUSHLIGHT:
			m_shot_cd = 0.0;
			m_shot_offset = 0.0;
			m_shot_damage = 0.0;
			m_shot_distance = 0.0;
			m_shot_ammo = null;

# 每1秒增加1难度
func _on_Timer_timeout():
	m_zombie_speed += m_zombie_speed_add;
