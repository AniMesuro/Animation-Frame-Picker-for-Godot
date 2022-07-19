tool
extends Control

signal frame_selected (frame_id)
signal frame_applied (frame_id)
signal updated_reference (reference_name)
signal warning_issued (warning_key)
signal warning_fixed (warning_key)

var pluginInstance: EditorPlugin setget ,_get_pluginInstance

var anim_animSprite: AnimatedSprite setget _set_anim_animSprite
var anim_spriteFrames: SpriteFrames
var anim_animation: String setget _set_anim_animation
var anim_animPlayer: AnimationPlayer setget _set_anim_animPlayer
var anim: Animation

onready var framesContainer: GridContainer = $VBox/FramesHBox/ScrollContainer/FramesContainer

func _ready() -> void:
	add_to_group("plugin animation_frame_picker")
	pluginInstance = _get_pluginInstance()
	
	# If being edited.
	if get_tree().edited_scene_root == self:
		return
	var dock_group: String = "_plugindock frame picker"
	add_to_group(dock_group)
	
	connect("frame_selected", self, "_on_frame_selected")
	connect("frame_applied", self, "_on_frame_applied")
	pluginInstance.connect("scene_changed", self, "_on_scene_changed")
	if !is_instance_valid(get_tree().edited_scene_root):
		issue_warning('edited_scene_invalid')

func get_relevant_children() -> Array:
	var editedSceneRoot = get_tree().edited_scene_root
#	if !is_instance_valid(editedSceneRoot):
#		return []
#	var _edited_scene_nodes :Array= [editedSceneRoot]
	
	#For each child and its 5 children layers, reference itself to the edited_scene_tree Array
#	for child in editedSceneRoot.get_children():
#		edited_scene_tree.append(child)
#
#		for child_a in child.get_children():
#			edited_scene_tree.append(child_a)
#
#			for child_b in child_a.get_children():
#				edited_scene_tree.append(child_b)
#
#				for child_c in child_b.get_children():
#					edited_scene_tree.append(child_c)
#
#					for child_d in child_c.get_children():
#						edited_scene_tree.append(child_d)
#
#						for child_e in child_d.get_children():
#							edited_scene_tree.append(child_e)
	_select_children_as_array(editedSceneRoot, true, 300)
	return _edited_scene_nodes

var _edited_scene_nodes: Array = []
var _select_children_as_array_iter: int = 0
func _select_children_as_array(parent: Node, is_root: bool = false, max_iters: int = 0):
	if is_root:
		_edited_scene_nodes = []
		_select_children_as_array_iter = max_iters
	if !is_instance_valid(parent):
		return
	
	for child in parent.get_children():
		if _select_children_as_array_iter == 0:
			return
		_select_children_as_array_iter -=1
		
		_edited_scene_nodes.append(child)
		_select_children_as_array(child)

func _on_frame_selected(frame_id :int):
	if !is_instance_valid(pluginInstance):
		pluginInstance = _get_pluginInstance()
	if !is_instance_valid(anim_animPlayer):
		issue_warning('cant_frame')
		return
	if !is_instance_valid(anim_animSprite):
		issue_warning('cant_frame')
		return
	
	if !is_instance_valid(pluginInstance.animationPlayerEditor_CurrentAnimation_OptionButton):
		pluginInstance.get_references()
	
	var _anim: String = pluginInstance.animationPlayerEditor_CurrentAnimation_OptionButton.text
	if _anim in anim_animPlayer.get_animation_list():
		if _anim == '':
			issue_warning("animplayeredit_empty")
			return
		anim = anim_animPlayer.get_animation(_anim)
	else:
		issue_warning("animplayeredit_empty")
		return
	if !is_instance_valid(anim):
		issue_warning("animplayeredit_empty")
		return
	fix_warning("animplayeredit_empty")
	fix_warning('cant_frame')
	
	emit_signal("frame_applied", frame_id)
	
	var current_time :float= float(pluginInstance.animationPlayerEditor_CurrentTime_LineEdit.text)
	
	var animPlayer_root_node :Node= anim_animPlayer.get_node(anim_animPlayer.root_node)

	var tr_frame :int= anim.find_track(str(animPlayer_root_node.get_path_to(anim_animSprite))+':frame')
	var tr_anim :int= anim.find_track(str(animPlayer_root_node.get_path_to(anim_animSprite))+':animation')
	if tr_anim == -1:
		tr_anim = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(tr_anim, str(animPlayer_root_node.get_path_to(anim_animSprite))+':animation')
		anim.value_track_set_update_mode(tr_anim, Animation.UPDATE_DISCRETE)
	if tr_frame == -1:
		tr_frame = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(tr_frame, str(animPlayer_root_node.get_path_to(anim_animSprite))+':frame')
		anim.value_track_set_update_mode(tr_frame, Animation.UPDATE_DISCRETE)
	
	var key_anim_id :int= anim.track_find_key(tr_anim, current_time, false)
	var key_anim :String= ''
	if key_anim_id != -1:
		key_anim = anim.track_get_key_value(tr_anim, key_anim_id)
	
	# Gets next frame and keyframe next frame's animation
	var key_nextframe_id :int= anim.track_find_key(tr_frame, current_time) + 1
	var key_nextframe_time :float
	if key_nextframe_id < anim.track_get_key_count(tr_frame):
		key_nextframe_time = anim.track_get_key_time(tr_frame, key_nextframe_id)
		var key_nextframe_anim_id :int= anim.track_find_key(tr_anim, key_nextframe_time)
		
		var key_nextframe_anim :String= anim.track_get_key_value(tr_anim, key_nextframe_anim_id)
		if key_nextframe_anim != anim_animation:
			anim.track_insert_key(tr_anim, key_nextframe_time, key_nextframe_anim)
	
	
	if key_anim == '':
		anim.track_insert_key(tr_anim, 0.0, anim_animation)
	elif key_anim != anim_animation:
		anim.track_insert_key(tr_anim, current_time, anim_animation)
		
	anim.track_insert_key(tr_frame, current_time, frame_id)

func _on_frame_applied(frame_id: int):
	if !is_instance_valid(anim_animSprite):
		return
	anim_animSprite.animation = anim_animation
	anim_animSprite.frame = frame_id

func _on_scene_changed(scene_root :Node):
	if !is_inside_tree():
		yield(self, "tree_entered")
	
	# Reset all references
	anim_animPlayer = null
	anim_animSprite = null
	anim_animation = ""
	anim_spriteFrames = null
	anim = null
	emit_signal("updated_reference", "anim_animPlayer")
	emit_signal("updated_reference", "anim_animSprite")
	
	
	var editedscene_child :Array= get_relevant_children()
	
	var _has_animsprite :bool=false
	var _has_animplayer :bool=false
	for node in editedscene_child:
		if node.get_class() == 'AnimatedSprite':
			_has_animsprite = true
		elif node.get_class() == 'AnimationPlayer':
			_has_animplayer = true
	
	if !_has_animplayer or !_has_animsprite:
		issue_warning("lacking_nodes")
	else:
		fix_warning("lacking_nodes")

var last_animSprite: AnimatedSprite
func _set_anim_animSprite(new_animSprite :AnimatedSprite):
	last_animSprite = anim_animSprite
	if last_animSprite == new_animSprite:
		return
	
	
	if is_instance_valid(last_animSprite):
		if is_instance_valid(last_animSprite.frames):
			if last_animSprite.frames.is_connected("changed", self, "_on_anim_spriteFrames_changed"):
				last_animSprite.frames.disconnect("changed", self, "_on_anim_spriteFrames_changed")

	if is_instance_valid(new_animSprite):
		if is_instance_valid(new_animSprite.frames):
			if !new_animSprite.frames.is_connected("changed", self, "_on_anim_spriteFrames_changed"):
				new_animSprite.frames.connect("changed", self, "_on_anim_spriteFrames_changed")
	
	anim_animSprite = new_animSprite


func _set_anim_animation(new_animation :String):
	var last_animation = anim_animation
	if anim_animation == new_animation:
		return
	
	anim_animation = new_animation
	if !is_instance_valid(anim_animSprite):
		return
	if !is_instance_valid(anim_animSprite.frames):
		return
	
	if !anim_animSprite.frames.is_connected("changed", self, "_on_anim_spriteFrames_changed"):
		anim_animSprite.frames.connect("changed", self, "_on_anim_spriteFrames_changed")

func force_deselect_animPlayer():
	anim_animPlayer = null
	var animPlayerButton: Button = $"VBox/AnimPlayerHBox/Button"
	animPlayerButton.is_forced_animationPlayer = false
	emit_signal("updated_reference", "anim_animPlayer")

func force_select_animPlayer(new_anim_animPlayer: AnimationPlayer, animPlayer_name: String, animPlayer_icon: StreamTexture = null):
	anim_animPlayer = new_anim_animPlayer
	var animPlayerButton: Button = $"VBox/AnimPlayerHBox/Button"
	animPlayerButton.text = animPlayer_name
	animPlayerButton.hint_tooltip = animPlayer_name
	animPlayerButton.is_forced_animationPlayer = true
	if is_instance_valid(animPlayer_icon):
		animPlayerButton.icon = animPlayer_icon
	

func _set_anim_animPlayer(new_anim_animPlayer: AnimationPlayer):
	anim_animPlayer = new_anim_animPlayer
	
	var editorInterface: EditorInterface = self.pluginInstance.get_editor_interface()
	var editorSelection: EditorSelection = editorInterface.get_selection()
	editorSelection.clear()
	editorSelection.add_node(new_anim_animPlayer)

func _on_anim_spriteFrames_changed():
	if !is_instance_valid(anim_animSprite):
		return
	if !is_instance_valid(anim_animSprite.frames):
		return
	
	# Update FrameContainer
	$VBox/AnimHBox/Button.fill_frames()


func _get_pluginInstance() -> EditorPlugin:
	for node in get_tree().get_nodes_in_group("plugin animation_frame_picker"):
		if node is EditorPlugin:
			return node
	return null

func issue_warning(warning_key :String):
	emit_signal("warning_issued", warning_key)

func fix_warning(warning_key :String):
	emit_signal("warning_fixed", warning_key)
	
