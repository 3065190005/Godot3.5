extends Area2D

export var rotation_time = 0.002; # 物品旋转动画度数

var AutoGunsTexture = preload("res://Resources/Spine/rifle.png");	# 步枪贴图
var HandGunsTexutre = preload("res://Resources/Spine/pistol.png");	# 手枪贴图

export(int,"hand","auto") var m_item_type; # 物品当前类型

# 初始化
func _ready():
	match (m_item_type):
		Global.ItemsType.AUTOSHOT:
			$Sprite.texture = AutoGunsTexture;
			$Sprite.scale = Vector2(0.8,0.8);
		Global.ItemsType.HANDSHOT:
			$Sprite.texture = HandGunsTexutre;
			$Sprite.scale = Vector2(1.4,1.4);
	
# 更新转圈动画
func _process(_delta):
	self.rotation += rotation_time;

# 当幸存者进入拾取范围
func _on_Items_area_entered(area):
	var survivor = area.get_parent();
	survivor._on_Item_Pick_Up(m_item_type);
	queue_free();
