class_name HollowTheme
extends RefCounted
## Graveyard Hollow's look for the shared theme. Headings and buttons keep the
## shared add-on's Kenney fonts; running text (the tutorial, role cards, chat,
## tips, chores, the map) uses Montserrat, which has lower case and reads far
## better in long lines than the all-capitals Kenney fonts.

const TEXT_FONT := "res://assets/fonts/Montserrat-SemiBold.ttf"

static var text_font: Font


static func apply(root: Window, base_size := 22) -> Theme:
	var t := build(base_size)
	root.theme = t
	# As in LGTheme.apply: merging into the default theme reaches menus under
	# a CanvasLayer or a 3D scene too.
	ThemeDB.get_default_theme().merge_with(t)
	ThemeDB.get_default_theme().default_font = t.default_font
	ThemeDB.get_default_theme().default_font_size = t.default_font_size
	return t


static func build(base_size := 22) -> Theme:
	var t := LGTheme.build(base_size)
	if text_font == null:
		text_font = load(TEXT_FONT)
	t.default_font = text_font
	return t
