extends KinematicBody2D

var g_state = global_define.m_anim_state
var g_motion = global_define.m_anim_motion

onready var sprite = get_node("Sprite")
onready var collision = get_node("bodyCollision")
onready var anim = get_node("AnimationPlayer")
onready var hurt_texture = preload("res://Resources/enemy/Skeleton_Hit_1.png");

onready var hurtBox = get_node("Sprite/hurtBox")
onready var hurtCollision = get_node("Sprite/hurtBox/hurtCollision")

var run_speed := 350		 # move speed
var jump_speed := -1000		 # jump height
var gravity := 4000			 # heaven gravity
var velocity := Vector2.ZERO # direct motion

var heath = 100				 # npc heath point

func _ready():
	global_define.m_enemy_count = global_define.m_enemy_count + 1;
	set_anim(g_state.idle)
	anim.connect("animation_finished",self,"on_animation_finished_callback")
	hurtBox.connect("area_entered",self,"on_collision_hurt_callback")

func enemy_move(delta):
	velocity.y += gravity * delta
	if velocity.x > 0:
		sprite.scale.x = 1;
	elif velocity.x < 0:
		sprite.scale.x = -1;
	velocity = move_and_slide(velocity, Vector2(0, -1))

func _physics_process(delta):
	if(heath != 0):
		enemy_move(delta)

func set_anim(name):
	name = g_motion[name];
	if(name == ""):
		return
	anim.play(name)
	
func on_dead():
	# heath bar visible false
	$HeathBar.visible = false;
	$HeathBar_bg.visible = false;
	
	hurtCollision.set_deferred("disabled",false);
	global_define.m_enemy_count = global_define.m_enemy_count - 1;
	
func on_hurt(attack):
	if(anim.current_animation == g_motion[g_state.dead]):
		return null;
		
	heath -= attack;
	heath = clamp(heath,0,abs(heath));	

	$HurtAudio.play();
	$Sprite.texture = hurt_texture;
	
	# heath bar
	var time = heath / 100.0;
	var heathbar = $HeathBar.scale;
	var heathbarbg = $HeathBar_bg.scale;
	
	heathbar.x *= time;
	heathbarbg.x *= time;
	
	$HeathBar.scale = heathbar;
	$HeathBar_bg.scale = heathbarbg;
	
	if(heath <= 0):
		on_dead();
		set_anim(g_state.dead);
		return false;
	else:
		set_anim(g_state.hurt);
		return true
		
func on_collision_hurt_callback(_attcker):	
	if(anim.current_animation == g_motion[g_state.dead]):
		return;
		
	# 获取攻击者和受击者全局坐标
	var att_par = _attcker.get_parent();
	var targPos = att_par.global_position;
	var selfPos = sprite.global_position;
	
	# 受击重置面朝方向
	if(targPos.x > selfPos.x):
		sprite.scale.x = 1;
	else:
		sprite.scale.x = -1;
	
func on_animation_finished_callback(name):
	if(name == g_motion[g_state.hurt]):
		set_anim(g_state.idle)
	if(name == g_motion[g_state.dead]):
		queue_free();
