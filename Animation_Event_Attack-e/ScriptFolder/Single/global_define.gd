extends Node

enum m_anim_state {none,idle,walk,attack,attack1,attack2,hurt,dead}

var m_anim_motion = {
	m_anim_state.idle : "Idle",
	m_anim_state.walk : "Walk",
	m_anim_state.hurt : "Hurt",
	m_anim_state.dead : "Dead",
	m_anim_state.attack : "Attack",
	m_anim_state.attack1 : "Attack1",
	m_anim_state.attack2 : "Attack2",
}


var m_enemy_count = 0;

onready var m_root = get_tree().root;
