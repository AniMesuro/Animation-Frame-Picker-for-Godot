tool
extends TextureButton

var frame_id :int= 0
#export var frame :StreamTexture= load("res://icon.png") setget _set_frame

var backgroundRect :ColorRect
func _ready() -> void:
	backgroundRect = $BackgroundRect
	connect( "mouse_entered", self, "_on_mouse_entered")
	connect( "mouse_exited", self, "_on_mouse_exited")
	connect("pressed", self, "_on_pressed")

func _on_pressed():
	if !is_instance_valid(owner):
		owner = get_parent().owner
	owner.emit_signal("frame_selected", frame_id)

func _on_mouse_entered():
	modulate = Color(.7,.7,1)
	
	
func _on_mouse_exited():
	modulate = Color.white



