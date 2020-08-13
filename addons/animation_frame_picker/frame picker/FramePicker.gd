tool
extends Control

signal frame_selected (frame_id)
signal updated_reference (reference_name)
signal warning_issued (warning_key)
signal warning_fixed (warning_key)

var pluginInstance :EditorPlugin

var anim_animSprite :AnimatedSprite setget _set_anim_animSprite
var anim_spriteFrames :SpriteFrames
var anim_animation :String setget _set_anim_animation
var anim_animPlayer :AnimationPlayer
var anim :Animation

onready var framesContainer :GridContainer= $VBox/FramesHBox/ScrollContainer/FramesContainer

func _ready() -> void:
	pluginInstance = _get_pluginInstance()
	
	# If being edited.
	if get_tree().edited_scene_root == self:
		return
	
	connect("frame_selected", self, "_on_frame_selected")
	pluginInstance.connect("scene_changed", self, "_on_scene_changed")
	if !is_instance_valid(get_tree().edited_scene_root):
		issue_warning('edited_scene_invalid')


func get_relevant_children() -> Array:
	var editedSceneRoot = get_tree().edited_scene_root
	if !is_instance_valid(editedSceneRoot):
		return []
	var edited_scene_tree :Array= [editedSceneRoot]
	
	#For each child and its 5 children layers, reference itself to the edited_scene_tree Array
	for child in editedSceneRoot.get_children():
		edited_scene_tree.append(child)
		
		for child_a in child.get_children():
			edited_scene_tree.append(child_a)
			
			for child_b in child_a.get_children():
				edited_scene_tree.append(child_b)
				
				for child_c in child_b.get_children():
					edited_scene_tree.append(child_c)
					
					for child_d in child_c.get_children():
						edited_scene_tree.append(child_d)
						
						for child_e in child_d.get_children():
							edited_scene_tree.append(child_e)
	return edited_scene_tree

func _on_frame_selected(frame_id :int):
	if !is_instance_valid(pluginInstance):
		pluginInstance = _get_pluginInstance()
	if !is_instance_valid(anim_animPlayer):
		issue_warning('cant_frame')
		return
	if !is_instance_valid(anim_animSprite):
		issue_warning('cant_frame')
		return
	
	
	var _anim :String= pluginInstance.animationPlayerEditor_CurrentAnimation_OptionButton.text
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
	
	var current_time :float= float(pluginInstance.animationPlayerEditor_CurrentTime_LineEdit.text)
	
	var animPlayer_root_node :Node= anim_animPlayer.get_node(anim_animPlayer.root_node)

	var tr_frame :int= anim.find_track(str(animPlayer_root_node.get_path_to(anim_animSprite))+':frame')
	var tr_anim :int= anim.find_track(str(animPlayer_root_node.get_path_to(anim_animSprite))+':animation')
	if tr_frame == -1:
		tr_frame = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(tr_frame, str(animPlayer_root_node.get_path_to(anim_animSprite))+':frame')
		anim.value_track_set_update_mode(tr_frame, Animation.UPDATE_DISCRETE)
	if tr_anim == -1:
		tr_anim = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(tr_anim, str(animPlayer_root_node.get_path_to(anim_animSprite))+':animation')
		anim.value_track_set_update_mode(tr_anim, Animation.UPDATE_DISCRETE)
	
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


func _set_anim_animSprite(new_animSprite :AnimatedSprite):
	var last_animSprite :AnimatedSprite= anim_animSprite
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

func _on_anim_spriteFrames_changed():
	if !is_instance_valid(anim_animSprite):
		return
	if !is_instance_valid(anim_animSprite.frames):
		return
	
	# Update FrameContainer
	$VBox/AnimHBox/Button.fill_frames()


func _get_pluginInstance() -> EditorPlugin:
	if get_tree().has_group("plugin animation_frame_picker"):
		for node in get_tree().get_nodes_in_group("plugin animation_frame_picker"):
			if node is EditorPlugin:
				return node
	else:
		print("[Animation Frame Picker] plugin group not found")
	return null

func issue_warning(warning_key :String):
	emit_signal("warning_issued", warning_key)

func fix_warning(warning_key :String):
	emit_signal("warning_fixed", warning_key)
	
