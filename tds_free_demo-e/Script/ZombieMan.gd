extends KinematicBody2D

export var m_heath = 100; # 僵尸血量
export var m_hit_back = 300; # 僵尸被击退距离
export var m_min_back_limit = 150; # 僵尸击退最新速度
export var m_damage = 5;		# 僵尸攻击力
export var m_speed = 100;		# 僵尸移动速度
export var m_attack_cd = 2; 	# 僵尸攻击cd/秒


var m_direct = Vector2.RIGHT; 	# 当前僵尸移动方向
var m_back_vec = Vector2.ZERO; 	# 当前僵尸击退值
var m_velocity = Vector2.ZERO;  # 当前僵尸移动值

var m_attack_target = null;
var m_can_attack = true;

var m_audio_attack = preload("res://Resources/Sound/zombie_attack.mp3");
var m_audio_dead = preload("res://Resources/Sound/zombie_dead.mp3");
var m_audio_move = preload("res://Resources/Sound/zombie_move.mp3");
var m_audio_spawn = preload("res://Resources/Sound/zombie_spawn.mp3");

func _ready():
	# 随机速度 随机血量
	var speed_inface = rand_range(m_speed,m_speed + m_speed * (Global.m_zombie_speed / 20));
	speed_inface = clamp(speed_inface,m_speed , m_speed * 5);
	
	var heath_inface = rand_range(m_heath,m_heath + m_heath * Global.m_zombie_speed  / 10);
	heath_inface = clamp(heath_inface,m_heath , m_heath * 2);
	
	var speed_color = m_speed / speed_inface;
	var heath_color = (heath_inface - m_heath) / 100;
	
	# 通过颜色区分僵尸速度和血量
	$Sprite.self_modulate = Color(speed_color,1 - heath_color,1,1);
	$Sprite.play("default");
	$ZombieAudio.stream = m_audio_spawn;
	$ZombieAudio.play();
	
	m_speed = speed_inface;
	m_heath = heath_inface;
	
# 物理帧更新
func _physics_process(_delta):
	if(m_heath <= 0):
		return;
		
	var velocity = Vector2.ZERO;
	velocity = on_move(_delta);
	velocity = move_and_slide(velocity);
		

# 移动更新 帧更新
func on_move(_delta):
	m_velocity = Vector2.ZERO;
	if(on_attack()):
		return m_velocity;
		
	if(!on_hit_back(_delta)):
		m_velocity = Ai_Motion(_delta);
		if(m_velocity != Vector2.ZERO && $Sprite.animation != "move"):
			$Sprite.play("move");
		elif(m_velocity == Vector2.ZERO && $Sprite.animation != "idle"):
			$Sprite.play("idle");
	
	if($ZombieAudio.stream == null):
		if($ZombieAudio/Timer.time_left <= 0):
			$ZombieAudio.stream = m_audio_move;
			$ZombieAudio.play();
			$ZombieAudio/Timer.start();
			
	return m_velocity;
		
# 击退位置 帧更新
func on_hit_back(_delta):
	if(m_back_vec == Vector2.ZERO):
		return false;
		
	var befor_global = self.global_position;	
	var colli = move_and_collide(m_back_vec * _delta);
	var after_global = self.global_position;
	
	m_back_vec -= after_global - befor_global;
	if(abs(m_back_vec.x) < m_min_back_limit && abs(m_back_vec.y) < m_min_back_limit):
		m_back_vec = Vector2.ZERO;
	if(colli != null):
		m_back_vec = Vector2.ZERO;
	return true;

# 攻击操作 帧更新
func on_attack():		
	if(m_back_vec != Vector2.ZERO):
		return false;
	
	if($Sprite.animation == "attack"):
		return true;
		
	if(m_attack_target == null):
		return false;
		
	if($Sprite.animation != "attack" && m_can_attack):
		$Sprite.play("attack");
		if($ZombieAudio.stream != m_audio_dead):
			$ZombieAudio.stream = m_audio_attack;
			$ZombieAudio.play();
		
	return true;

# 受伤回调
func on_hurt(damage):
	var main_scene = get_tree().root.get_node("Main");
	
	m_heath -= damage;
	main_scene.create_blood(global_position);
	if(m_heath <= 0):
		on_dead();
	else:
		$ammo_Audio.play();
	return;
# 击退回调
func on_hurt_with_kick(targ_vec):
	var self_vec = self.global_position;
	var sub_vec =  self_vec - targ_vec;
	m_back_vec = m_direct.rotated(sub_vec.angle());
	m_back_vec *= m_hit_back;
	$PunchAudio.play();
	
# 僵尸死亡回调
func on_dead():
	var main_scene = get_tree().root.get_node("Main");
	var self_color = $Sprite.self_modulate;
	var item_type = 1;
	
	item_type = Global.ItemsType.HANDSHOT;
	if(self_color.r < 0.5 && self_color.g < 0.5):
		item_type = Global.ItemsType.AUTOSHOT;
		
	main_scene.call_deferred("random_create_item",self.global_position,item_type);
	
	self.visible = false;
	$Sprite/HitArea/HitCollision.set_deferred("disabled",true);
	$HurtArea/HurtCollision.set_deferred("disabled",true);
	$BodyCollision.set_deferred("disabled",true);
	
	$ZombieAudio.stream = m_audio_dead;
	$ZombieAudio.play();
	
# 僵尸移动AI
func Ai_Motion(_delta):
	var survivor = get_parent().get_survivor();
	var surv_pos = survivor.global_position;
	var self_pos = global_position;
	var sub_pos =  surv_pos - self_pos;
	
	$Sprite.global_rotation = sub_pos.angle();
	
	var velocity = m_direct.rotated($Sprite.global_rotation) * m_speed;
	return velocity;
	
func attack_cd_zero():
	m_can_attack = true;

# 攻击判断区检测 - 进入
func _on_HitArea_area_entered(area):
	m_attack_target = area.get_parent();

# 攻击判断区检测 - 离开
func _on_HitArea_area_exited(_area):
	m_attack_target = null;

# 动画结束回调
func _on_Sprite_animation_finished():
	if($Sprite.animation == "attack"):
		if (m_attack_target != null):
			m_attack_target.on_hurt(m_damage);
		m_can_attack = false;
		var timer = get_tree().create_timer(m_attack_cd);
		timer.connect("timeout",self,"attack_cd_zero");
		
	if(m_velocity == Vector2.ZERO):
		$Sprite.play("idle");
	elif(m_velocity != Vector2.ZERO):
		$Sprite.play("move");

func _on_ZombieAudio_finished():
	if($ZombieAudio.stream == m_audio_dead):
		queue_free();
	$ZombieAudio.stream = null;
