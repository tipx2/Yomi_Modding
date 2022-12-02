extends VBoxContainer

export  var player_id = 1

signal style_selected(style)

var selected_style = null
var aura_particle = null

func _ready():
	$"%PlayerLabel".text = "P1" if player_id == 1 else "P2"
	$"%CharacterPortrait".flip_h = player_id != 1
	$"%LoadStyleButton".connect("style_selected", self, "_on_style_selected")

func _on_style_selected(style):
	emit_signal("style_selected", style)
	selected_style = style
	if style:
		Custom.apply_style_to_material(style, $"%CharacterPortrait".get_material())
		if style.show_aura:
			var particle = preload("res://fx/CustomTrailParticle.tscn").instance()
			$"%CharacterPortrait".add_child(particle)
			particle.load_settings(style.aura_settings)
			particle.position = $"%CharacterPortrait".rect_size / 2
			particle.scale.x = - 1 if player_id == 2 else 1
			pass
	else :
		var material = $"%CharacterPortrait".get_material()
		material.set_shader_param("color", Color.white)
		material.set_shader_param("use_outline", false)
		aura_particle.queue_free()
		aura_particle = null
			


func init():
	$"%CharacterLabel".text = ""

	set_enabled(true)
	$"%LoadStyleButton".update_styles()
	$"%LoadStyleButton".hide()
	if SteamYomi.STARTED and ( not Network.multiplayer_active or player_id == Network.player_id):
		$"%LoadStyleButton".show()

func load_character_data(data):
	$"%CharacterPortrait".texture = data["portrait"]
	$"%CharacterLabel".text = data["name"]

func set_enabled(on):
	for child in get_children():
		child.visible = on

