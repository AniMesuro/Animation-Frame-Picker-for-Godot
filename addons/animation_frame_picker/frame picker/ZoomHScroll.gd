tool
extends HSlider


var framesContainer :GridContainer
var scrollContainer :ScrollContainer
func _ready() -> void:
	get_parent().get_node("ZoomIcon").texture = get_icon('Zoom', "EditorIcons")
	
	connect("value_changed", self, "_on_value_changed")
	framesContainer = owner.get_node("VBox/FramesHBox/ScrollContainer/FramesContainer")
	scrollContainer = owner.get_node("VBox/FramesHBox/ScrollContainer/")
	
	scrollContainer.connect("resized", self, "_on_ScrollContainer_resized")
	_update_frame_sizes()
	owner.get_node("VBox/AnimHBox/Button").connect('frames_filled', self, '_update_frame_sizes')

func _on_ScrollContainer_resized():
	if get_tree().edited_scene_root == owner:
		return
	_update_frame_sizes()

func _on_value_changed(value :float):
	_update_frame_sizes()
	
	

func _update_frame_sizes():
#	framesContainer = owner.framesContainer
#	scrollContainer = framesContainer.get_parent()
	if !is_instance_valid(framesContainer):
		framesContainer = owner.get_node("VBox/FramesHBox/ScrollContainer/FramesContainer")
	if !is_instance_valid(scrollContainer):
		scrollContainer = owner.get_node("VBox/FramesHBox/ScrollContainer/")
	
	var framesContainer_children :Array= framesContainer.get_children()
	if framesContainer_children == []:
		return
	
	for frame in framesContainer_children:
		var f :TextureButton= frame
		
		var zoomed_size :int= value * 8
		f.rect_min_size = Vector2(zoomed_size, zoomed_size)
		f.backgroundRect.rect_min_size = f.rect_min_size
	
	
#	Still glitches sometimes, but it's better than the previous one.
	var new_columns :int= floor(owner.rect_size.x / (framesContainer_children[0].rect_size.x + 2))
	if new_columns > 0:
		framesContainer.columns =  new_columns
