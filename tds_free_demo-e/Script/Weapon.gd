extends Position2D

var BulletClass = preload("res://Scene/Bullet.tscn"); # 子弹场景

export(int,"flush","hand","auto") var m_weapon = 0; # 当前武器

var reload_stream = preload("res://Resources/Sound/guns_reload.mp3"); # 换弹声音
var hand_shot_stream = preload("res://Resources/Sound/hand_shot_shooting.mp3") # 手枪声音
var auto_shot_stream = preload("res://Resources/Sound/rifle_shooting.ogg"); # 步枪声音

# 武器解锁状态
var m_unlock_list = {
	Global.WeaponType.FLUSHLIGHT:true,
	Global.WeaponType.HANDSHOT:false,
	Global.WeaponType.AUTOSHOT:false,
};

var m_open_fire = false;			# 是否可以开火
var m_self_pos := Vector2.ZERO;		# 当前全局位置
var m_target_pos := Vector2.ZERO;	# 枪口朝向全局位置
var m_shot_cd = false;				# 子弹发射间隔

# 初始化
func _ready():
	change_type(m_weapon);

# 判断是否可以切换开火状态
func is_state_fire():
	var survivor = get_parent().get_parent();
	if(survivor.is_idle_or_move() || survivor.is_on_fire()):
		return true;
	return false;
	
# 判断是否有子弹
func has_ammo():
	if (Global.m_shot_ammo == null):
		return false;
	elif(Global.m_shot_ammo.m_ammo_left == 0 &&
		 Global.m_shot_ammo.m_ammo_right == 0):
		return false;
		
	return true;

# 判断是否需要换子弹
func need_reload():
	if (Global.m_shot_ammo == null):
		return false;
	elif(Global.m_shot_ammo.m_ammo_left != 0):
		return false;
	return true;
	
# 判断是否可以换子弹
func could_reload():
	if (Global.m_shot_ammo == null):
		return false;
	elif(Global.m_shot_ammo.m_ammo_right == 0):
		return false;
	return true;
	
# 判断当前子弹是否处于满状态
func is_ammo_max():
	if(Global.m_shot_ammo == null):
		return false;
		
	var ammo_left = Global.m_shot_ammo.m_ammo_left;
	var ammo_max = Global.m_shot_ammo.m_ammo_max;
	if(ammo_left == ammo_max):
		return true;
	return false;

# 帧更新
func _process(_delta):
	# 判断是否开火，是否处于发射间隔 ，是否可以切换为开火状态
	if(!m_open_fire || m_shot_cd || !is_state_fire() || !has_ammo()):
		return;
	
	# 执行相应武器发射行为
	match (m_weapon):
		Global.WeaponType.FLUSHLIGHT:
			on_flush_light();
		Global.WeaponType.HANDSHOT:
			on_bullet_fire("handshot_shoot");
		Global.WeaponType.AUTOSHOT:
			on_bullet_fire("autoshot_shoot");

# 持有者 强制播放指定动画
func survivor_play(anim):
	if(anim != ""):
		var animated = get_parent();
		animated.play(anim);

# 持有者 开火调用函数
func on_fire(self_pos , target_pos):
	m_open_fire = true;
	m_self_pos = self_pos;
	m_target_pos = target_pos;

# 持有者 停火调用函数
func stop_fire():
	m_open_fire = false;
	
# 持有者 武器换子弹函数动画
func on_guns_reload():
	# 是否可以切换动作 当前弹夹是否为满子弹 是否有备弹
	if(!is_state_fire() ||  is_ammo_max() || !could_reload()):
		return false;
		
	if(!need_reload()):
		var left_ammo = Global.m_shot_ammo.m_ammo_left;
		Global.m_shot_ammo.m_ammo_left = 0;
		Global.m_shot_ammo.m_ammo_right += left_ammo;
		
	var survivor = get_parent().get_parent();
	var type_str = survivor.m_anim_type[m_weapon];
	type_str += survivor.m_anim_motion[Global.AnimMotion.reload];
	
	play_sound(reload_stream)
	survivor_play(type_str);
	return true;
	
# 持有者 换弹动画结束执行操作函数
func reload_finished():
	var max_ammo = Global.m_shot_ammo.m_ammo_max;
	var right_ammo = Global.m_shot_ammo.m_ammo_right;
	var ammo_count = 0.0;
	
	ammo_count = clamp(right_ammo,1,max_ammo);
	
	Global.m_shot_ammo.m_ammo_right -= ammo_count;
	Global.m_shot_ammo.m_ammo_left = ammo_count;

# 捡起子弹物品
func on_pickup_ammo(item_type,unlock):
	var max_ammo = null;
	var auto_type = Global.ItemsType.AUTOSHOT;
	var hand_type = Global.ItemsType.HANDSHOT;
	var current_type = null;
	
	match (item_type):
		auto_type:
			current_type = Global.WeaponType.AUTOSHOT;
			max_ammo = Global.m_auto_ammo_class.m_ammo_max;
			Global.m_auto_ammo_class.m_ammo_right += max_ammo * 2;
		hand_type:
			current_type = Global.WeaponType.HANDSHOT;
			max_ammo = Global.m_hand_ammo_class.m_ammo_max;
			Global.m_hand_ammo_class.m_ammo_right += max_ammo * 2;
			
	if(current_type != null):
		if(unlock):
				m_unlock_list[current_type] = true;
	$PickItem.play();
	return true;
		
# 切换当前武器到指定武器
func change_type(type):
	if(!is_state_fire()):
		return type;
		
	var max_type = Global.WeaponType.AUTOSHOT;
	while true:
		if(type > max_type):
			m_weapon = Global.WeaponType.FLUSHLIGHT;
			type = m_weapon;
			break;
		elif(m_unlock_list[type] == true):
			m_weapon = type;
			break;
			
		type += 1;
		
	Global.change_weapon(type);
	$ChagneWeapon.play();
	return type;
	
# 手电筒开火执行函数
func on_flush_light():
	m_open_fire = false;
	return;

# 发射子弹执行函数
func on_bullet_fire(anim_name):
	if(need_reload()):
		on_guns_reload();
		return;
		
	var main_scene = get_tree().root.get_node("Main");
	var bullet = BulletClass.instance();
	var rot_offset = rand_range(abs(Global.m_shot_offset),-abs(Global.m_shot_offset));
	var rot = get_parent().rotation + rot_offset;
	var dir = self.global_position;
	
	bullet.create_bullet(rot,dir,Global.m_shot_damage);
	main_scene.add_child(bullet);
	
	Global.m_shot_ammo.m_ammo_left -= 1;
	survivor_play(anim_name);
	if("auto" in anim_name):
		play_sound(auto_shot_stream);
	elif("hand" in anim_name):
		play_sound(hand_shot_stream);
	
	m_shot_cd = true;
	yield (get_tree().create_timer(Global.m_shot_cd),"timeout");
	m_shot_cd = false;

func play_sound(sound):
	$WeaponAudio.stream = sound;
	$WeaponAudio.play();
