class_name HollowTheme
extends RefCounted
## Graveyard Hollow's look for the shared theme. Everything keeps the shared
## add-on's Kenney fonts except text that wraps over several lines (the
## tutorial, role cards, tips, chat, the chore list), which uses Montserrat: it
## has lower case and reads far better in long lines than the all-capitals
## Kenney fonts.

const TEXT_FONT := "res://assets/fonts/Montserrat-SemiBold.ttf"

static var text_font: Font


## Applies the shared theme to `root` and gives every label that wraps the
## reading font as it joins the tree.
static func apply(root: Window, base_size := 22) -> Theme:
	var t := LGTheme.apply(root, base_size)
	if text_font == null:
		text_font = load(TEXT_FONT)
	var tree := root.get_tree()
	if not tree.node_added.is_connected(_on_node_added):
		tree.node_added.connect(_on_node_added)
	return t


static func _on_node_added(node: Node) -> void:
	# Deferred, since screens often turn wrapping on after adding a label.
	if node is Label:
		use_text_font.call_deferred(node)


## Gives `label` the reading font when it wraps and would otherwise use the
## body font; headings and labels with a font of their own keep theirs.
static func use_text_font(label: Label) -> void:
	if not is_instance_valid(label) or label.autowrap_mode == TextServer.AUTOWRAP_OFF:
		return
	if label.has_theme_font_override("font") or label.get_theme_font("font") != LGTheme.body_font:
		return
	label.add_theme_font_override("font", text_font)
