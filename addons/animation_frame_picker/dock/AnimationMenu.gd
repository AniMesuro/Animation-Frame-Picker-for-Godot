tool
extends MenuButton

signal frames_filled

const TEX_IconExpand :StreamTexture= preload("res://addons/animation_frame_picker/assets/icons/icon_expand.png")

const SCN_FramePreview :PackedScene= preload("res://addons/animation_frame_picker/interface/FramePreview.tscn")

var last_index :int= -1

export var msg_no_selection = ""
export var msg_no_animspr_selection = ""
export var owner_reference :String= 'anim_'
#export var node_type :String= 'Node'

var editedSceneRoot :Node

var framesContainer :GridContainer
var popup :PopupMenu

func _ready() -> void:
	popup = get_popup()
	connect('pressed', self, '_on_Button_pressed')
	popup.connect('id_pressed', self, '_on_PopupMenu_item_selected')#, [button.selected])
	owner.connect('updated_reference', self, '_on_FramePicker_updated_reference')
	text = msg_no_animspr_selection

func _enter_tree() -> void:
	framesContainer = owner.get_node("VBox/FramesHBox/ScrollContainer/FramesContainer")
	


func _on_Button_pressed() -> void:
	editedSceneRoot = get_tree().edited_scene_root
	if !is_instance_valid(editedSceneRoot):
		return
#	var edited_scene_child = owner.get_relevant_children()
	
	popup = get_popup()
	popup.clear()
	var animSprite :AnimatedSprite= owner.anim_animSprite
	if !is_instance_valid(animSprite):
		text = msg_no_animspr_selection
		hint_tooltip = text
		popup.clear()
		return
	var spriteFrames :SpriteFrames= animSprite.frames
	if !is_instance_valid(spriteFrames):
		text = "Null SpriteFrames"
		hint_tooltip = text
		owner.issue_warning("animsprite_empty")
		return
	text = msg_no_selection
	hint_tooltip = text
	var anim_names :PoolStringArray= spriteFrames.get_animation_names()
	owner.fix_warning("animsprite_empty")
	
	# Empty Strings ("") should be Invalid.
	if '' in anim_names:
		for i in anim_names.size():
			if anim_names[i] == '':
				anim_names.remove(i)
				break
	
	if anim_names.size() == 0:
		text = msg_no_selection
		return
	popup.clear()
	for anim_name in anim_names:
		popup.add_item(anim_name)
	


func _on_PopupMenu_item_selected(id :int):
	last_index = id
	var item_name :String= popup.get_item_text(id)
	text = item_name
	hint_tooltip = text
	
	if !is_instance_valid(owner.pluginInstance):
		owner.pluginInstance = owner._get_pluginInstance()
	icon = owner.pluginInstance.get_editor_interface().get_inspector().get_icon("Animation", "EditorIcons")
	owner.set(owner_reference, item_name)
	fill_frames()

func _on_FramePicker_updated_reference(reference):
	if !is_instance_valid(owner.anim_animSprite):
		text = msg_no_animspr_selection
		icon = TEX_IconExpand
		_clear_frames()
	else:
		if reference == 'anim_animSprite':
			if owner.last_animSprite != owner.anim_animSprite:
				_deselect_animation()
				_clear_frames()
		if !is_instance_valid(owner.anim_animSprite.frames):
			owner.issue_warning("animsprite_empty")
			_deselect_animation()
			_clear_frames()
		elif !owner.anim_animSprite.frames.has_animation(owner.anim_animation):
			owner.fix_warning("animsprite_empty")
			_deselect_animation()
			_clear_frames()

func _deselect_animation():
	owner.anim_animation = ""
	text = msg_no_selection
	icon = TEX_IconExpand

func fill_frames():	
	_clear_frames()
	
	var animSprite :AnimatedSprite= owner.anim_animSprite
	if !is_instance_valid(animSprite):
		return
	var spriteFrames :SpriteFrames= owner.anim_animSprite.frames
	var anim :String= owner.anim_animation
	if !is_instance_valid(spriteFrames):
		return
	if !spriteFrames.has_animation(anim):
		return
	
	for i in spriteFrames.get_frame_count(anim):
		var frame :StreamTexture= spriteFrames.get_frame(anim, i)
		
		#Instance frame and set it as  child of grid.
		var framePreview = SCN_FramePreview.instance()
		framesContainer.add_child(framePreview)
		framePreview.texture_normal = frame
		framePreview.frame_id = i
	emit_signal("frames_filled")

func _clear_frames():
	#Clear children
	if !is_instance_valid(framesContainer):
		framesContainer = owner.get_node("VBox/FramesHBox/ScrollContainer/FramesContainer")
	if framesContainer.get_child_count() > 0:
		for child in framesContainer.get_children():
			child.queue_free()
