@tool
@icon('res://addons/little_helper/icon.svg')
extends MarginContainer

@onready var status_box: HBoxContainer = $VBoxContainer/HeaderBox/StatusBox
@onready var status_icon: TextureRect = $VBoxContainer/HeaderBox/StatusBox/StatusIcon
@onready var status_label: Label = $VBoxContainer/HeaderBox/StatusBox/StatusLabel
@onready var settings_button: Button = $VBoxContainer/HeaderBox/SettingsButton
@onready var clear_button: Button = $VBoxContainer/HeaderBox/ClearButton
@onready var chat_history: RichTextLabel = $VBoxContainer/ChatHistory
@onready var autocomplete_box: PanelContainer = $VBoxContainer/AutocompleteBox
@onready var autocomplete_list: ItemList = $VBoxContainer/AutocompleteBox/AutocompleteList
@onready var input_box: HBoxContainer = $VBoxContainer/InputBox
@onready var attach_button: Button = $VBoxContainer/InputBox/AttachButton
@onready var prompt_input: LineEdit = $VBoxContainer/InputBox/PromptInput
@onready var send_button: Button = $VBoxContainer/InputBox/SendButton

signal settings_saved

# Settings Overlay and Panel
@onready var settings_overlay: Control = $SettingsOverlay
@onready var settings_panel: PanelContainer = $SettingsOverlay/SettingsPanel
@onready var close_settings_button: Button = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsHeader/CloseSettingsButton
@onready var mode_option: OptionButton = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/ModeOption
@onready var direct_ai_section: VBoxContainer = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/DirectAiSection
@onready var provider_option: OptionButton = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/DirectAiSection/ProviderOption
@onready var model_input: LineEdit = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/DirectAiSection/ModelInput
@onready var api_key_input: LineEdit = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/DirectAiSection/ApiKeyInput
@onready var endpoint_input: LineEdit = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/DirectAiSection/EndpointInput
@onready var temp_label: Label = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/DirectAiSection/TempLabel
@onready var temp_slider: HSlider = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/DirectAiSection/TempSlider

@onready var mcp_section: VBoxContainer = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/McpSection
@onready var mcp_enable_check: CheckBox = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/McpSection/McpEnableCheck
@onready var mcp_port_input: LineEdit = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/McpSection/McpPortBox/McpPortInput
@onready var mcp_snippet: TextEdit = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/McpSection/McpSnippet
@onready var copy_config_button: Button = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/McpSection/CopyConfigButton
@onready var mcp_feedback_label: Label = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsScroll/FormLayout/McpSection/McpFeedbackLabel

@onready var save_status_label: Label = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsFooter/SaveStatusLabel
@onready var save_settings_button: Button = $SettingsOverlay/SettingsPanel/SettingsLayout/SettingsFooter/SaveSettingsButton

const ICONS_DIR := "res://addons/little_helper/icons/"
const TRASH_SVG := ICONS_DIR + "trash.svg"
const SEND_SVG := ICONS_DIR + "send.svg"
const PLUS_SVG := ICONS_DIR + "plus.svg"
const CHEVRON_DOWN_SVG := ICONS_DIR + "chevron_down.svg"
const CHEVRON_UP_SVG := ICONS_DIR + "chevron_up.svg"
const SETTINGS_SVG := ICONS_DIR + "settings.svg"
const CIRCLE_ARROW_SVG := ICONS_DIR + "circle_arrow.svg"
const CROSS_SVG := ICONS_DIR + "cross.svg"
const SCRIPT_SVG := ICONS_DIR + "script.svg"
const NODE_SVG := ICONS_DIR + "node.svg"
const TREE_SVG := ICONS_DIR + "tree.svg"
const BOOK_SVG := ICONS_DIR + "book.svg"
const TERMINAL_SVG := ICONS_DIR + "terminal.svg"
const FOLDER_SVG := ICONS_DIR + "folder.svg"
const BOLT_SVG := ICONS_DIR + "bolt.svg"
const COPY_SVG := ICONS_DIR + "copy.svg"
const SETTINGS_FILE_PATH := "user://little_helper_settings.cfg"
const INITIAL_GREETING := "Hi! Ask me anything, use [color=#66ccff][b]@[/b][/color] to attach editor context (@script, @node, @tree), or [color=#eebb44][b]/[/b][/color] for actions.\nClick [b]+[/b] to attach files or resources."
const LLMClient = preload("res://addons/little_helper/src/agent/llm_client.gd")
const Utils = preload("res://addons/little_helper/src/tools/tool_utils.gd")

const CONTEXT_MENTIONS: Array[Dictionary] = [
	{
		"name": "@script",
		"desc": "Active GDScript in Godot Script Editor",
		"usage": "@script"
	},
	{
		"name": "@node",
		"desc": "Selected node in scene tree & inspector",
		"usage": "@node"
	},
	{
		"name": "@tree",
		"desc": "Active scene node tree hierarchy",
		"usage": "@tree"
	},
	{
		"name": "@docs",
		"desc": "Engine documentation from ClassDB",
		"usage": "@docs"
	},
	{
		"name": "@logs",
		"desc": "Recent Godot debug & error logs",
		"usage": "@logs"
	}
]

const COMMANDS: Array[Dictionary] = [
	{
		"name": "/help",
		"desc": "Show all available commands and usage",
		"usage": "/help"
	},
	{
		"name": "/selected",
		"desc": "Inspect currently selected node in editor",
		"usage": "/selected"
	},
	{
		"name": "/select",
		"desc": "Select & focus a node in scene tree & inspector",
		"usage": "/select <node_path>"
	},
	{
		"name": "/tree",
		"desc": "View full scene tree hierarchy",
		"usage": "/tree"
	},
	{
		"name": "/inspect",
		"desc": "Inspect node properties by path",
		"usage": "/inspect <node_path>"
	},
	{
		"name": "/tools",
		"desc": "List registered MCP & engine tools",
		"usage": "/tools"
	},
	{
		"name": "/clear",
		"desc": "Clear chat history",
		"usage": "/clear"
	},
	{
		"name": "/save",
		"desc": "Save active scene (or '/save all' for all scenes)",
		"usage": "/save [all]"
	},
	{
		"name": "/open",
		"desc": "Open a scene (.tscn) in editor tab",
		"usage": "/open <scene_path>"
	},
	{
		"name": "/remove",
		"desc": "Remove node from scene with Undo/Redo",
		"usage": "/remove <node_path>"
	},
	{
		"name": "/run",
		"desc": "Play main project scene (or custom scene path)",
		"usage": "/run [scene_path]"
	},
	{
		"name": "/stop",
		"desc": "Stop playing running project scene",
		"usage": "/stop"
	},
	{
		"name": "/logs",
		"desc": "View recent Godot debug & error logs",
		"usage": "/logs [lines]"
	},
	{
		"name": "/setting",
		"desc": "Get, set, or search ProjectSettings",
		"usage": "/setting <name_or_prefix> [value]"
	},
	{
		"name": "/eval",
		"desc": "Execute GDScript snippet or expression",
		"usage": "/eval <code>"
	},
	{
		"name": "/doc",
		"desc": "Inspect Godot 4 class or method documentation from ClassDB",
		"usage": "/doc <class_name>[.<symbol>]"
	},
	{
		"name": "/script",
		"desc": "Inspect the active GDScript open in Godot Script Editor",
		"usage": "/script"
	},
	{
		"name": "/error",
		"desc": "Test error status indicator",
		"usage": "/error"
	}
]

var _icon_cache: Dictionary = {}
var _settings_tween: Tween = null
var _is_busy: bool = false
var _spin_tween: Tween = null
var _llm_client: Node = null

var _attach_popup: PopupMenu = null
var _file_dialog: FileDialog = null
var custom_instructions_edit: TextEdit = null
var _code_blocks: Array[String] = []

func _ready() -> void:
	status_icon.custom_minimum_size = Vector2(16, 16)
	status_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	status_icon.pivot_offset = Vector2(8, 8)
	status_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	set_idle()
	
	chat_history.bbcode_enabled = true
	if not chat_history.meta_clicked.is_connected(_on_chat_meta_clicked):
		chat_history.meta_clicked.connect(_on_chat_meta_clicked)
	
	# Connect chat interactions
	if not attach_button.pressed.is_connected(_on_attach_button_pressed):
		attach_button.pressed.connect(_on_attach_button_pressed)
	if not send_button.pressed.is_connected(_on_send_pressed):
		send_button.pressed.connect(_on_send_pressed)
	if not prompt_input.text_submitted.is_connected(_on_prompt_submitted):
		prompt_input.text_submitted.connect(_on_prompt_submitted)
	if not prompt_input.text_changed.is_connected(_on_prompt_text_changed):
		prompt_input.text_changed.connect(_on_prompt_text_changed)
	if not prompt_input.gui_input.is_connected(_on_prompt_gui_input):
		prompt_input.gui_input.connect(_on_prompt_gui_input)
	if not autocomplete_list.item_clicked.is_connected(_on_autocomplete_item_clicked):
		autocomplete_list.item_clicked.connect(_on_autocomplete_item_clicked)
	if not clear_button.pressed.is_connected(_on_clear_pressed):
		clear_button.pressed.connect(_on_clear_pressed)
	
	# Connect settings interactions
	if not settings_button.pressed.is_connected(_toggle_settings):
		settings_button.pressed.connect(_toggle_settings)
	if not close_settings_button.pressed.is_connected(_close_settings):
		close_settings_button.pressed.connect(_close_settings)
	if not mode_option.item_selected.is_connected(_on_mode_selected):
		mode_option.item_selected.connect(_on_mode_selected)
	if not provider_option.item_selected.is_connected(_on_provider_selected):
		provider_option.item_selected.connect(_on_provider_selected)
	if not temp_slider.value_changed.is_connected(_on_temp_slider_changed):
		temp_slider.value_changed.connect(_on_temp_slider_changed)
	if not copy_config_button.pressed.is_connected(_on_copy_mcp_config_pressed):
		copy_config_button.pressed.connect(_on_copy_mcp_config_pressed)
	if not mcp_port_input.text_changed.is_connected(_on_mcp_port_changed):
		mcp_port_input.text_changed.connect(_on_mcp_port_changed)
	if not mcp_enable_check.toggled.is_connected(_on_mcp_enable_toggled):
		mcp_enable_check.toggled.connect(_on_mcp_enable_toggled)
	if not save_settings_button.pressed.is_connected(_on_save_settings_pressed):
		save_settings_button.pressed.connect(_on_save_settings_pressed)
	if not resized.is_connected(_on_dock_resized):
		resized.connect(_on_dock_resized)
	if not settings_overlay.resized.is_connected(_on_dock_resized):
		settings_overlay.resized.connect(_on_dock_resized)
	
	settings_overlay.visible = false
	_reset_settings_panel_layout()
	
	_apply_panel_style()
	_setup_provider_options()
	_setup_custom_instructions_ui()
	_setup_attach_popup()
	_load_settings()
	
	_update_button_icons()
	_hide_autocomplete()
	
	if not _llm_client:
		_llm_client = LLMClient.new()
		add_child(_llm_client)
		_llm_client.response_received.connect(_on_llm_response)
		_llm_client.request_failed.connect(_on_llm_error)
		_llm_client.status_changed.connect(_on_llm_status_changed)
	
	_restore_chat_history()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		if is_node_ready():
			_apply_panel_style()
			_update_button_icons()


func _apply_panel_style() -> void:
	var bg := Color(0.14, 0.16, 0.2, 1.0)
	var border := Color(0.25, 0.28, 0.35, 1.0)
	if Engine.is_editor_hint():
		if has_theme_color("base_color", "Editor"):
			bg = get_theme_color("base_color", "Editor")
		if has_theme_color("separator_color", "Editor"):
			border = get_theme_color("separator_color", "Editor")
	
	if is_instance_valid(settings_panel):
		var sb := StyleBoxFlat.new()
		sb.bg_color = bg
		sb.border_width_right = 1
		sb.border_color = border
		sb.set_content_margin_all(8)
		settings_panel.add_theme_stylebox_override("panel", sb)
	
	if is_instance_valid(autocomplete_box):
		var ac_sb := StyleBoxFlat.new()
		ac_sb.bg_color = bg
		ac_sb.border_width_left = 1
		ac_sb.border_width_top = 1
		ac_sb.border_width_right = 1
		ac_sb.border_width_bottom = 1
		ac_sb.border_color = border
		ac_sb.corner_radius_top_left = 4
		ac_sb.corner_radius_top_right = 4
		ac_sb.set_content_margin_all(4)
		autocomplete_box.add_theme_stylebox_override("panel", ac_sb)
	
	if is_instance_valid(autocomplete_list):
		var empty_sb := StyleBoxEmpty.new()
		autocomplete_list.add_theme_stylebox_override("panel", empty_sb)
	
	if is_instance_valid(mcp_snippet):
		var snip_sb := StyleBoxFlat.new()
		snip_sb.bg_color = Color(0.1, 0.12, 0.15, 1.0)
		snip_sb.border_width_left = 1
		snip_sb.border_width_top = 1
		snip_sb.border_width_right = 1
		snip_sb.border_width_bottom = 1
		snip_sb.border_color = border
		snip_sb.set_content_margin_all(6)
		mcp_snippet.add_theme_stylebox_override("normal", snip_sb)
		mcp_snippet.add_theme_stylebox_override("read_only", snip_sb)


func _setup_provider_options() -> void:
	provider_option.clear()
	provider_option.add_item("OpenAI (ChatGPT)", 0)
	provider_option.add_item("Anthropic (Claude)", 1)
	provider_option.add_item("Google Gemini", 2)
	provider_option.add_item("DeepSeek", 3)
	provider_option.add_item("Ollama (Local)", 4)
	provider_option.add_item("Custom / Compatible", 5)


func _on_provider_selected(index: int, update_defaults: bool = true) -> void:
	match index:
		0: # OpenAI
			if update_defaults:
				model_input.text = "gpt-4o"
				endpoint_input.text = "https://api.openai.com/v1/chat/completions"
			api_key_input.editable = true
			api_key_input.placeholder_text = "sk-..."
		1: # Claude
			if update_defaults:
				model_input.text = "claude-3-5-sonnet-latest"
				endpoint_input.text = "https://api.anthropic.com/v1/messages"
			api_key_input.editable = true
			api_key_input.placeholder_text = "sk-ant-..."
		2: # Gemini
			if update_defaults:
				model_input.text = "gemini-flash-lite-latest"
				endpoint_input.text = "https://generativelanguage.googleapis.com/v1beta/models/"
			api_key_input.editable = true
			api_key_input.placeholder_text = "AIzaSy... / AQ...."
		3: # DeepSeek
			if update_defaults:
				model_input.text = "deepseek-chat"
				endpoint_input.text = "https://api.deepseek.com/v1/chat/completions"
			api_key_input.editable = true
			api_key_input.placeholder_text = "sk-..."
		4: # Ollama
			if update_defaults:
				model_input.text = "llama3:latest"
				endpoint_input.text = "http://localhost:11434/api/chat"
			api_key_input.editable = false
			api_key_input.placeholder_text = "(Not needed for local Ollama)"
		5: # Custom
			if update_defaults:
				model_input.text = ""
				endpoint_input.text = ""
			api_key_input.editable = true
			api_key_input.placeholder_text = "API Key"


func _on_temp_slider_changed(val: float) -> void:
	temp_label.text = "Temperature: %.2f" % val


func _load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_FILE_PATH)
	if err == OK:
		var mode: int = int(config.get_value("general", "mode", 0))
		mode_option.selected = mode
		_on_mode_selected(mode)
		
		var p_idx: int = int(config.get_value("llm", "provider", 0))
		provider_option.selected = p_idx
		_on_provider_selected(p_idx, false)
		model_input.text = config.get_value("llm", "model", "gpt-4o")
		api_key_input.text = config.get_value("llm", "api_key", "")
		endpoint_input.text = config.get_value("llm", "endpoint", "https://api.openai.com/v1/chat/completions")
		var t_val: float = float(config.get_value("llm", "temperature", 0.7))
		temp_slider.value = t_val
		temp_label.text = "Temperature: %.2f" % t_val
		
		if is_instance_valid(custom_instructions_edit):
			custom_instructions_edit.text = str(config.get_value("llm", "custom_instructions", ""))
		
		var b_enabled: bool = bool(config.get_value("bridge", "enabled", true))
		mcp_enable_check.button_pressed = b_enabled
		var b_port: int = int(config.get_value("bridge", "port", 9099))
		mcp_port_input.text = str(b_port)
		_update_mcp_status()
	else:
		mode_option.selected = 0
		_on_mode_selected(0)
		provider_option.selected = 0
		_on_provider_selected(0, true)
		mcp_enable_check.button_pressed = true
		mcp_port_input.text = "9099"
		_update_mcp_status()


func _on_mode_selected(idx: int) -> void:
	match idx:
		0: # In-Engine Chat
			direct_ai_section.visible = true
			mcp_section.visible = false
			prompt_input.placeholder_text = "Ask anything, @ to mention, / for actions"
		1: # External Agent (MCP Bridge)
			direct_ai_section.visible = false
			mcp_section.visible = true
			prompt_input.placeholder_text = "Running as MCP server (use /help for tools)..."
			_update_mcp_status()
		2: # Dual Mode
			direct_ai_section.visible = true
			mcp_section.visible = true
			prompt_input.placeholder_text = "Ask anything, @ to mention, / for actions"
			_update_mcp_status()


func _on_mcp_port_changed(_new_text: String) -> void:
	_update_mcp_snippet()


func _on_mcp_enable_toggled(_toggled_on: bool) -> void:
	_update_mcp_status()


func _update_mcp_snippet() -> void:
	if not is_instance_valid(mcp_snippet):
		return
	var port_str := mcp_port_input.text.strip_edges() if is_instance_valid(mcp_port_input) else "9099"
	if port_str.is_empty():
		port_str = "9099"
	var script_path := ProjectSettings.globalize_path("res://addons/little_helper/bridge/mcp_bridge.js").replace("\\", "/")
	var snippet := {
		"mcpServers": {
			"godot-little-helper": {
				"command": "node",
				"args": [script_path],
				"env": {
					"GODOT_PORT": port_str
				}
			}
		}
	}
	mcp_snippet.text = JSON.stringify(snippet, "  ")


func _update_mcp_status() -> void:
	_update_mcp_snippet()


func _on_copy_mcp_config_pressed() -> void:
	_update_mcp_snippet()
	DisplayServer.clipboard_set(mcp_snippet.text)
	mcp_feedback_label.text = "MCP config copied to clipboard!"
	mcp_feedback_label.add_theme_color_override("font_color", Color(0.4, 0.95, 0.45, 1.0))
	get_tree().create_timer(2.2).timeout.connect(func():
		if is_instance_valid(mcp_feedback_label):
			mcp_feedback_label.text = ""
	)


func _on_save_settings_pressed() -> void:
	var config := ConfigFile.new()
	config.set_value("general", "mode", mode_option.selected)
	
	config.set_value("llm", "provider", provider_option.selected)
	config.set_value("llm", "model", model_input.text.strip_edges())
	config.set_value("llm", "api_key", api_key_input.text.strip_edges())
	config.set_value("llm", "endpoint", endpoint_input.text.strip_edges())
	config.set_value("llm", "temperature", temp_slider.value)
	if is_instance_valid(custom_instructions_edit):
		config.set_value("llm", "custom_instructions", custom_instructions_edit.text.strip_edges())
	
	config.set_value("bridge", "enabled", mcp_enable_check.button_pressed)
	config.set_value("bridge", "port", int(mcp_port_input.text.strip_edges()))
	
	var err := config.save(SETTINGS_FILE_PATH)
	if err == OK:
		save_status_label.text = "Saved!"
		save_status_label.modulate = Color(0.4, 1.0, 0.4)
		settings_saved.emit()
		_on_mode_selected(mode_option.selected)
		get_tree().create_timer(0.6).timeout.connect(func():
			if is_instance_valid(save_status_label):
				save_status_label.text = ""
			_close_settings()
		)
	else:
		save_status_label.text = "Failed to save!"
		save_status_label.modulate = Color(1.0, 0.4, 0.4)


func _reset_settings_panel_layout() -> void:
	if not is_instance_valid(settings_panel):
		return
	settings_panel.anchor_left = 0.0
	settings_panel.anchor_top = 0.0
	settings_panel.anchor_right = 1.0
	settings_panel.anchor_bottom = 1.0
	settings_panel.grow_horizontal = Control.GROW_DIRECTION_END
	settings_panel.grow_vertical = Control.GROW_DIRECTION_END
	settings_panel.offset_left = 0.0
	settings_panel.offset_top = 0.0
	settings_panel.offset_right = 0.0
	settings_panel.offset_bottom = 0.0


func _open_settings() -> void:
	if _settings_tween and _settings_tween.is_valid():
		_settings_tween.kill()
	
	_update_mcp_status()
	
	var dock_size := size
	if dock_size.x <= 0.0 or dock_size.y <= 0.0:
		dock_size = get_rect().size
	if dock_size.x <= 0.0:
		dock_size.x = 320.0
	if dock_size.y <= 0.0:
		dock_size.y = 500.0
	
	settings_overlay.visible = true
	settings_overlay.size = dock_size
	settings_overlay.position = Vector2.ZERO
	
	_reset_settings_panel_layout()
	settings_panel.size = dock_size
	settings_panel.position = Vector2(-dock_size.x, 0.0)
	
	_settings_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_settings_tween.tween_property(settings_panel, "position:x", 0.0, 0.25)


func _close_settings() -> void:
	if not settings_overlay or not settings_overlay.visible:
		return
	if _settings_tween and _settings_tween.is_valid():
		_settings_tween.kill()
	
	var target_x := -size.x if size.x > 0.0 else -settings_panel.size.x
	_settings_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_settings_tween.tween_property(settings_panel, "position:x", target_x, 0.2)
	_settings_tween.tween_callback(func():
		if is_instance_valid(settings_overlay):
			settings_overlay.visible = false
	)


func _toggle_settings() -> void:
	if settings_overlay and settings_overlay.visible and settings_panel.position.x >= -10.0:
		_close_settings()
	else:
		_open_settings()


func _on_dock_resized() -> void:
	if is_instance_valid(settings_overlay) and settings_overlay.visible:
		var dock_size := size
		if dock_size.x > 0.0 and dock_size.y > 0.0:
			settings_overlay.size = dock_size
			settings_overlay.position = Vector2.ZERO
			settings_panel.size = dock_size
			settings_panel.offset_top = 0.0
			settings_panel.offset_bottom = 0.0
			settings_panel.position.y = 0.0
			if _settings_tween == null or not _settings_tween.is_valid():
				settings_panel.position.x = 0.0


func _update_button_icons() -> void:
	# Settings icon
	var settings_icon := _get_svg_icon(SETTINGS_SVG, 16)
	if settings_icon:
		settings_button.icon = settings_icon
	elif Engine.is_editor_hint() and has_theme_icon("Tools", "EditorIcons"):
		settings_button.icon = get_theme_icon("Tools", "EditorIcons")
	
	# Trash icon for ClearButton
	var trash_icon := _get_svg_icon(TRASH_SVG, 16)
	if trash_icon:
		clear_button.icon = trash_icon
	elif Engine.is_editor_hint() and has_theme_icon("Remove", "EditorIcons"):
		clear_button.icon = get_theme_icon("Remove", "EditorIcons")
	
	# Send icon for SendButton
	var send_icon := _get_svg_icon(SEND_SVG, 16)
	if send_icon:
		send_button.icon = send_icon
	elif Engine.is_editor_hint() and has_theme_icon("ArrowUp", "EditorIcons"):
		send_button.icon = get_theme_icon("ArrowUp", "EditorIcons")

	# Attach icon for AttachButton
	if is_instance_valid(attach_button):
		var plus_icon := _get_svg_icon(PLUS_SVG, 16)
		if plus_icon:
			attach_button.icon = plus_icon
			attach_button.text = ""
		elif Engine.is_editor_hint() and has_theme_icon("Add", "EditorIcons"):
			attach_button.icon = get_theme_icon("Add", "EditorIcons")
			attach_button.text = ""
		else:
			attach_button.text = "+"

	# Close icon for CloseSettingsButton
	if is_instance_valid(close_settings_button):
		var cross_icon := _get_svg_icon(CROSS_SVG, 14)
		if cross_icon:
			close_settings_button.icon = cross_icon
			close_settings_button.text = ""
		elif Engine.is_editor_hint() and has_theme_icon("Close", "EditorIcons"):
			close_settings_button.icon = get_theme_icon("Close", "EditorIcons")
			close_settings_button.text = ""


func _get_svg_icon(path: String, target_size: int = 16) -> Texture2D:
	var key := "%s_%d" % [path, target_size]
	if _icon_cache.has(key):
		return _icon_cache[key]
	var tex := _load_svg_icon(path, target_size)
	if tex:
		_icon_cache[key] = tex
	return tex


func _load_svg_icon(path: String, target_size: int = 16) -> Texture2D:
	if not FileAccess.file_exists(path):
		return null
	
	var svg_str := FileAccess.get_file_as_string(path)
	if svg_str.is_empty():
		return null
	
	# Strip DOCTYPE / comment headers so ThorVG parses clean SVG root
	var svg_start := svg_str.find("<svg")
	if svg_start > 0:
		svg_str = svg_str.substr(svg_start)
	
	var img := Image.new()
	var err := img.load_svg_from_string(svg_str)
	if err != OK:
		err = img.load_svg_from_buffer(FileAccess.get_file_as_bytes(path))
	
	if err == OK and not img.is_empty():
		if img.get_width() != target_size or img.get_height() != target_size:
			var scale_factor := float(target_size) / float(maxi(img.get_width(), 1))
			var img_scaled := Image.new()
			if img_scaled.load_svg_from_string(svg_str, scale_factor) == OK and not img_scaled.is_empty():
				return ImageTexture.create_from_image(img_scaled)
			img.resize(target_size, target_size, Image.INTERPOLATE_LANCZOS)
		return ImageTexture.create_from_image(img)
	
	return null


func set_idle() -> void:
	_is_busy = false
	if _spin_tween and _spin_tween.is_valid():
		_spin_tween.kill()
		_spin_tween = null
	
	if is_instance_valid(status_icon):
		status_icon.visible = false
		status_icon.rotation = 0.0
		status_icon.texture = null
	
	if is_instance_valid(status_label):
		status_label.visible = false
		status_label.text = ""


func set_busy(message: String = "Thinking...") -> void:
	_is_busy = true
	if _spin_tween and _spin_tween.is_valid():
		_spin_tween.kill()
		_spin_tween = null
	
	var icon: Texture2D = _get_indicator_icon("busy")
	if is_instance_valid(status_icon):
		status_icon.texture = icon
		status_icon.modulate = Color.WHITE
		status_icon.pivot_offset = Vector2(8, 8)
		status_icon.rotation = 0.0
		status_icon.visible = (icon != null)
		
		# Animate spinning
		if icon != null:
			_spin_tween = create_tween().set_loops()
			_spin_tween.tween_property(status_icon, "rotation", TAU, 1.0).from(0.0)
	
	if is_instance_valid(status_label):
		status_label.text = message
		status_label.tooltip_text = message
		status_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.75, 1.0))
		status_label.visible = not message.is_empty()


func set_error(message: String = "Error") -> void:
	_is_busy = false
	if _spin_tween and _spin_tween.is_valid():
		_spin_tween.kill()
		_spin_tween = null
	
	var icon: Texture2D = _get_indicator_icon("error")
	if is_instance_valid(status_icon):
		status_icon.texture = icon
		status_icon.modulate = Color(1.0, 0.35, 0.35, 1.0)
		status_icon.pivot_offset = Vector2(8, 8)
		status_icon.rotation = 0.0
		status_icon.visible = (icon != null)
	
	if is_instance_valid(status_label):
		status_label.text = message
		status_label.tooltip_text = message
		status_label.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45, 1.0))
		status_label.visible = not message.is_empty()


func _get_indicator_icon(kind: String) -> Texture2D:
	if kind == "busy":
		var tex := _get_svg_icon(CIRCLE_ARROW_SVG, 16)
		if tex:
			return tex
		if Engine.is_editor_hint():
			for cand in ["Reload", "Progress1", "Loop", "Time"]:
				if has_theme_icon(cand, "EditorIcons"):
					return get_theme_icon(cand, "EditorIcons")
	elif kind == "error":
		var tex := _get_svg_icon(CROSS_SVG, 16)
		if tex:
			return tex
		if Engine.is_editor_hint():
			for cand in ["Close", "Error", "StatusError"]:
				if has_theme_icon(cand, "EditorIcons"):
					return get_theme_icon(cand, "EditorIcons")
	return null


func _on_prompt_text_changed(new_text: String) -> void:
	_update_autocomplete(new_text)


func _update_autocomplete(text: String) -> void:
	var caret := prompt_input.caret_column
	var text_before_caret := text.substr(0, caret)
	var last_space := text_before_caret.rfind(" ")
	var current_word := text_before_caret.substr(last_space + 1)
	
	var is_slash_cmd := (last_space == -1 and current_word.begins_with("/"))
	var is_mention := current_word.begins_with("@")
	
	if not is_slash_cmd and not is_mention:
		_hide_autocomplete()
		return
	
	var matches: Array[Dictionary] = []
	var query := current_word.to_lower()
	
	if is_mention:
		for item in CONTEXT_MENTIONS:
			var m_name: String = item["name"]
			if query == "@" or m_name.to_lower().begins_with(query):
				matches.append(item)
	elif is_slash_cmd:
		for cmd in COMMANDS:
			var c_name: String = cmd["name"]
			if query == "/" or c_name.to_lower().begins_with(query):
				matches.append(cmd)
	
	if matches.is_empty():
		_hide_autocomplete()
		return
	
	autocomplete_list.clear()
	for item in matches:
		var label := "%s  —  %s" % [item["name"], item["desc"]]
		var icon: Texture2D = _get_mention_icon(item["name"]) if is_mention else _get_command_icon(item["name"])
		var idx := autocomplete_list.add_item(label, icon)
		autocomplete_list.set_item_metadata(idx, item["name"])
		autocomplete_list.set_item_tooltip(idx, item["desc"])
	
	autocomplete_list.select(0)
	autocomplete_list.ensure_current_is_visible()
	
	var row_height := 26.0
	var total_h := clampf(matches.size() * row_height + 10.0, 36.0, 140.0)
	autocomplete_box.custom_minimum_size.y = total_h
	autocomplete_box.visible = true


func _on_prompt_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match event.keycode:
			KEY_UP:
				if autocomplete_box.visible:
					_navigate_autocomplete(-1)
					prompt_input.accept_event()
			KEY_DOWN:
				if autocomplete_box.visible:
					_navigate_autocomplete(1)
					prompt_input.accept_event()
			KEY_TAB:
				if autocomplete_box.visible and autocomplete_list.item_count > 0:
					_apply_selected_autocomplete()
					prompt_input.accept_event()
				else:
					_update_autocomplete(prompt_input.text)
					if autocomplete_box.visible and autocomplete_list.item_count > 0:
						_apply_selected_autocomplete()
						prompt_input.accept_event()
			KEY_ENTER, KEY_KP_ENTER:
				if autocomplete_box.visible and autocomplete_list.item_count > 0:
					_apply_selected_autocomplete()
					prompt_input.accept_event()
			KEY_ESCAPE:
				if autocomplete_box.visible:
					_hide_autocomplete()
					prompt_input.accept_event()


func _navigate_autocomplete(direction: int) -> void:
	var count := autocomplete_list.item_count
	if count == 0:
		return
	var selected := autocomplete_list.get_selected_items()
	var current := selected[0] if selected.size() > 0 else 0
	var next := posmod(current + direction, count)
	autocomplete_list.select(next)
	autocomplete_list.ensure_current_is_visible()


func _apply_selected_autocomplete() -> void:
	var selected := autocomplete_list.get_selected_items()
	var idx := selected[0] if selected.size() > 0 else 0
	_apply_autocomplete_index(idx)


func _on_autocomplete_item_clicked(index: int, _at_position: Vector2, _mouse_button_index: int) -> void:
	_apply_autocomplete_index(index)


func _apply_autocomplete_index(index: int) -> void:
	if index < 0 or index >= autocomplete_list.item_count:
		return
	var item_name: String = autocomplete_list.get_item_metadata(index)
	var text := prompt_input.text
	var caret := prompt_input.caret_column
	var text_before_caret := text.substr(0, caret)
	var last_space := text_before_caret.rfind(" ")
	var word_start := last_space + 1
	var text_after_caret := text.substr(caret)
	
	var new_text := text.substr(0, word_start) + item_name + " " + text_after_caret
	prompt_input.text = new_text
	prompt_input.caret_column = word_start + item_name.length() + 1
	_hide_autocomplete()
	prompt_input.grab_focus()


func _hide_autocomplete() -> void:
	if is_instance_valid(autocomplete_box):
		autocomplete_box.visible = false
	if is_instance_valid(autocomplete_list):
		autocomplete_list.clear()


func _get_mention_icon(mention_name: String) -> Texture2D:
	match mention_name:
		"@script":
			var ic := _get_svg_icon(SCRIPT_SVG, 16)
			if ic: return ic
			if Engine.is_editor_hint() and has_theme_icon("Script", "EditorIcons"):
				return get_theme_icon("Script", "EditorIcons")
		"@node":
			var ic := _get_svg_icon(NODE_SVG, 16)
			if ic: return ic
			if Engine.is_editor_hint() and has_theme_icon("Node", "EditorIcons"):
				return get_theme_icon("Node", "EditorIcons")
		"@tree":
			var ic := _get_svg_icon(TREE_SVG, 16)
			if ic: return ic
			if Engine.is_editor_hint() and has_theme_icon("Tree", "EditorIcons"):
				return get_theme_icon("Tree", "EditorIcons")
		"@docs":
			var ic := _get_svg_icon(BOOK_SVG, 16)
			if ic: return ic
			if Engine.is_editor_hint() and has_theme_icon("Help", "EditorIcons"):
				return get_theme_icon("Help", "EditorIcons")
		"@logs":
			var ic := _get_svg_icon(TERMINAL_SVG, 16)
			if ic: return ic
			if Engine.is_editor_hint() and has_theme_icon("FileList", "EditorIcons"):
				return get_theme_icon("FileList", "EditorIcons")
	return null


func _get_command_icon(cmd_name: String) -> Texture2D:
	if not Engine.is_editor_hint():
		return null
	match cmd_name:
		"/help":
			if has_theme_icon("HelpSearch", "EditorIcons"):
				return get_theme_icon("HelpSearch", "EditorIcons")
			elif has_theme_icon("Help", "EditorIcons"):
				return get_theme_icon("Help", "EditorIcons")
		"/selected":
			if has_theme_icon("ToolSelect", "EditorIcons"):
				return get_theme_icon("ToolSelect", "EditorIcons")
			elif has_theme_icon("Node", "EditorIcons"):
				return get_theme_icon("Node", "EditorIcons")
		"/select":
			if has_theme_icon("ToolSelect", "EditorIcons"):
				return get_theme_icon("ToolSelect", "EditorIcons")
			elif has_theme_icon("Node", "EditorIcons"):
				return get_theme_icon("Node", "EditorIcons")
		"/tree":
			if has_theme_icon("Tree", "EditorIcons"):
				return get_theme_icon("Tree", "EditorIcons")
			elif has_theme_icon("FileList", "EditorIcons"):
				return get_theme_icon("FileList", "EditorIcons")
		"/inspect":
			if has_theme_icon("Search", "EditorIcons"):
				return get_theme_icon("Search", "EditorIcons")
			elif has_theme_icon("Zoom", "EditorIcons"):
				return get_theme_icon("Zoom", "EditorIcons")
		"/tools":
			if has_theme_icon("Tools", "EditorIcons"):
				return get_theme_icon("Tools", "EditorIcons")
		"/save":
			if has_theme_icon("Save", "EditorIcons"):
				return get_theme_icon("Save", "EditorIcons")
		"/open":
			if has_theme_icon("Load", "EditorIcons"):
				return get_theme_icon("Load", "EditorIcons")
			elif has_theme_icon("Folder", "EditorIcons"):
				return get_theme_icon("Folder", "EditorIcons")
		"/remove":
			if has_theme_icon("Remove", "EditorIcons"):
				return get_theme_icon("Remove", "EditorIcons")
			elif has_theme_icon("Close", "EditorIcons"):
				return get_theme_icon("Close", "EditorIcons")
		"/run":
			if has_theme_icon("MainPlay", "EditorIcons"):
				return get_theme_icon("MainPlay", "EditorIcons")
			elif has_theme_icon("Play", "EditorIcons"):
				return get_theme_icon("Play", "EditorIcons")
		"/stop":
			if has_theme_icon("Stop", "EditorIcons"):
				return get_theme_icon("Stop", "EditorIcons")
		"/logs":
			if has_theme_icon("FileList", "EditorIcons"):
				return get_theme_icon("FileList", "EditorIcons")
			elif has_theme_icon("TextFile", "EditorIcons"):
				return get_theme_icon("TextFile", "EditorIcons")
		"/setting":
			return _get_svg_icon(SETTINGS_SVG, 14)
		"/eval":
			if has_theme_icon("GDScript", "EditorIcons"):
				return get_theme_icon("GDScript", "EditorIcons")
			elif has_theme_icon("Script", "EditorIcons"):
				return get_theme_icon("Script", "EditorIcons")
		"/doc":
			if has_theme_icon("HelpSearch", "EditorIcons"):
				return get_theme_icon("HelpSearch", "EditorIcons")
			elif has_theme_icon("Help", "EditorIcons"):
				return get_theme_icon("Help", "EditorIcons")
		"/script":
			if has_theme_icon("Script", "EditorIcons"):
				return get_theme_icon("Script", "EditorIcons")
		"/clear":
			return _get_svg_icon(TRASH_SVG, 14)
		"/error":
			return _get_svg_icon(CROSS_SVG, 14)
	return null


func _show_greeting() -> void:
	_append_message("LittleHelper", INITIAL_GREETING)


func _on_send_pressed() -> void:
	_on_prompt_submitted(prompt_input.text)


func _on_prompt_submitted(text: String) -> void:
	var clean_text := text.strip_edges()
	
	# If autocomplete was open and user typed a partial command without arguments (e.g. "/h", "/sel"):
	if autocomplete_box.visible and autocomplete_list.item_count > 0:
		var selected_indices := autocomplete_list.get_selected_items()
		var chosen_idx := selected_indices[0] if selected_indices.size() > 0 else 0
		var candidate: String = autocomplete_list.get_item_metadata(chosen_idx)
		if not clean_text.contains(" ") and candidate.begins_with(clean_text):
			clean_text = candidate
	
	_hide_autocomplete()
	
	if clean_text.is_empty():
		return
	
	prompt_input.clear()
	_append_message("You", clean_text)
	
	if clean_text == "/help":
		var lines: Array[String] = ["[b]Available Commands:[/b]"]
		for cmd in COMMANDS:
			lines.append("• [b]%s[/b] — %s" % [cmd.get("usage", cmd["name"]), cmd["desc"]])
		lines.append("\n[color=#888888]Tip: Press [b]Tab[/b] to autocomplete slash commands.[/color]")
		
		var cur_mode := mode_option.selected if is_instance_valid(mode_option) else 0
		var mode_name := mode_option.get_item_text(cur_mode) if is_instance_valid(mode_option) else "In-Engine"
		lines.append("\n[b]Mode:[/b] %s" % mode_name)
		
		_append_message("LittleHelper", "\n".join(lines))
		return
	
	if clean_text == "/clear":
		_on_clear_pressed()
		return
	
	if clean_text == "/error":
		set_error("Connection error")
		get_tree().create_timer(3.0).timeout.connect(func():
			if is_instance_valid(self):
				set_idle()
		)
		return
	
	if clean_text == "/tools":
		var defs := LittleHelperToolRegistry.get_tool_definitions()
		var lines := ["[b]Available Tools (%d):[/b]" % defs.size()]
		for d in defs:
			lines.append("• [b]%s[/b]: %s" % [d["name"], d["description"]])
		_append_message("LittleHelper", "\n".join(lines))
		return
	
	if clean_text == "/selected":
		var res := LittleHelperToolRegistry.execute_tool("get_selected_nodes", {})
		_append_message("LittleHelper", "[code]%s[/code]" % JSON.stringify(res, "\t"))
		return
	
	if clean_text == "/select" or clean_text.begins_with("/select "):
		var arg := clean_text.substr(7).strip_edges()
		var res := LittleHelperToolRegistry.execute_tool("select_node", {"node_path": arg})
		if res.has("success"):
			_append_message("LittleHelper", "[color=#66ff99]Selected node:[/color] [b]%s[/b] (%s) at [code]%s[/code]" % [res["selected_node"], res["type"], res["path"]])
		else:
			_append_message("LittleHelper", "[color=#ff7777]%s[/color]" % str(res.get("error", "Failed to select node.")))
		return
	
	if clean_text == "/tree":
		var res := LittleHelperToolRegistry.execute_tool("get_scene_tree", {})
		_append_message("LittleHelper", "[code]%s[/code]" % JSON.stringify(res, "\t"))
		return
	
	if clean_text == "/inspect" or clean_text.begins_with("/inspect "):
		var path := clean_text.substr(8).strip_edges()
		var res := LittleHelperToolRegistry.execute_tool("inspect_node", {"node_path": path})
		_append_message("LittleHelper", "[code]%s[/code]" % JSON.stringify(res, "\t"))
		return
	
	if clean_text == "/save" or clean_text.begins_with("/save "):
		var arg := clean_text.substr(5).strip_edges().to_lower()
		var res := LittleHelperToolRegistry.execute_tool("save_scene", {"all": arg == "all"})
		var msg: String = str(res.get("message", res.get("error", "Done")))
		var color := "#66ff99" if res.has("success") else "#ff7777"
		_append_message("LittleHelper", "[color=%s]%s[/color]" % [color, msg])
		return
	
	if clean_text == "/run" or clean_text.begins_with("/run "):
		var custom_path := clean_text.substr(4).strip_edges()
		var res := LittleHelperToolRegistry.execute_tool("run_project", {"scene_path": custom_path})
		var msg: String = str(res.get("message", res.get("error", "Done")))
		var color := "#66ff99" if res.has("success") else "#ff7777"
		_append_message("LittleHelper", "[color=%s]%s[/color]" % [color, msg])
		return
	
	if clean_text == "/stop":
		var res := LittleHelperToolRegistry.execute_tool("stop_project", {})
		var msg: String = str(res.get("message", res.get("error", "Done")))
		_append_message("LittleHelper", msg)
		return
	
	if clean_text == "/logs" or clean_text.begins_with("/logs "):
		var arg := clean_text.substr(5).strip_edges()
		var lines_cnt := int(arg) if arg.is_valid_int() else 35
		var res := LittleHelperToolRegistry.execute_tool("get_debug_logs", {"max_lines": lines_cnt})
		if res.has("logs"):
			_append_message("LittleHelper", "[b]Debug Logs (%s):[/b]\n[code]%s[/code]" % [res.get("log_file", "godot.log"), res["logs"]])
		else:
			_append_message("LittleHelper", str(res.get("message", res.get("error", "No logs found."))))
		return
	
	if clean_text == "/open" or clean_text.begins_with("/open "):
		var path := clean_text.substr(5).strip_edges()
		var res := LittleHelperToolRegistry.execute_tool("open_scene", {"scene_path": path})
		if res.has("success"):
			_append_message("LittleHelper", "[color=#66ff99]Opened scene:[/color] [code]%s[/code]" % res["opened_scene"])
		else:
			_append_message("LittleHelper", "[color=#ff7777]%s[/color]" % str(res.get("error", "Failed to open scene.")))
		return
	
	if clean_text == "/remove" or clean_text.begins_with("/remove "):
		var path := clean_text.substr(7).strip_edges()
		var res := LittleHelperToolRegistry.execute_tool("remove_node", {"node_path": path})
		if res.has("success"):
			_append_message("LittleHelper", "[color=#66ff99]Removed node:[/color] [b]%s[/b] from [code]%s[/code] (Ctrl+Z to undo)" % [res["removed_node"], res["parent"]])
		else:
			_append_message("LittleHelper", "[color=#ff7777]%s[/color]" % str(res.get("error", "Failed to remove node.")))
		return
	
	if clean_text == "/setting" or clean_text.begins_with("/setting "):
		var arg := clean_text.substr(8).strip_edges()
		var parts := arg.split(" ", false, 1)
		var key := parts[0] if parts.size() > 0 else ""
		var val = parts[1] if parts.size() > 1 else null
		var dict := {"setting": key}
		if val != null:
			dict["value"] = val
		var res := LittleHelperToolRegistry.execute_tool("project_setting", dict)
		_append_message("LittleHelper", "[code]%s[/code]" % JSON.stringify(res, "\t"))
		return
	
	if clean_text == "/eval" or clean_text.begins_with("/eval "):
		var code := clean_text.substr(5).strip_edges()
		var res := LittleHelperToolRegistry.execute_tool("execute_code", {"code": code})
		if res.has("success"):
			var result_str: String = JSON.stringify(res["result"], "\t") if (res["result"] is Dictionary or res["result"] is Array) else str(res["result"])
			_append_message("LittleHelper", "[color=#66ff99]Result (%s):[/color] [code]%s[/code]" % [res.get("mode", "ok"), result_str])
		else:
			_append_message("LittleHelper", "[color=#ff7777]Eval error: %s[/color]" % str(res.get("error", "Execution failed.")))
		return
	
	if clean_text == "/doc" or clean_text.begins_with("/doc "):
		var arg := clean_text.substr(5).strip_edges()
		if arg.is_empty():
			_append_message("LittleHelper", "Usage: [b]/doc <class_name>[.<method_or_property>][/b]\nExample: [code]/doc CharacterBody3D[/code] or [code]/doc CharacterBody3D.move_and_slide[/code]")
			return
		var parts := arg.split(".", false, 1)
		var c_name := parts[0]
		var sym := parts[1] if parts.size() > 1 else ""
		var res := LittleHelperToolRegistry.execute_tool("get_documentation", {
			"class_name": c_name,
			"symbol": sym
		})
		if res.has("error"):
			_append_message("LittleHelper", "[color=#ff7777]%s[/color]" % str(res["error"]))
		elif res.get("type") == "method":
			_append_message("LittleHelper", "[b]%s.%s[/b] (Method):\n[code]%s[/code]" % [res["class"], res["name"], res["signature"]])
		elif res.get("type") == "property":
			_append_message("LittleHelper", "[b]%s.%s[/b] (Property):\n[code]var %s: %s[/code] (Hint: %s)" % [res["class"], res["name"], res["name"], res["property_type"], res.get("hint_string", "")])
		elif res.get("type") == "signal":
			_append_message("LittleHelper", "[b]%s.%s[/b] (Signal):\n[code]%s[/code]" % [res["class"], res["name"], res["signature"]])
		else:
			var lines := [
				"[b]Class: %s[/b] (Inherits: %s)" % [res["class_name"], res.get("inherits", "Object")],
				"\n[b]Key Methods (%d):[/b]" % res.get("methods", []).size()
			]
			for m in res.get("methods", []):
				lines.append("  • [code]%s[/code]" % m)
			if not res.get("properties", []).is_empty():
				lines.append("\n[b]Key Properties:[/b]")
				for p in res.get("properties", []):
					lines.append("  • [code]%s[/code]" % p)
			if not res.get("signals", []).is_empty():
				lines.append("\n[b]Signals:[/b]")
				for s in res.get("signals", []):
					lines.append("  • [code]%s[/code]" % s)
			_append_message("LittleHelper", "\n".join(lines))
		return
	
	if clean_text == "/script":
		var script: Script = Utils.get_active_script()
		if not is_instance_valid(script):
			_append_message("LittleHelper", "No GDScript is currently open in the Godot Script Editor.")
			return
		var path: String = script.resource_path if script.resource_path else "Unsaved Script"
		var lines: PackedStringArray = script.source_code.split("\n")
		_append_message("LittleHelper", "[b]Active Script:[/b] [code]%s[/code] (%d lines)\n[color=#888888]Tip: Type [color=#66ccff][b]@script[/b][/color] in your prompt to include this script as context.[/color]" % [path, lines.size()])
		return
	
	# If in External Agent (MCP Bridge) mode:
	if mode_option.selected == 1:
		_append_message("LittleHelper", "LittleHelper is set to [b]External Agent (MCP Bridge)[/b] mode.\n\n• Talk to your agent in your IDE (Antigravity, Cursor, Claude Desktop) to inspect & modify Godot live.\n• To chat directly in this dock using an API key or local Ollama, open Settings (gear icon) and select [b]In-Engine Chat[/b].")
		return
	
	# Dispatch to In-Engine LLM Client
	if _llm_client:
		var context := _gather_prompt_context(clean_text)
		var full_prompt := clean_text + context
		_llm_client.send_chat(full_prompt)
	else:
		_append_message("LittleHelper", "[color=#ff6666]Error: LLM client is not initialized.[/color]")


func _on_llm_response(text: String) -> void:
	set_idle()
	_append_message("LittleHelper", text)


func _on_llm_error(error_msg: String) -> void:
	set_error("Request error")
	_append_message("LittleHelper", "[color=#ff7777]%s[/color]" % error_msg)
	get_tree().create_timer(4.0).timeout.connect(func():
		if is_instance_valid(self):
			set_idle()
	)


func _on_llm_status_changed(busy: bool, msg: String) -> void:
	if busy:
		set_busy(msg if not msg.is_empty() else "Thinking...")
	else:
		set_idle()


func _on_clear_pressed() -> void:
	chat_history.clear()
	_code_blocks.clear()
	set_idle()
	if _llm_client:
		_llm_client.clear_history()
	_show_greeting()


func _append_message(sender: String, message: String) -> void:
	var color := "#66ccff" if sender == "LittleHelper" else "#aaddaa"
	var avatar := ""
	if sender == "LittleHelper" and ResourceLoader.exists("res://addons/little_helper/icon.svg"):
		avatar = "[img=18x18]res://addons/little_helper/icon.svg[/img] "
	
	var formatted_message := message
	if sender == "You":
		var mention_regex := RegEx.new()
		if mention_regex.compile("(@[A-Za-z0-9_]+)") == OK:
			formatted_message = mention_regex.sub(formatted_message, "[color=#66ccff][b]$1[/b][/color]", true)
	elif sender == "LittleHelper" and (message.contains("```gdscript") or message.contains("```")):
		formatted_message = _inject_code_actions(message)
	
	chat_history.append_text("%s[b][color=%s]%s:[/color][/b] %s\n\n" % [avatar, color, sender, formatted_message])


func _inject_code_actions(msg: String) -> String:
	var regex := RegEx.new()
	var err := regex.compile("```(?:gdscript)?\\s*\\n([\\s\\S]*?)\\n```")
	if err != OK:
		return msg
	
	var matches := regex.search_all(msg)
	if matches.is_empty():
		return msg
	
	var result := msg
	for i in range(matches.size() - 1, -1, -1):
		var m := matches[i]
		var code_str := m.get_string(1).strip_edges()
		var block_idx := _code_blocks.size()
		_code_blocks.append(code_str)
		
		var original_block := m.get_string(0)
		var action_bar := "\n[color=#888888]Actions:[/color] [url=copy:%d][color=#66ccff][Copy][/color][/url]  |  [url=apply:%d][color=#66ffaa][Apply to Script][/color][/url]  |  [url=new_script:%d][color=#ffcc66][Save as File][/color][/url]" % [block_idx, block_idx, block_idx]
		var replacement := original_block + "\n" + action_bar
		result = result.substr(0, m.get_start()) + replacement + result.substr(m.get_end())
	
	return result


func _on_chat_meta_clicked(meta) -> void:
	var meta_str := str(meta)
	if meta_str.begins_with("copy:"):
		var idx := int(meta_str.substr(5))
		if idx >= 0 and idx < _code_blocks.size():
			DisplayServer.clipboard_set(_code_blocks[idx])
			_append_message("LittleHelper", "[color=#66ff99]Code snippet copied to clipboard.[/color]")
	elif meta_str.begins_with("apply:"):
		var idx := int(meta_str.substr(6))
		if idx >= 0 and idx < _code_blocks.size():
			var code: String = _code_blocks[idx]
			var script: Script = Utils.get_active_script()
			if not is_instance_valid(script):
				_append_message("LittleHelper", "[color=#ffcc66]Please open a script in Godot's Script Editor first to apply this code.[/color]")
				return
			
			var path: String = script.resource_path
			if path.is_empty():
				_append_message("LittleHelper", "[color=#ff7777]Active script is unsaved. Please save it first.[/color]")
				return
			
			var fa := FileAccess.open(path, FileAccess.WRITE)
			if fa:
				fa.store_string(code)
				fa.close()
				if Engine.is_editor_hint() and EditorInterface != null:
					EditorInterface.get_resource_filesystem().scan()
					script.source_code = code
					script.reload()
					EditorInterface.edit_script(script)
				_append_message("LittleHelper", "[color=#66ff99]Successfully applied code to [b]%s[/b].[/color]" % path.get_file())
			else:
				_append_message("LittleHelper", "[color=#ff7777]Failed to write to %s.[/color]" % path)
	elif meta_str.begins_with("new_script:"):
		var idx := int(meta_str.substr(11))
		if idx >= 0 and idx < _code_blocks.size():
			var code := _code_blocks[idx]
			var script_name := "new_script.gd"
			var regex := RegEx.new()
			if regex.compile("class_name\\s+([A-Za-z0-9_]+)") == OK:
				var match_res := regex.search(code)
				if match_res:
					script_name = match_res.get_string(1).to_snake_case() + ".gd"
			var save_path := "res://" + script_name
			var res := LittleHelperToolRegistry.execute_tool("write_script", {
				"file_path": save_path,
				"content": code,
				"open_in_editor": true
			})
			if res.has("success"):
				_append_message("LittleHelper", "[color=#66ff99]Saved and opened new script at [b]%s[/b].[/color]" % save_path)
			else:
				_append_message("LittleHelper", "[color=#ff7777]Error: %s[/color]" % str(res.get("error", "Failed to create script.")))


func _setup_attach_popup() -> void:
	if is_instance_valid(_attach_popup):
		return
	_attach_popup = PopupMenu.new()
	_attach_popup.name = "AttachPopup"
	add_child(_attach_popup)
	
	var ic_script := _get_svg_icon(SCRIPT_SVG, 16)
	var ic_node := _get_svg_icon(NODE_SVG, 16)
	var ic_tree := _get_svg_icon(TREE_SVG, 16)
	var ic_docs := _get_svg_icon(BOOK_SVG, 16)
	var ic_logs := _get_svg_icon(TERMINAL_SVG, 16)
	var ic_folder := _get_svg_icon(FOLDER_SVG, 16)
	var ic_bolt := _get_svg_icon(BOLT_SVG, 16)
	
	if ic_script:
		_attach_popup.add_icon_item(ic_script, "Active Script (@script)", 0)
	else:
		_attach_popup.add_item("Active Script (@script)", 0)
		
	if ic_node:
		_attach_popup.add_icon_item(ic_node, "Selected Node (@node)", 1)
	else:
		_attach_popup.add_item("Selected Node (@node)", 1)
		
	if ic_tree:
		_attach_popup.add_icon_item(ic_tree, "Scene Tree (@tree)", 2)
	else:
		_attach_popup.add_item("Scene Tree (@tree)", 2)
		
	if ic_docs:
		_attach_popup.add_icon_item(ic_docs, "Documentation (@docs)", 3)
	else:
		_attach_popup.add_item("Documentation (@docs)", 3)
		
	if ic_logs:
		_attach_popup.add_icon_item(ic_logs, "Debug Logs (@logs)", 4)
	else:
		_attach_popup.add_item("Debug Logs (@logs)", 4)
		
	_attach_popup.add_separator()
	
	if ic_folder:
		_attach_popup.add_icon_item(ic_folder, "Attach Project File...", 5)
	else:
		_attach_popup.add_item("Attach Project File...", 5)
		
	_attach_popup.add_separator()
	
	if ic_bolt:
		_attach_popup.add_icon_item(ic_bolt, "Actions Palette (/)", 6)
	else:
		_attach_popup.add_item("Actions Palette (/)", 6)
	
	_attach_popup.id_pressed.connect(_on_attach_menu_id_pressed)


func _on_attach_button_pressed() -> void:
	if not is_instance_valid(_attach_popup):
		_setup_attach_popup()
	
	_attach_popup.reset_size()
	var btn_pos := attach_button.global_position
	var popup_pos := Vector2i(int(btn_pos.x), int(btn_pos.y) - _attach_popup.size.y - 6)
	_attach_popup.popup(Rect2i(popup_pos, Vector2i.ZERO))


func _on_attach_menu_id_pressed(id: int) -> void:
	match id:
		0: _insert_mention("@script")
		1: _insert_mention("@node")
		2: _insert_mention("@tree")
		3: _insert_mention("@docs")
		4: _insert_mention("@logs")
		5: _open_file_dialog()
		6:
			prompt_input.text = "/"
			prompt_input.caret_column = 1
			prompt_input.grab_focus()
			_update_autocomplete("/")


func _insert_mention(mention: String) -> void:
	var cur := prompt_input.text
	if cur.is_empty():
		prompt_input.text = mention + " "
	else:
		if not cur.ends_with(" "):
			prompt_input.text += " "
		prompt_input.text += mention + " "
	prompt_input.caret_column = prompt_input.text.length()
	prompt_input.grab_focus()
	_hide_autocomplete()


func _open_file_dialog() -> void:
	if not is_instance_valid(_file_dialog):
		_file_dialog = FileDialog.new()
		_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
		_file_dialog.access = FileDialog.ACCESS_RESOURCES
		_file_dialog.title = "Select File to Attach"
		_file_dialog.filters = PackedStringArray([
			"*.gd ; GDScript",
			"*.tscn ; Scene",
			"*.tres ; Resource",
			"*.json, *.cfg, *.txt, *.md ; Text Data",
			"* ; All Files"
		])
		_file_dialog.file_selected.connect(_on_file_selected_to_attach)
		add_child(_file_dialog)
	
	_file_dialog.popup_centered_ratio(0.65)


func _on_file_selected_to_attach(path: String) -> void:
	_insert_mention(path)


func _setup_custom_instructions_ui() -> void:
	if not is_instance_valid(direct_ai_section):
		return
	var label := Label.new()
	label.text = "Custom Instructions / Project Persona:"
	label.add_theme_font_size_override("font_size", 12)
	direct_ai_section.add_child(label)
	
	custom_instructions_edit = TextEdit.new()
	custom_instructions_edit.custom_minimum_size = Vector2(0, 60)
	custom_instructions_edit.placeholder_text = "e.g. 2D platformer, use static typing (-> void), prefer composition, Godot 4 conventions..."
	custom_instructions_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	custom_instructions_edit.add_theme_font_size_override("font_size", 11)
	direct_ai_section.add_child(custom_instructions_edit)


func _restore_chat_history() -> void:
	if not _llm_client:
		return
	var hist: Array[Dictionary] = _llm_client.load_history()
	if hist.is_empty():
		_show_greeting()
		return
	
	chat_history.clear()
	for m in hist:
		var sender := "You" if m.get("role") == "user" else "LittleHelper"
		var content: String = str(m.get("content", ""))
		if sender == "You":
			var ctx_pos := content.find("\n\n[Active Editor Context]")
			if ctx_pos != -1:
				content = content.substr(0, ctx_pos)
		_append_message(sender, content)


func _gather_prompt_context(prompt_text: String) -> String:
	var parts: Array[String] = []
	var lower := prompt_text.to_lower()
	
	# 1. Active Script (@script)
	if lower.contains("@script") or lower.contains("@active_script"):
		var script: Script = Utils.get_active_script()
		if is_instance_valid(script):
			var path: String = script.resource_path if script.resource_path else "active_script.gd"
			var code: String = script.source_code
			if code.length() > 4000:
				code = code.substr(0, 4000) + "\n# ... (truncated for brevity)"
			parts.append("--- Active Script (%s) ---\n```gdscript\n%s\n```" % [path, code])
		else:
			parts.append("--- Active Script ---\n(No script currently open in Script Editor)")
	
	# 2. Selected Node (@node)
	if lower.contains("@node") or lower.contains("@selected"):
		var sel: EditorSelection = Utils.get_editor_selection()
		if sel:
			var nodes: Array[Node] = sel.get_selected_nodes()
			if not nodes.is_empty():
				var node_info: Array[String] = []
				for n in nodes:
					var p_str := "Node '%s' (%s) at '%s'" % [n.name, n.get_class(), n.get_path()]
					node_info.append(p_str)
				parts.append("--- Selected Node(s) ---\n" + "\n".join(node_info))
			else:
				parts.append("--- Selected Node(s) ---\n(No node currently selected)")
	
	# 3. Scene Hierarchy (@tree or @scene)
	if lower.contains("@tree") or lower.contains("@scene"):
		var root: Node = Utils.get_editor_root()
		if is_instance_valid(root):
			var tree_summary: Array[String] = [root.name + " (" + root.get_class() + ")"]
			for c in root.get_children():
				tree_summary.append("  - " + c.name + " (" + c.get_class() + ")")
			parts.append("--- Scene Hierarchy ---\n" + "\n".join(tree_summary.slice(0, 30)))
		else:
			parts.append("--- Scene Hierarchy ---\n(No open scene)")
	
	# 4. Debug Logs (@logs)
	if lower.contains("@logs"):
		var res := LittleHelperToolRegistry.execute_tool("get_debug_logs", {"lines": 25})
		if res.has("logs"):
			parts.append("--- Recent Debug Logs ---\n```\n%s\n```" % str(res["logs"]))
	
	# 5. Documentation Notice (@docs)
	if lower.contains("@docs"):
		parts.append("--- Engine Documentation Notice ---\n(User referenced engine documentation. Provide accurate Godot 4 ClassDB APIs.)")
	
	# 6. Attached Files (e.g. res://...)
	var path_regex := RegEx.new()
	if path_regex.compile("res://[^\\s,;\"'\\)]+") == OK:
		for m in path_regex.search_all(prompt_text):
			var file_path := m.get_string()
			if FileAccess.file_exists(file_path):
				var ext := file_path.get_extension().to_lower()
				if ["gd", "tscn", "tres", "json", "cfg", "txt", "md", "csv"].has(ext):
					var fa := FileAccess.open(file_path, FileAccess.READ)
					if fa:
						var content := fa.get_as_text()
						fa.close()
						if content.length() > 3000:
							content = content.substr(0, 3000) + "\n# ... (truncated)"
						parts.append("--- Attached File (%s) ---\n```\n%s\n```" % [file_path, content])
	
	if parts.is_empty():
		return ""
	return "\n\n[Active Editor Context]\n" + "\n\n".join(parts)

