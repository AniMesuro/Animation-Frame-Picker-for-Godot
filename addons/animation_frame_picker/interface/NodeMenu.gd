tool
extends MenuButton

const TEX_IconExpand :StreamTexture= preload("res://addons/animation_frame_picker/assets/icons/icon_expand.png")

var last_index :int= -1

export var msg_no_selection = ""
export var owner_reference :String= 'anim_'
export var node_type :String= 'Node'

var editedSceneRoot

var popup :PopupMenu

func _ready() -> void:
	popup = get_popup()
	connect('pressed', self, '_on_Button_pressed')
	popup.connect('id_pressed', self, '_on_PopupMenu_item_selected')#, [button.selected])
	owner.connect('updated_reference', self, '_on_FramePicker_updated_reference')
	text = msg_no_selection

func _on_Button_pressed() -> void:
	editedSceneRoot = get_tree().edited_scene_root
	if !is_instance_valid(editedSceneRoot):
		owner.issue_warning("edited_scene_invalid")
		return
	if !is_instance_valid(popup):
		popup = get_popup()
	var edited_scene_child = owner.get_relevant_children()
	owner.fix_warning("edited_scene_invalid")

	popup.clear()
	for i in edited_scene_child.size():
		if (edited_scene_child[i].get_class() == node_type):
			if edited_scene_child[i] != editedSceneRoot:
				popup.add_item(editedSceneRoot.get_path_to(edited_scene_child[i]))
			else:
				# Representation of the path for getting itself (?)
				popup.add_item('./'+editedSceneRoot.name)
	if edited_scene_child.size() == 0:
		text = msg_no_selection
#	_validate_parameters()


func _on_PopupMenu_item_selected(id :int):
	last_index = id
	var item_name :String= popup.get_item_text(id)
	text = item_name
	hint_tooltip = text
	
	if !is_instance_valid(owner.pluginInstance):
		owner.pluginInstance = owner._get_pluginInstance()
	
	icon = owner.pluginInstance.get_editor_interface().get_inspector().get_icon(node_type, "EditorIcons")
	if item_name != './'+editedSceneRoot.name:
		owner.set(owner_reference, editedSceneRoot.get_node(item_name))
	else:
		owner.set(owner_reference, editedSceneRoot)
		
	owner.emit_signal("updated_reference", owner_reference)

func _on_FramePicker_updated_reference(reference):
	if !is_instance_valid(owner.get(owner_reference)):
		text = msg_no_selection
		icon = TEX_IconExpand
		owner.fix_warning('lacking_nodes')
	elif owner.get(owner_reference).owner != get_tree().edited_scene_root:
		if owner.get(owner_reference) == get_tree().edited_scene_root:
			return
		text = msg_no_selection
		icon = TEX_IconExpand
		owner.fix_warning('lacking_nodes')
	else:
		owner.fix_warning("animsprite_empty")
		owner.fix_warning('lacking_nodes')
		
func _validate_parameters():
	if !is_instance_valid(owner.get(owner_reference)):
		text = msg_no_selection
		icon = TEX_IconExpand
		
