@tool
class_name LittleHelperCodeTools
extends RefCounted

## ClassDB query, GDScript reading, and in-editor dynamic execution tools.

const Utils = preload("res://addons/little_helper/src/tools/tool_utils.gd")

static func get_tools() -> Array[Dictionary]:
	return [
		{
			"name": "get_class_info",
			"description": "Queries Godot's built-in ClassDB for class properties, methods, signals, and inheritance.",
			"parameters": {
				"type": "object",
				"properties": {
					"class_name": {
						"type": "string",
						"description": "Name of the Godot class (e.g. 'CharacterBody2D', 'Area3D', 'GPUParticles2D')."
					}
				},
				"required": ["class_name"]
			}
		},
		{
			"name": "read_script",
			"description": "Reads GDScript code from a file in the project with optional line range.",
			"parameters": {
				"type": "object",
				"properties": {
					"file_path": {
						"type": "string",
						"description": "Path to the script file (e.g. 'res://player.gd')."
					},
					"start_line": {
						"type": "integer",
						"description": "First line to read (1-indexed)."
					},
					"end_line": {
						"type": "integer",
						"description": "Last line to read (inclusive)."
					}
				},
				"required": ["file_path"]
			}
		},
		{
			"name": "execute_code",
			"description": "Executes a GDScript code snippet or expression inside the Godot editor, with access to the active scene root.",
			"parameters": {
				"type": "object",
				"properties": {
					"code": {
						"type": "string",
						"description": "GDScript expression (e.g. 'root.get_child_count()') or multi-line statement block to execute."
					}
				},
				"required": ["code"]
			}
		},
		{
			"name": "write_script",
			"description": "Creates or completely overwrites a GDScript file (.gd) in the project and opens it in Godot's Script Editor.",
			"parameters": {
				"type": "object",
				"properties": {
					"file_path": {
						"type": "string",
						"description": "Path to the script file (e.g. 'res://player.gd' or 'res://scripts/combat/hitbox.gd')."
					},
					"content": {
						"type": "string",
						"description": "Full GDScript source code to write."
					},
					"open_in_editor": {
						"type": "boolean",
						"description": "Whether to open the script in the Godot script editor (default: true)."
					}
				},
				"required": ["file_path", "content"]
			}
		},
		{
			"name": "patch_script",
			"description": "Patches a GDScript file by replacing an exact targeted code snippet or function with new code.",
			"parameters": {
				"type": "object",
				"properties": {
					"file_path": {
						"type": "string",
						"description": "Path to the script file (e.g. 'res://player.gd')."
					},
					"target": {
						"type": "string",
						"description": "Exact text or function block to replace."
					},
					"replacement": {
						"type": "string",
						"description": "The new replacement code."
					}
				},
				"required": ["file_path", "target", "replacement"]
			}
		},
		{
			"name": "get_documentation",
			"description": "Fetches Godot 4 API documentation, method signatures, properties, and signals from ClassDB.",
			"parameters": {
				"type": "object",
				"properties": {
					"class_name": {
						"type": "string",
						"description": "Godot class name (e.g. 'CharacterBody3D', 'NavigationAgent2D', 'Node')."
					},
					"symbol": {
						"type": "string",
						"description": "Optional method, property, or signal name to inspect in detail (e.g. 'move_and_slide')."
					}
				},
				"required": ["class_name"]
			}
		}
	]


static func has_tool(tool_name: String) -> bool:
	return tool_name in [
		"get_class_info", "read_script", "execute_code",
		"write_script", "patch_script", "get_documentation"
	]


static func execute(tool_name: String, args: Dictionary) -> Dictionary:
	match tool_name:
		"get_class_info":
			return _get_class_info(args)
		"read_script":
			return _read_script(args)
		"execute_code":
			return _execute_code(args)
		"write_script":
			return _write_script(args)
		"patch_script":
			return _patch_script(args)
		"get_documentation":
			return _get_documentation(args)
	return {"error": "Tool '%s' not found in CodeTools" % tool_name}


static func _get_class_info(args: Dictionary) -> Dictionary:
	var c_name: String = str(args.get("class_name", "")).strip_edges()
	if c_name.is_empty():
		return {"error": "Parameter 'class_name' is required."}
	
	if not ClassDB.class_exists(c_name):
		return {"error": "Class '%s' does not exist in Godot's ClassDB." % c_name}
	
	var parent_class := ClassDB.get_parent_class(c_name)
	
	var methods := []
	for m in ClassDB.class_get_method_list(c_name, true):
		methods.append(m["name"])
	
	var properties := []
	for p in ClassDB.class_get_property_list(c_name, true):
		properties.append(p["name"])
	
	var signals := []
	for s in ClassDB.class_get_signal_list(c_name, true):
		signals.append(s["name"])
	
	return {
		"class_name": c_name,
		"parent_class": parent_class,
		"can_instantiate": ClassDB.can_instantiate(c_name),
		"methods_count": methods.size(),
		"methods": methods.slice(0, 40),
		"properties_count": properties.size(),
		"properties": properties.slice(0, 40),
		"signals": signals
	}


static func _read_script(args: Dictionary) -> Dictionary:
	var path: String = str(args.get("file_path", "")).strip_edges()
	if path.is_empty():
		return {"error": "Parameter 'file_path' is required."}
	
	if not path.begins_with("res://") and not path.begins_with("user://"):
		path = "res://" + path
	
	if not FileAccess.file_exists(path):
		return {"error": "Script file not found: %s" % path}
	
	var fa := FileAccess.open(path, FileAccess.READ)
	if not fa:
		return {"error": "Failed to open script file: %s" % path}
	
	var content := fa.get_as_text()
	fa.close()
	
	var lines := content.split("\n")
	var total_lines := lines.size()
	
	var start_line: int = int(args.get("start_line", 1))
	var end_line: int = int(args.get("end_line", total_lines))
	
	start_line = clampi(start_line, 1, total_lines)
	end_line = clampi(end_line, start_line, total_lines)
	
	var slice := lines.slice(start_line - 1, end_line)
	return {
		"file_path": path,
		"total_lines": total_lines,
		"start_line": start_line,
		"end_line": end_line,
		"content": "\n".join(slice)
	}


static func _execute_code(args: Dictionary) -> Dictionary:
	var code_str: String = str(args.get("code", "")).strip_edges()
	if code_str.is_empty():
		return {"error": "Parameter 'code' is required."}
	
	var root := Utils.get_editor_root()
	var is_statement := code_str.contains("\n") or code_str.begins_with("var ") or code_str.begins_with("return ") or code_str.begins_with("for ") or code_str.begins_with("if ") or code_str.begins_with("while ")
	
	if not is_statement:
		var expr := Expression.new()
		var parse_err := expr.parse(code_str, ["root"])
		if parse_err == OK:
			var result = expr.execute([root], root)
			if not expr.has_execute_failed():
				return {"success": true, "result": Utils.sanitize_variant(result), "mode": "expression"}
	
	# Wrap in dynamic script
	var script := GDScript.new()
	var lines := code_str.split("\n")
	var indented_lines := []
	for l in lines:
		indented_lines.append("\t" + l)
	var method_body := "\n".join(indented_lines)
	
	script.source_code = "@tool\nextends RefCounted\n\nfunc execute(root: Node):\n" + method_body + "\n"
	var reload_err := script.reload()
	if reload_err != OK:
		return {"error": "Failed to compile GDScript (code %d)" % reload_err}
	
	var inst = script.new()
	var res = inst.execute(root)
	return {"success": true, "result": Utils.sanitize_variant(res), "mode": "script"}


static func _write_script(args: Dictionary) -> Dictionary:
	var path: String = str(args.get("file_path", "")).strip_edges()
	if path.is_empty():
		return {"error": "Parameter 'file_path' is required."}
	if not path.begins_with("res://") and not path.begins_with("user://"):
		path = "res://" + path
	if not path.ends_with(".gd"):
		path += ".gd"
	
	var content: String = str(args.get("content", ""))
	var dir := path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	
	var fa := FileAccess.open(path, FileAccess.WRITE)
	if not fa:
		return {"error": "Failed to open file for writing at %s" % path}
	fa.store_string(content)
	fa.close()
	
	var open_in_editor: bool = bool(args.get("open_in_editor", true))
	if Engine.is_editor_hint() and EditorInterface != null:
		EditorInterface.get_resource_filesystem().scan()
		if open_in_editor:
			var res = load(path)
			if res is Script:
				EditorInterface.edit_script(res)
	
	var lines := content.split("\n")
	return {
		"success": true,
		"file_path": path,
		"line_count": lines.size(),
		"opened_in_editor": open_in_editor
	}


static func _patch_script(args: Dictionary) -> Dictionary:
	var path: String = str(args.get("file_path", "")).strip_edges()
	if path.is_empty():
		return {"error": "Parameter 'file_path' is required."}
	if not path.begins_with("res://") and not path.begins_with("user://"):
		path = "res://" + path
	
	if not FileAccess.file_exists(path):
		return {"error": "Script file not found: %s" % path}
	
	var target: String = str(args.get("target", ""))
	if target.is_empty():
		return {"error": "Parameter 'target' is required."}
	var replacement: String = str(args.get("replacement", ""))
	
	var fa := FileAccess.open(path, FileAccess.READ)
	if not fa:
		return {"error": "Could not read file: %s" % path}
	var text := fa.get_as_text()
	fa.close()
	
	if not text.contains(target):
		return {"error": "Target snippet was not found in %s." % path}
	
	var new_text := text.replace(target, replacement)
	var fw := FileAccess.open(path, FileAccess.WRITE)
	if not fw:
		return {"error": "Failed to write patched script: %s" % path}
	fw.store_string(new_text)
	fw.close()
	
	if Engine.is_editor_hint() and EditorInterface != null:
		EditorInterface.get_resource_filesystem().scan()
		var res = load(path)
		if res is Script:
			EditorInterface.edit_script(res)
	
	return {
		"success": true,
		"file_path": path,
		"target_found": true
	}


static func _get_documentation(args: Dictionary) -> Dictionary:
	var c_name: String = str(args.get("class_name", "")).strip_edges()
	if c_name.is_empty():
		return {"error": "Parameter 'class_name' is required."}
	if not ClassDB.class_exists(c_name):
		return {"error": "Class '%s' does not exist in Godot's ClassDB." % c_name}
	
	var symbol: String = str(args.get("symbol", "")).strip_edges()
	var parent := ClassDB.get_parent_class(c_name)
	
	if not symbol.is_empty():
		# Check methods
		for m in ClassDB.class_get_method_list(c_name, true):
			if m["name"] == symbol:
				var args_formatted := []
				for a in m.get("args", []):
					args_formatted.append("%s: %s" % [a["name"], type_string(a["type"])])
				var ret_type := type_string(m.get("return", {}).get("type", TYPE_NIL))
				return {
					"class": c_name,
					"type": "method",
					"name": symbol,
					"signature": "func %s(%s) -> %s" % [symbol, ", ".join(args_formatted), ret_type],
					"flags": m.get("flags", 0)
				}
		# Check properties
		for p in ClassDB.class_get_property_list(c_name, true):
			if p["name"] == symbol:
				return {
					"class": c_name,
					"type": "property",
					"name": symbol,
					"property_type": type_string(p["type"]),
					"hint": p.get("hint", 0),
					"hint_string": p.get("hint_string", "")
				}
		# Check signals
		for s in ClassDB.class_get_signal_list(c_name, true):
			if s["name"] == symbol:
				var s_args := []
				for a in s.get("args", []):
					s_args.append("%s: %s" % [a["name"], type_string(a["type"])])
				return {
					"class": c_name,
					"type": "signal",
					"name": symbol,
					"signature": "signal %s(%s)" % [symbol, ", ".join(s_args)]
				}
		return {"error": "Symbol '%s' not found on class '%s'." % [symbol, c_name]}
	
	# Class Overview
	var methods_list := []
	for m in ClassDB.class_get_method_list(c_name, false):
		var args_formatted := []
		for a in m.get("args", []):
			args_formatted.append("%s: %s" % [a["name"], type_string(a["type"])])
		var ret_type := type_string(m.get("return", {}).get("type", TYPE_NIL))
		methods_list.append("func %s(%s) -> %s" % [m["name"], ", ".join(args_formatted), ret_type])
	
	var props_list := []
	for p in ClassDB.class_get_property_list(c_name, false):
		if not (p["usage"] & PROPERTY_USAGE_CATEGORY or p["usage"] & PROPERTY_USAGE_GROUP or p["usage"] & PROPERTY_USAGE_SUBGROUP):
			props_list.append("var %s: %s" % [p["name"], type_string(p["type"])])
	
	var signals_list := []
	for s in ClassDB.class_get_signal_list(c_name, false):
		var s_args := []
		for a in s.get("args", []):
			s_args.append("%s: %s" % [a["name"], type_string(a["type"])])
		signals_list.append("signal %s(%s)" % [s["name"], ", ".join(s_args)])
	
	return {
		"class_name": c_name,
		"inherits": parent,
		"can_instantiate": ClassDB.can_instantiate(c_name),
		"methods": methods_list.slice(0, 30),
		"properties": props_list.slice(0, 30),
		"signals": signals_list
	}


