extends Area2D

var m_velocity = Vector2.RIGHT; # 移动方向
var m_distance := 0.0;   		# 子弹最大射程
var m_now_distance := 0.0;		# 子弹当前射程
var m_speed = 1000;				# 子弹飞行速度
var m_damage = 0;				# 子弹击中伤害
	
# 子弹移动更新
func _physics_process(_delta):
	self.global_position += m_velocity.rotated(rotation) * m_speed * _delta;
	m_now_distance += m_speed * _delta;
	if(m_now_distance >= m_distance):
		queue_free();

# 创建子弹回调 子弹朝向 子弹全局位置 子弹伤害
func create_bullet(direction, location,damage):
	self.rotation = direction;
	self.global_position = location;
	self.m_damage = damage;
	self.m_distance = Global.m_shot_distance;
	
	match (self.m_damage):
		Global.m_hand_damage:
			self.scale = Vector2(1,2);
		Global.m_auto_damage:
			self.scale = Vector2(1.2,4);

# 子弹碰到敌人
func _on_Area2D_area_entered(_area):
	var zombie = _area.get_parent();
	zombie.on_hurt(m_damage);
	queue_free();
