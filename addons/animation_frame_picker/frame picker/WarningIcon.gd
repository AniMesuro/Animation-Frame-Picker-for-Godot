tool
extends TextureRect

var framePicker :Control


var WarningText :Dictionary= {
	'': "",
	'lacking_nodes': "Required nodes for Animation not present in current tree. Please instance required nodes.",
	'cant_frame': "Could not add keyframe because FramePicker lacks parameters.",
	'animplayeredit_empty': "Could not add keyframe because Animation is not selected on AnimationPlayerEditor.",
	'animsprite_empty': "AnimatedSprite lacks a SpriteFrames resource.",
	'edited_scene_invalid': "Current Edited Scene is Invalid."
}
var current_warning :String= ''

# Maybe toolhint should display all warning data instead of just current_warning?
var warning_data :PoolStringArray= PoolStringArray([])

func _enter_tree() -> void:
	framePicker = owner
	visible = false
	
	if !framePicker.is_connected("warning_issued", self, "_on_warning_issued"):
		framePicker.connect("warning_issued", self, "_on_warning_issued")
	if !framePicker.is_connected("warning_fixed", self, "_on_warning_fixed"):
		framePicker.connect("warning_fixed", self, "_on_warning_fixed")

# Warning added to the warning_data
func _on_warning_issued(warning_key :String):
	if !warning_key in WarningText:
		print('This warning is Invalid.')
	visible = true
	hint_tooltip = WarningText[warning_key]
	current_warning = warning_key
	if !(warning_key in warning_data):
		warning_data.append(warning_key)

# If a warning is on the warning_data, it will be removed
func _on_warning_fixed(warning_key :String):
	# Multiple warning system: If a warning is fixed, it finds the next
	if (warning_key in warning_data):
		visible = false
		hint_tooltip = WarningText['']
			
		
		for i in warning_data.size():
			if warning_data[i] == warning_key:
				warning_data.remove(i)
				break
		
		if warning_data.size() > 0:
			owner.issue_warning(warning_data[-1])
