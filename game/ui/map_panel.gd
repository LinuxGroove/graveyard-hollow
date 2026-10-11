class_name MapPanel
extends Control
## A parchment map of the village: lanterns as you last saw them, the bell,
## your chores and you.

const LABEL_SIZE := 15

var game: Game
var _canvas: Control


func setup(p_game: Game) -> void:
	game = p_game
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.4)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var panel := PanelContainer.new()
	panel.theme_type_variation = "ParchmentPanel"
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(panel)
	var col := VBoxContainer.new()
	panel.add_child(col)
	var title := LGUi.label(game.village.map_name, "InkHeader")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(title)
	_canvas = Control.new()
	_canvas.custom_minimum_size = Vector2(600, 600)
	_canvas.draw.connect(_draw_map)
	col.add_child(_canvas)
	var note := LGUi.label("Lanterns show as you last saw them.", "InkLabel")
	note.add_theme_font_size_override("font_size", 17)
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	col.add_child(note)
	var hint := PanelContainer.new()
	hint.theme_type_variation = "GlassPanel"
	hint.add_child(ActionPrompt.make("show_map", "Close", 32))
	col.add_child(hint)


func open() -> void:
	visible = true
	_canvas.queue_redraw()


func close() -> void:
	visible = false


func _process(_delta: float) -> void:
	if visible:
		_canvas.queue_redraw()


func _to_map(p: Vector3) -> Vector2:
	var b: Rect2 = game.village.bounds
	return Vector2((p.x - b.position.x) / b.size.x, (p.z - b.position.y) / b.size.y) * _canvas.size


func _draw_map() -> void:
	var ink := LGTheme.INK
	var font := _canvas.get_theme_default_font()
	_canvas.draw_rect(Rect2(Vector2.ZERO, _canvas.size), Color(0.36, 0.5, 0.3, 0.35))
	for i in game.seen_lit.size():
		var p := _to_map(game.lantern_position(i))
		if game.seen_lit[i]:
			_canvas.draw_circle(p, 9, Color(1.0, 0.85, 0.35, 0.55))
			_canvas.draw_circle(p, 5, Color(1.0, 0.75, 0.2))
		else:
			_canvas.draw_circle(p, 5, Color(0.2, 0.2, 0.25))
	var bell := _to_map(game.village.bell_position())
	_canvas.draw_rect(Rect2(bell - Vector2(7, 7), Vector2(14, 14)), Color("b0782a"))
	# Names go over the lanterns but under your chores and you.
	var marks: Dictionary = game.village.landmark_positions()
	for n in marks:
		_draw_label(font, map_label(str(n)), _to_map(marks[n]), Color(ink, 0.8))
	var n := 1
	for c in game.available_chores():
		var sp: Vector3 = game.station_position(c.data.station)
		if sp == Vector3.INF:
			continue
		var p := _to_map(sp)
		_canvas.draw_circle(p, 11, Color("e8635a"))
		_canvas.draw_string(font, p + Vector2(-10, 6), str(n), HORIZONTAL_ALIGNMENT_CENTER, 20, 16, Color.WHITE)
		n += 1
	if game.player:
		var p := _to_map(game.player.global_position)
		var fwd := Vector2(sin(game.player.avatar.rotation.y), cos(game.player.avatar.rotation.y))
		_canvas.draw_colored_polygon(PackedVector2Array([p + fwd * 14, p + fwd.orthogonal() * 8 - fwd * 6, p - fwd.orthogonal() * 8 - fwd * 6]), Color("3b6fd8"))
		_canvas.draw_circle(p, 4, Color.WHITE)


## A landmark's name as the map writes it: "the graveyard gate" is "Graveyard Gate".
static func map_label(landmark: String) -> String:
	return landmark.trim_prefix("the ").capitalize()


## Writes `text` centred above `at`, whole, kept inside the map, on a
## parchment outline so it stays readable over the lantern dots.
func _draw_label(font: Font, text: String, at: Vector2, color: Color) -> void:
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE).x
	var x := clampf(at.x - w * 0.5, 4.0, _canvas.size.x - w - 4.0)
	var pos := Vector2(x, at.y - 15.0)
	_canvas.draw_string_outline(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, 4, Color(LGTheme.PARCHMENT, 0.85))
	_canvas.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, LABEL_SIZE, color)
