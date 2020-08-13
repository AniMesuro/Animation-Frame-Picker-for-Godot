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

var SCN_FramePicker :PackedScene= load("res://addons/animation_frame_picker/frame picker/FramePicker.tscn")

# Editor
var animationPlayerEditor :Node
var animationPlayerEditor_CurrentTime_LineEdit :LineEdit
var animationPlayerEditor_CurrentAnimation_OptionButton :OptionButton

var framePicker :Control
func _enter_tree() -> void:
	add_to_group(group_plugin)
	
	_get_references()
	var editor :EditorInterface= get_editor_interface()
	
	if is_instance_valid(framePicker):
		remove_control_from_docks(framePicker)
#		framePicker.queue_free()
	framePicker = SCN_FramePicker.instance()
	add_control_to_dock(DOCK_SLOT_LEFT_UR, framePicker)
#	editor.add

func _exit_tree() -> void:
	
	if is_instance_valid(framePicker):
		remove_control_from_docks(framePicker)
#		framePicker.queue_free()

func _get_references():
	# AnimationPlayerEditor
	for node in get_tree().get_nodes_in_group('_vp_unhandled_key_input1176'):
		if node.get_class() == 'AnimationPlayerEditor':
			animationPlayerEditor = node
			break
	if !is_instance_valid(animationPlayerEditor):
		print("[Animation Frame Picker] Couldn't get AnimationPlayerEditor reference")
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
	
#	print("AnimationPlayerEditor is ",animationPlayerEditor)
#	print("AnimationPlayerEditor CurrentTime LineEdit =", animationPlayerEditor_CurrentTime_LineEdit)
#	print("AnimationPlayerEditor CurrentAnimation OptionButton =",animationPlayerEditor_CurrentAnimation_OptionButton)
	
#	animationPlayerEditor_CurrentTime_LineEdit = animationPlayerEditor.get_node('@@5686/@@5697/@@5695')
#	print('rootcanvas133 ',get_tree().get_nodes_in_group('root_canvas133'))
#	animationPlayerEditor_CurrentAnimation_OptionButton = animationPlayerEditor.get_node('@@5686/@@5724')
	
#	print("animationPlayerEditor_CurrentAnimation_OptionButton id ",animationPlayerEditor_CurrentAnimation_OptionButton.get_instance_id())
	
