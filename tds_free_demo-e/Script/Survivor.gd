extends KinematicBody2D

var m_hurt_1_audio = preload("res://Resources/Sound/survive_hurt_1.mp3");
var m_hurt_2_audio = preload("res://Resources/Sound/survive_hurt_2.mp3");
var m_dead_audio = preload("res://Resources/Sound/survive_dead.mp3");

# 武器动画类型字符串
var m_anim_type = {
	Global.AnimType.flush:"flush_",
	Global.AnimType.handshot:"handshot_",
	Global.AnimType.autoshot:"autoshot_",
};

# 武器动画动作字符串
var m_anim_motion = {
	Global.AnimMotion.idle:"idle",
	Global.AnimMotion.move:"move",
	Global.AnimMotion.attack:"attack",
	Global.AnimMotion.reload:"reload",
	Global.AnimMotion.shoot:"shoot",
};

export var m_heath = 100;  # 血量
export var m_speed = 300;  # 移动速度
export(int,"flush","hand","auto") var m_weapon_type; # 当前角色武器

var m_velocity = Vector2.ZERO; # 移动值

# 初始化
func _ready():
	var anim_type = Global.AnimType.flush;
	set_animation(anim_type,Global.AnimMotion.idle,true);
	
	var type = m_weapon_type;
	m_weapon_type = $"Sprite/Weapon".change_type(type);
		
	anim_type = get_weapon_type();
	set_animation(anim_type,Global.AnimMotion.idle,true);

# 动画帧更新
func _process(_delta):
	# 重置手电筒位置
	if(get_weapon_type() != Global.WeaponType.FLUSHLIGHT):
		$Sprite/FlushLight.position = Vector2(75,24);
	else:
		$Sprite/FlushLight.position = Vector2(125,-30);
	on_weapon_reload(); # 武器换弹按键检测
	on_change_weapon(); # 更换武器按键检测
	sprite_rotate();	# 旋转角度跟随鼠标
	animation_update();	# 行走动画级功能更新
	on_fire();			# 开枪动画级功能更新
	on_attack();		# 攻击动画级功能更新
	
# 物体学刚体移动速度更新
func _physics_process(_delta):
	m_velocity = Vector2.ZERO;
	var motion = get_motion_value();
	
	m_velocity.x = motion.x * m_speed;
	m_velocity.y = motion.y * m_speed;
	m_velocity = move_and_slide(m_velocity,Vector2.UP);

# 武器换子弹检测 帧更新
func on_weapon_reload():
	if(Input.is_action_just_pressed("ui_weapon_reload")):
		$"Sprite/Weapon".on_guns_reload();

# 切换武器检测 帧更新
func on_change_weapon():
	var type = m_weapon_type + 1;
	if(Input.is_action_just_pressed("ui_weapon_change")):
		m_weapon_type = $"Sprite/Weapon".change_type(type)

# 行走/站立 帧更新
func animation_update():
	var anim_type = "";
	var anim_motion = "";
	
	anim_type = get_weapon_type();
	
	if(m_velocity == Vector2(0,0)):
		anim_motion = Global.AnimMotion.idle;
	else:
		anim_motion = Global.AnimMotion.move;
		
	if (is_idle_or_move()):
		set_animation(anim_type,anim_motion);
		
	var timer = $"footstep/Timer".time_left;
	if(anim_motion == Global.AnimMotion.move && timer <= 0):
		$footstep.pitch_scale = rand_range(0.8,1.2);
		$footstep.play();
		$footstep/Timer.start(0.3);

# 开火 帧更新
func on_fire():
	var weapon = $Sprite.get_node("Weapon");
	if (Input.is_action_just_pressed("ui_fire")): 
		weapon.on_fire(self.global_position,get_global_mouse_position());
	if(Input.is_action_just_released("ui_fire")):
		weapon.stop_fire();

# 攻击 帧更新
func on_attack():
	if(Input.is_action_just_pressed("ui_attack")):
		var type_str = m_anim_type[get_weapon_type()];
		var motion_str = m_anim_motion[Global.AnimMotion.attack];
		$AnimationPlayer.play(type_str + motion_str);
		$PunchAudio.play();

# 角色受伤
func on_hurt(damage):
	var audio = null;
	m_heath -= damage;
	$HeathEffect.start();
	if(m_heath <= 0):
		audio = m_dead_audio;
	else:
		var rand = rand_range(0,1);
		if(rand > 0.5):
			audio = m_hurt_1_audio;
		else:
			audio = m_hurt_2_audio;
	
	if(audio == m_dead_audio || $HurtAudio.playing == false):
		$HurtAudio.stream = audio;
		$HurtAudio.play();

# 角色朝向鼠标旋转 帧更新
func sprite_rotate():
	var mouse_pos = get_global_mouse_position();
	var self_pos = self.global_position;
	var sub_pos = mouse_pos - self_pos;
	var rota = sub_pos.angle();
	$Sprite.rotation = rota;

# 动画结束回调
func _on_Sprite_animation_finished():
	var anim_type = "";
	var anim_motion = "";
	var end_anim = $Sprite.animation;
	
	anim_type = get_weapon_type();

	if(m_velocity != Vector2(0,0)):
		anim_motion = Global.AnimMotion.move;
	else:
		anim_motion = Global.AnimMotion.idle;
	set_animation(anim_type,anim_motion,true);
	
	# 换弹结束动画回调
	var reload_str = m_anim_motion[Global.AnimMotion.reload];
	if(reload_str in end_anim):
		$"Sprite/Weapon".reload_finished();

# 攻击区域判断回调
func _on_HitArea_area_entered(area):
	var zombie = area.get_parent();
	zombie.on_hurt_with_kick(global_position);
	
# 呼吸回血
func _on_HeathEffect_timeout():
	if(m_heath > 0):
		m_heath += 10;
		m_heath = clamp(m_heath,0,100);
	
# 拾取物品回调
func _on_Item_Pick_Up(type):
	match type:
		Global.ItemsType.AUTOSHOT:
			$Sprite/Weapon.on_pickup_ammo(type,true);
		Global.ItemsType.HANDSHOT:
			$Sprite/Weapon.on_pickup_ammo(type,true);
	
# 设置当前播放动画 : 动画状态 动画动作 是否强制切换
func set_animation(type,motion,change = false):
	var anim =  m_anim_type[type] + m_anim_motion[motion];
	if($Sprite.animation != anim || change):
		$Sprite.play(anim);

# 获取移动方向
func get_motion_value():
	var vec2 = Vector2.ZERO;
	vec2.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left");
	vec2.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up");
	return vec2;

# 获取当前武器类型
func get_weapon_type():
	var anim_type = "";
	var weapon_node = $Sprite/Weapon;
	match weapon_node.m_weapon:
		Global.WeaponType.FLUSHLIGHT:
			anim_type = Global.AnimType.flush;
		Global.WeaponType.HANDSHOT:
			anim_type = Global.AnimType.handshot;
		Global.WeaponType.AUTOSHOT:
			anim_type = Global.AnimType.autoshot;
	return anim_type;

# 判断是否处于开火动画
func is_on_fire():
	var anim_type = "";
	anim_type = get_weapon_type();
	
	var shoot_anim = m_anim_type[anim_type] + m_anim_motion[Global.AnimMotion.shoot];
	var motion = $Sprite.animation;
	if(motion == shoot_anim):
		return true;
	return false;

# 判断是否处于停止/移动状态
func is_idle_or_move():
	var idle_anim = m_anim_motion[Global.AnimMotion.idle];
	var move_anim = m_anim_motion[Global.AnimMotion.move];
	var motion = $Sprite.animation;
	if(idle_anim in motion || move_anim in motion):
		return true;
	return false;
