tool
extends EditorPlugin

#-----------------------------------------------#
# Animation Frame Picker plugin by AniMesuro.	#
#-----------------------------------------------#
#
# GitHub repo:
# 	https://github.com/AniMesuro/Frame-Picker-for-Godot
# - Please send bug reports at:
# 	https://github.com/AniMesuro/Frame-Picker-for-Godot/issues

var group_plugin :String= "plugin animation_frame_picker"

const SCN_FramePicker: PackedScene = preload("res://addons/animation_frame_picker/dock/FramePicker.tscn")

var settings: Resource

# Editor References
var animationPlayerEditor :Node
var animationPlayerEditor_CurrentTime_LineEdit :LineEdit
var animationPlayerEditor_CurrentAnimation_OptionButton :OptionButton

var framePicker: Control
func _enter_tree() -> void:
	add_to_group(group_plugin)
	
	get_references()
	var editor: EditorInterface = get_editor_interface()
	
	for orphanDock in get_tree().get_nodes_in_group("_plugindock frame picker"):
		remove_control_from_docks(orphanDock)
	settings = load("res://addons/animation_frame_picker/settings.tres")
	settings.pluginInstance = self
	
	framePicker = SCN_FramePicker.instance()
	add_control_to_dock(DOCK_SLOT_LEFT_BR, framePicker)
	settings.dock = framePicker


func _exit_tree() -> void:
	for dock in get_tree().get_nodes_in_group("_plugindock frame picker"):
		remove_control_from_docks(dock)



func get_references():
	# Godot 3.4.3
	animationPlayerEditor = _select_from_child_ids(_get_editorVBox(), [1, 1, 1, 0, 0, 1, 0, 1])
	if !is_instance_valid(animationPlayerEditor):
		print("[Animation Frame Picker] Couldn't get Editor's AnimationPlayerEditor reference")
		return
	
	# Get HBoxContainer
	var _hBox :HBoxContainer
	for child in animationPlayerEditor.get_children():
		if child.get_class() == 'HBoxContainer':
			_hBox = child
			break
	if !is_instance_valid(_hBox):
		print("[Animation Frame Picker] Couldn't get AnimationPlayerEditor/HBoxContainer reference")
		return
	
	# Get SpinBox -- current_time
	var _spinBox :SpinBox
	for child in _hBox.get_children():
		if child.get_class() == 'SpinBox':
			_spinBox = child
			animationPlayerEditor_CurrentTime_LineEdit = _spinBox.get_line_edit()
			break
	if !is_instance_valid(_spinBox):
		print("[Animation Frame Picker] Couldn't get AnimationPlayerEditor/HBoxContainer/SpinBox reference")
		return
	
	# Get OptionButton -- current_animation
	for child in _hBox.get_children():
		if child.get_class() == 'OptionButton':
			animationPlayerEditor_CurrentAnimation_OptionButton = child
			break
	if !is_instance_valid(animationPlayerEditor_CurrentAnimation_OptionButton):
		print("[Animation Frame Picker] Couldn't get AnimationPlayerEditor/HBoxContainer/OptionButton reference")
		return
	
func _select_from_child_ids(current_node: Node, child_ids: PoolIntArray):
	var last_child: Node = current_node
	while child_ids.size() != 0:
		last_child = last_child.get_child(child_ids[0])
		child_ids.remove(0)
		if child_ids.size() == 0:
			return last_child
	return null

func _get_editorVBox():
	var _editorControl: Control = get_editor_interface().get_base_control()
	for child in _editorControl.get_children():
		if child.get_class() == 'VBoxContainer':
			return child
