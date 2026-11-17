@tool
extends EditorPlugin

const DOCK_SCENE_PATH := "res://addons/LittleHelper/src/ui/little_helper_dock.tscn"
const BridgeServer = preload("res://addons/LittleHelper/src/core/bridge_server.gd")

var dock_instance: Control = null
var bridge_server_instance: Node = null

func _enable_plugin() -> void:
	_mount_dock()
	_start_bridge_server()

func _disable_plugin() -> void:
	_stop_bridge_server()
	_unmount_dock()

func _enter_tree() -> void:
	_check_legacy_folder()
	if is_instance_valid(dock_instance):
		_unmount_dock()
	_mount_dock()
	_start_bridge_server()
	_register_command_palette()

func _check_legacy_folder() -> void:
	if DirAccess.dir_exists_absolute("res://addons/little_helper"):
		push_warning("[LittleHelper] Legacy folder 'res://addons/little_helper' detected alongside 'res://addons/LittleHelper'. Please delete the old folder from the FileSystem dock to prevent duplicate class conflicts.")
		print_rich("[color=#ff6666][b][LittleHelper WARNING][/b][/color] Legacy folder [b]'res://addons/little_helper'[/b] detected alongside [b]'res://addons/LittleHelper'[/b]. Please delete the old folder to prevent duplicate class errors.")
		if DisplayServer.get_name() != "headless" and Engine.is_editor_hint():
			call_deferred("_show_legacy_folder_dialog")

func _show_legacy_folder_dialog() -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "LittleHelper: Legacy Folder Warning"
	dialog.dialog_text = "Legacy folder 'res://addons/little_helper' was detected alongside 'res://addons/LittleHelper'.\n\nTo prevent duplicate class definitions and broken references, please delete the old 'addons/little_helper' folder from your FileSystem dock."
	dialog.confirmed.connect(func(): dialog.queue_free())
	dialog.canceled.connect(func(): dialog.queue_free())
	var base_control: Control = null
	if has_method("get_editor_interface"):
		var editor_if = get_editor_interface()
		if editor_if and editor_if.has_method("get_base_control"):
			base_control = editor_if.get_base_control()
	if base_control:
		base_control.add_child(dialog)
		dialog.popup_centered()

func _exit_tree() -> void:
	_unregister_command_palette()
	_stop_bridge_server()
	_unmount_dock()

func _mount_dock() -> void:
	if is_instance_valid(dock_instance):
		return
	
	if not ResourceLoader.exists(DOCK_SCENE_PATH):
		push_error("[LittleHelper] Dock scene not found at %s" % DOCK_SCENE_PATH)
		return
	
	var dock_scene: PackedScene = load(DOCK_SCENE_PATH)
	if dock_scene == null or not dock_scene.can_instantiate():
		push_error("[LittleHelper] Failed to instantiate dock scene.")
		return
	
	var instance := dock_scene.instantiate()
	if not instance is Control:
		push_error("[LittleHelper] Root node of dock scene must be a Control.")
		instance.free()
		return
	
	dock_instance = instance
	dock_instance.name = "LittleHelper"
	
	if dock_instance.has_signal("settings_saved"):
		dock_instance.connect("settings_saved", _on_settings_saved)
	
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_instance)
	print_rich("[color=#66ccff][b][LittleHelper][/b][/color] Enabled and dock mounted.")

func _unmount_dock() -> void:
	if not is_instance_valid(dock_instance):
		dock_instance = null
		return
	
	if dock_instance.has_signal("settings_saved") and dock_instance.is_connected("settings_saved", _on_settings_saved):
		dock_instance.disconnect("settings_saved", _on_settings_saved)
	
	if dock_instance.is_inside_tree():
		remove_control_from_docks(dock_instance)
	
	dock_instance.free()
	dock_instance = null
	print_rich("[color=#ff9966][b][LittleHelper][/b][/color] Disabled and dock completely removed.")

func _start_bridge_server() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load("user://little_helper_settings.cfg")
	var enabled := true
	var port := 9099
	if err == OK:
		enabled = bool(cfg.get_value("bridge", "enabled", true))
		port = int(cfg.get_value("bridge", "port", 9099))
	
	if not enabled:
		_stop_bridge_server()
		return
	
	if is_instance_valid(bridge_server_instance):
		if bridge_server_instance.active_port != port:
			bridge_server_instance.start_server(port)
		return
	
	bridge_server_instance = BridgeServer.new()
	bridge_server_instance.name = "LittleHelperBridgeServer"
	add_child(bridge_server_instance)
	bridge_server_instance.start_server(port)

func _stop_bridge_server() -> void:
	if is_instance_valid(bridge_server_instance):
		bridge_server_instance.stop_server()
		bridge_server_instance.queue_free()
		bridge_server_instance = null

func _on_settings_saved() -> void:
	_start_bridge_server()


func _register_command_palette() -> void:
	if not Engine.is_editor_hint() or DisplayServer.get_name() == "headless":
		return
	var cp := EditorInterface.get_command_palette()
	if not cp:
		return
	cp.add_command("LittleHelper: Focus Dock", "little_helper/focus_dock", Callable(self, "_cmd_focus_dock"))
	cp.add_command("LittleHelper: Open Settings", "little_helper/open_settings", Callable(self, "_cmd_open_settings"))
	cp.add_command("LittleHelper: Check for Updates", "little_helper/check_updates", Callable(self, "_cmd_check_updates"))


func _unregister_command_palette() -> void:
	if not Engine.is_editor_hint() or DisplayServer.get_name() == "headless":
		return
	var cp := EditorInterface.get_command_palette()
	if not cp:
		return
	cp.remove_command("little_helper/focus_dock")
	cp.remove_command("little_helper/open_settings")
	cp.remove_command("little_helper/check_updates")


func _cmd_focus_dock() -> void:
	if is_instance_valid(dock_instance):
		var prompt: LineEdit = dock_instance.get_node_or_null("%PromptInput")
		if prompt:
			prompt.grab_focus()


func _cmd_open_settings() -> void:
	if is_instance_valid(dock_instance) and dock_instance.has_method("_open_settings"):
		dock_instance._open_settings()


func _cmd_check_updates() -> void:
	if is_instance_valid(dock_instance):
		if dock_instance.has_method("_open_settings"):
			dock_instance._open_settings()
		if dock_instance.has_method("_on_check_updates_pressed"):
			dock_instance._on_check_updates_pressed()

