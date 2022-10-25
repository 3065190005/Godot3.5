extends KinematicBody2D

export var m_attack_damage = 20;

var global = global_define;
var g_state = global_define.m_anim_state
var g_motion = global_define.m_anim_motion

var ScreenShake = preload("res://ScriptFolder/ScreenShake.gd");

onready var sprite := get_node("Sprite")
onready var collision := get_node("bodyCollision")
onready var anim := get_node("AnimationPlayer")

onready var hitBox := get_node("Sprite/hitBox")
onready var hitCollision := get_node("Sprite/hitBox/hitCollision")

var run_speed := 300		 # move speed
var attack_push := 100		 # attack push speed
var jump_speed := -1000		 # jump height
var gravity := 4000			 # heaven gravity
var velocity := Vector2.ZERO # direct motion

var footstep_cd = 0.25;

var anim_name := ""	# animtion name

var is_attack = false;
var attack_state = 1;

func connectCallback():
	anim.connect("animation_finished",self,"on_animation_finished_callback")
	hitBox.connect("area_entered",self,"on_hitCollision_enter_callback")
	
# play player footstep when player in move
func player_foot_step():
	# footstep play
	if velocity.x != 0 and is_on_floor() and !is_attack :
		if($FootStep/FootStepTimer.time_left <= 0):
			$FootStep.pitch_scale = rand_range(0.8,1.2);
			$FootStep.play();
			$FootStep/FootStepTimer.start(footstep_cd);
	
func player_attack():
	if(is_attack):
		if sprite.scale.x == 1:
			velocity.x = attack_push
		elif sprite.scale.x == -1:
			velocity.x = -attack_push

		if hitCollision.disabled:
			velocity = move_and_slide(velocity,Vector2(0,-1))
		return
			
	var attack = Input.is_action_pressed("ui_attack")
	if attack and is_on_floor():
		attack_state += 1;
		if (attack_state == 4):
			attack_state = 1;
		
		var state = g_state.none;
		if(attack_state == 1):
			state = g_state.attack;
		elif(attack_state == 2):
			state = g_state.attack1;
		elif(attack_state == 3):
			state = g_state.attack2;
		
		set_anim(state,false)
		is_attack = true	
# player move
func player_move(): # only move when not attack
	if is_attack:
		return
	
	attack_state = 0;
	velocity.x = 0
	var right = Input.is_action_pressed('ui_right')
	var left = Input.is_action_pressed('ui_left')
	var jump = Input.is_action_pressed("ui_up")
	
	jump = false;
	
	var speed = 0;
	if is_on_floor() and jump:
		velocity.y = jump_speed
	elif right:
		speed = run_speed;
		sprite.scale.x = 1
		set_anim(g_state.walk,false)
	elif left:
		speed = -run_speed;
		sprite.scale.x = -1
		set_anim(g_state.walk,false)
	else:
		set_anim(g_state.idle,false)
		
	velocity.x += speed;
	velocity = move_and_slide(velocity,Vector2(0,-1));
		
func get_input():
	player_attack();
	player_move();
	player_foot_step();
		
func set_anim(name,change:bool):
	name = g_motion[name];
	if(name == ""):
		return
	elif anim_name != name or change:
		anim.play(name)
		anim_name = name

func _ready():
	connectCallback()
	set_anim(g_state.idle,false)
	
func _physics_process(delta):
	velocity.y += gravity * delta
	get_input()
	
func on_animation_finished_callback(name):
	is_attack = false;
	set_anim(g_state.idle,false)
	
func on_hitCollision_enter_callback(_hurter):
	# anyting for attack is success
	var hurter_sprite = _hurter.get_parent();
	var hurter_kinematic = hurter_sprite.get_parent();
	var isHurt = hurter_kinematic.on_hurt(m_attack_damage);
	
	if isHurt == null:
		return;
		
	var stop_time = 0;
	if(isHurt == true):
		if(attack_state == 1):
			stop_time = 0.1;
		elif(attack_state == 2):
			stop_time = 0.1;
		elif(attack_state == 3):
			stop_time = 0.2;
	else:
		stop_time = 0.6;
		
	global.get_tree().set_pause(true);

	var shakeNode = global.m_root.get_node("Main//Camera2D//ScreenShake");
	shakeNode.start(stop_time,30,6,0);
	yield (get_tree().create_timer(stop_time),"timeout");
	
	global.get_tree().set_pause(false);
