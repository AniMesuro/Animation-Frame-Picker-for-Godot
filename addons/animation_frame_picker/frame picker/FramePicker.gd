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
#	if !is_inside_tree():
#		print('framepicker outside tree')
#		yield(self, "tree_entered")
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
#	print('pressed ',frame_id)
#	print(anim_animPlayer,anim_animSprite,anim_animation,anim_animSprite)
	
#	pluginInstance._get_references()
#	return
	
#	yield(get_tree(), "idle_frame")
#	if !is_inside_tree():
#		print('outside tree')
#	if !is_instance_valid(self):
#		print('self not valid')
	
	if !is_instance_valid(pluginInstance):
		pluginInstance = _get_pluginInstance()
#	print('animationplayereditor ',AnimationPlayerEditor)
	if !is_instance_valid(anim_animPlayer):
#		print('animplayer not valid')
		issue_warning('cant_frame')
		return
	if !is_instance_valid(anim_animSprite):
#		print('animsprite not valid')
		issue_warning('cant_frame')
		return
#	print("______animplayer path= ",anim_animPlayer.get_path())
	
#	var animationPlayerEditor :AnimationPlayerEditor= EditorNode
#	var animationPlayerEditor := get_tree().root.get_node('EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@4916/@@4917/@@6167')
#	var abc := get_tree().root.get_node('EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@4916/@@4917/@@6167/@@6166')
	
	############################################################
#	For now ignore it.
	# Kind of risky because user could use an instanced animationplayer.
#	if anim_animPlayer.owner != get_tree().edited_scene_root:
#		print('not edited scene')
#		return
		
#	pluginInstance._get_references()
#	print('animspr ',anim_animSprite)
#	print('_animANIMATIONLIST ==',anim_animPlayer.get_animation_list())
	var _anim :String= pluginInstance.animationPlayerEditor_CurrentAnimation_OptionButton.text
#	print('_anim ',_anim)
	if _anim in anim_animPlayer.get_animation_list():
		if _anim == '':
			issue_warning("animplayeredit_empty")
			return
		anim = anim_animPlayer.get_animation(_anim)
	else:
#		print('anim not valid')
		issue_warning("animplayeredit_empty")
		return
#	anim = anim_animPlayer.get_animation()
#	print("animation is ",anim)
	if !is_instance_valid(anim):
		issue_warning("animplayeredit_empty")
		print('animation not selected')
		return
	fix_warning("animplayeredit_empty")
	
	fix_warning('cant_frame')
#	var currentAnimation :Animation= pluginInstance.animationPlayerEditor_CurrentAnimation_OptionButton.text
	
	var current_time :float= float(pluginInstance.animationPlayerEditor_CurrentTime_LineEdit.text)
	
	var animPlayer_root_node :Node= anim_animPlayer.get_node(anim_animPlayer.root_node)
#	print('animplayer root node =',animPlayer_root_node)
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
#	print('root to sprite =',animPlayer_root_node.get_path_to(anim_animSprite))
	
	var key_anim_id :int= anim.track_find_key(tr_anim, current_time, false)
#	print('key_anim_id ',key_anim_id)
	var key_anim :String= ''
	if key_anim_id != -1:
		key_anim = anim.track_get_key_value(tr_anim, key_anim_id)
	
	# Gets next frame and keyframe next frame's animation
	var key_nextframe_id :int= anim.track_find_key(tr_frame, current_time) + 1
	var key_nextframe_time :float
	if key_nextframe_id < anim.track_get_key_count(tr_frame):
		key_nextframe_time = anim.track_get_key_time(tr_frame, key_nextframe_id)
		var key_nextframe_anim_id :int= anim.track_find_key(tr_anim, key_nextframe_time)
		
#		print("key_nextframe_anim_id ",key_nextframe_anim_id)
		var key_nextframe_anim :String= anim.track_get_key_value(tr_anim, key_nextframe_anim_id)
		if key_nextframe_anim != anim_animation:
			anim.track_insert_key(tr_anim, key_nextframe_time, key_nextframe_anim)
#	print('nextframe id:',key_nextframe_id,' time:',key_nextframe_time)
	
	
	if key_anim == '':
		anim.track_insert_key(tr_anim, 0.0, anim_animation)
	elif key_anim != anim_animation:
#		print('key anim =',key_anim)
		anim.track_insert_key(tr_anim, current_time, anim_animation)
		
#	print('____key_anim = ',key_anim)
#	print('inserting frame key')
	anim.track_insert_key(tr_frame, current_time, frame_id)
#	print(abc,' name= ',abc.name)
#	print(abc.get_groups())
#	print(animationPlayerEditor,' name= ',animationPlayerEditor.name)
#	print('animpledit groups =',animationPlayerEditor.get_groups())
	
#	print('in _vp_unhandled_key_input1176 : ',get_tree().get_nodes_in_group('_vp_unhandled_key_input1176'))
#	Animplayer group = GROUP
#	[_vp_unhandled_key_input1176]
	
#	print('animtreditplu path= ',AnimationTrackEditPlugin)
#	var animationPlayerEditor :Node= get_tree().root.get_node("EditorNode/@@592/@@593/@@601/@@603/@@607/@@611/@@612/@@613/@@4921/@@4922/@@6174")#pluginInstance.get_editor_interface().get_base_control().find_node("AnimationTrackEditor")
#	print('animplayereditor ',animationPlayerEditor,' ',animationPlayerEditor.get_class())
	
#	if animationPlayerEditor.visible:
#		print('animPlayerEditor visible')

#AnimationTrackEdit

func _on_scene_changed(scene_root :Node):
#	print('scene changed')
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
#	emit_signal("updated_reference", "anim_animSprite")
#	emit_signal("updated_reference", "anim_")
#	emit_signal("updated_reference", "anim_")
	
	
	var editedscene_child :Array= get_relevant_children()
	
	var _has_animsprite :bool=false
	var _has_animplayer :bool=false
	for node in editedscene_child:
		if node.get_class() == 'AnimatedSprite':
			_has_animsprite = true
		elif node.get_class() == 'AnimationPlayer':
			_has_animplayer = true
	
	if !_has_animplayer or !_has_animsprite:
#		emit_signal("warning_issued", "lacking_nodes")
		issue_warning("lacking_nodes")
	else:
		fix_warning("lacking_nodes")
#		emit_signal("warning_issued", '')


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
		# if resource_changed connected
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
#		var plugin_group :Array= get_tree().get_nodes_in_group("plugin animatedsprite_frame_picker")
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
	
