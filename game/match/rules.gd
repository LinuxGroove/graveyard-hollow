class_name Rules
extends RefCounted
## Game rules: roles, actions, distances, timings, chores and house rules.

enum Role { LAMPLIGHTER, HOLLOW, SEER, WATCHMAN }
enum Team { VILLAGE, HOLLOW }
enum Phase { LOADING, NIGHT, MEETING, ENDED }
enum MeetingPhase { DISCUSS, VOTE, REVEAL }
enum Act { RELIGHT_START, RELIGHT_DONE, CHORE_START, CHORE_DONE, SNUFF, TAKE, REPORT, BELL, SEER, FLICKER, CANCEL }
enum Anim { IDLE, WALK, INTERACT, CARRY_IDLE, CARRY_WALK, EMOTE_YES, EMOTE_NO, SIT }

const ROLE_NAMES := {
	Role.LAMPLIGHTER: "Lamplighter",
	Role.HOLLOW: "Hollow",
	Role.SEER: "Seer",
	Role.WATCHMAN: "Watchman",
}
const ROLE_BLURBS := {
	Role.LAMPLIGHTER: "Keep the lanterns lit and finish your chores before dawn. Find the Hollow.",
	Role.HOLLOW: "Snuff the lanterns and take villagers in the dark. Don't get caught.",
	Role.SEER: "Once tonight, look closely at a villager to learn if they are Hollow. Choose well.",
	Role.WATCHMAN: "You see fresh footprints in the dark for a few seconds after someone passes.",
}

## The role card shown at the start of a match: a one-line goal, what each
## button does for this role ([action, text]) and a tip.
const ROLE_CARDS := {
	Role.LAMPLIGHTER: {
		"goal": "Keep the lanterns lit and finish your chores before dawn. One of the villagers is secretly Hollow: find them and vote them out.",
		"abilities": [["interact", "Relight a dark lantern, do a chore, or report what you find"], ["ring_bell", "Ring the bell in the square to call a meeting"]],
		"tip": "Chores need a lit lantern nearby. Stay in the light, and stay together.",
	},
	Role.HOLLOW: {
		"goal": "Put out the lanterns and take villagers where nobody can see. Blend in, and don't get voted out.",
		"abilities": [["special", "Snuff a lit lantern, or take a villager standing in the dark"], ["interact", "Do chores to look busy"]],
		"tip": "Both abilities need a cooldown. Slip away from the group, and never act where you can be seen.",
	},
	Role.SEER: {
		"goal": "Keep the lanterns lit and finish your chores. Once tonight you can look closely at a villager to learn if they are Hollow.",
		"abilities": [["special", "Look closely at a villager next to you, once"], ["interact", "Relight, do chores, report"]],
		"tip": "Choose carefully, and be careful how you share it. The Hollow would love to take you.",
	},
	Role.WATCHMAN: {
		"goal": "Keep the lanterns lit and finish your chores. You can see fresh footprints in the dark for a few seconds after someone passes.",
		"abilities": [["interact", "Relight, do chores, report"], ["ring_bell", "Ring the bell in the square to call a meeting"]],
		"tip": "Footprints show where someone just walked, so they can tell you who was where.",
	},
}

## Chores in the practice round: every kind of minigame, and one chore that
## carries something from one station to another.
const PRACTICE_CHORES := ["water", "fence", "candles", "hay"]

const SKIP_VOTE := 0

# Distances (metres)
const PERSONAL_LIGHT := 4.5
const LANTERN_RADIUS := 6.0
const VIEW_RADIUS := 14.0
## Chores need a lit lantern this close to the station (your own lantern is
## too dim to work by), except chores marked "dark".
const WORK_LIGHT_RADIUS := 7.0
const INTERACT_RANGE := 2.3
const TAKE_RANGE := 1.9
const SEER_RANGE := 3.0
const BELL_RANGE := 3.0

# Movement
const WALK_SPEED := 3.6
const BOT_SPEED := 3.1
const GHOST_SPEED := 4.2

# Timings (seconds)
const RELIGHT_TIME := 2.0
const SNUFF_COOLDOWN := 15.0
const TAKE_COOLDOWN := 25.0
const FIRST_COOLDOWN := 12.0
const BELL_COOLDOWN := 15.0
const REVEAL_TIME := 6.0
const FOOTPRINT_LIFE := 6.0
const FLICKER_TIME := 3.0

## Chores: each has one or more stations visited in order, each with a
## minigame. `min` is the shortest time the host accepts for that step.
## Most chores carry something across the village between two stations, so
## they take a while and leave the Lamplighter out on their own; a step's
## `label` says where to go next.
const CHORES := {
	"water": {"label": "Water the animals", "steps": [
		{"station": "fountain", "game": "mash", "min": 2.5, "carry": "water", "label": "Pump water at the fountain"},
		{"station": "pen", "game": "hold", "time": 3.0, "min": 2.5, "label": "Pour it in the animals' trough"}]},
	"fence": {"label": "Mend the broken fence", "steps": [
		{"station": "woodpile", "game": "hold", "time": 3.0, "min": 2.5, "carry": "planks", "label": "Fetch planks from the woodpile"},
		{"station": "fence", "game": "timing", "min": 3.0, "label": "Nail the planks to the fence"}]},
	"animals": {"label": "Feed the animals", "steps": [
		{"station": "hay", "game": "hold", "time": 3.0, "min": 2.5, "carry": "hay", "label": "Fork up hay in the hayfield"},
		{"station": "pen", "game": "hold", "time": 3.5, "min": 3.0, "label": "Feed the hay to the animals"}]},
	"candles": {"label": "Light the chapel candles", "steps": [
		{"station": "campfire", "game": "hold", "time": 2.5, "min": 2.0, "carry": "taper", "label": "Light a taper at the campfire"},
		{"station": "chapel", "game": "sequence", "min": 2.2, "label": "Light the chapel candles"}]},
	"market": {"label": "Stock the market stall", "steps": [
		{"station": "pen", "game": "hold", "time": 3.0, "min": 2.5, "carry": "eggs", "label": "Collect eggs at the farm"},
		{"station": "market", "game": "sequence", "min": 2.2, "label": "Set out the eggs at the market"}]},
	"wood": {"label": "Bring wood to the campfire", "steps": [
		{"station": "woodpile", "game": "hold", "time": 3.0, "min": 2.5, "carry": "wood", "label": "Fetch wood from the woodpile"},
		{"station": "campfire", "game": "hold", "time": 2.5, "min": 2.0, "label": "Stack the wood by the campfire"}]},
	"hay": {"label": "Stack the hay", "steps": [{"station": "hay", "game": "hold", "time": 4.5, "min": 4.0}]},
	"grave": {"label": "Dig at the old grave", "steps": [{"station": "grave", "game": "mash", "min": 2.5, "dark": true}]},
}

## Lobby settings the host can change. Every client gets a copy.
const DEFAULT_SETTINGS := {
	"night_minutes": 8,
	"hollow_count": 0,         # 0 = automatic (1 for up to 6 players, 2 above)
	"special_roles": true,     # Seer from 5 players, Watchman from 7
	"chores_each": 7,
	"discussion_seconds": 45,
	"vote_seconds": 30,
	"reveal_on_banish": true,
	"anonymous_votes": true,
	"bell_uses": 1,
	"dawn_chore_goal": 0.75,   # share of chores needed at dawn for the village
	"dark_fraction": 0.25,     # Hollow win if fewer lanterns than this stay lit
	"ai_brains": true,         # bots think with the local LLM when available
}


static func team_of(role: int) -> int:
	return Team.HOLLOW if role == Role.HOLLOW else Team.VILLAGE


static func hollow_count_for(players: int, setting: int) -> int:
	if setting > 0:
		return clampi(setting, 1, maxi(1, (players - 1) / 2))
	return 1 if players <= 6 else 2


## Deals roles for `ids` (already shuffled by the caller's RNG).
static func deal_roles(ids: Array, settings: Dictionary, rng: RandomNumberGenerator) -> Dictionary:
	var order := ids.duplicate()
	_shuffle(order, rng)
	var roles := {}
	var n := order.size()
	var hollow := hollow_count_for(n, int(settings.get("hollow_count", 0)))
	var i := 0
	for h in hollow:
		roles[order[i]] = Role.HOLLOW
		i += 1
	if settings.get("special_roles", true):
		if n >= 5 and i < n:
			roles[order[i]] = Role.SEER
			i += 1
		if n >= 7 and i < n:
			roles[order[i]] = Role.WATCHMAN
			i += 1
	while i < n:
		roles[order[i]] = Role.LAMPLIGHTER
		i += 1
	return roles


## What to do for one step of a chore, or the chore's name if it has one step.
static func step_label(key: String, step: int) -> String:
	var chore: Dictionary = CHORES[key]
	var steps: Array = chore.steps
	if step >= 0 and step < steps.size() and steps[step].has("label"):
		return steps[step].label
	return chore.label


static func deal_chores(count: int, rng: RandomNumberGenerator) -> Array:
	var keys := CHORES.keys()
	_shuffle(keys, rng)
	return keys.slice(0, clampi(count, 1, keys.size()))


static func _shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp
