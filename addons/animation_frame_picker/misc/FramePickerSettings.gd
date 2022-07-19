tool
extends Resource

export var enable_addons_integration: bool = true
export var integrations: Dictionary = {
	'posepal': true
}

var pluginInstance: EditorPlugin
var dock: Control


func is_addon_active(addon_name: String):
	if (!enable_addons_integration or !integrations.get(addon_name, false)
	or  !is_instance_valid(pluginInstance)):
		return false
	if pluginInstance.get_tree().get_nodes_in_group("plugin "+addon_name).size()>0:
		return true

func get_plugin_instance_for(addon_name):
	if !enable_addons_integration or !integrations.get(addon_name, false):
		return null
	var _plugin_group: Array = pluginInstance.get_tree().get_nodes_in_group("plugin "+addon_name)
	for node in _plugin_group:
		if node is EditorPlugin:
			return node
	return null
