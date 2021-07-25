extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
#	get_node("/root/").call_deferred("add_child", preload("res://menu/mini_map.tscn").instance())
	get_tree().change_scene("res://menu/main_menu.tscn")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
