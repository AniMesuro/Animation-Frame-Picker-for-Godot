tool
extends "res://addons/animation_frame_picker/interface/NodeMenu.gd"

var is_forced_animationPlayer: bool = false

func _on_FramePicker_updated_reference(reference):
	if !is_instance_valid(owner.get(owner_reference)):
		text = msg_no_selection
		icon = TEX_IconExpand
		owner.fix_warning('lacking_nodes')
	elif owner.get(owner_reference).owner != get_tree().edited_scene_root:
		if (owner.get(owner_reference) == get_tree().edited_scene_root
		or is_forced_animationPlayer):
			return
		text = msg_no_selection
		icon = TEX_IconExpand
		owner.fix_warning('lacking_nodes')
	else:
		owner.fix_warning("animsprite_empty")
		owner.fix_warning('lacking_nodes')
