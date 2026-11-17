# Changelog

All notable changes to **LittleHelper** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.2.0] - 2026-11-17

### 🚀 Highlights
- **In-Engine 1-Click Updater**: Check for updates and download/extract the latest release directly inside the dock Settings drawer via Godot 4's native `ZIPReader`.
- **PascalCase Addon Restructure**: Renamed addon root directory to `addons/LittleHelper/` following Godot's standard addon naming convention.
- **Defensive Startup Diagnosis**: Automatic guard detecting legacy lowercase `addons/little_helper/` folders to alert users and prevent duplicate class conflicts.
- **Hybrid Clean Namespacing**: Internal tool modules now use preload-only architecture to prevent polluting the user's "Create New Node" dialog, while core APIs retain clean `LittleHelper*` prefixes.
- **Editor Command Palette Integration**: Registered Godot Command Palette shortcuts (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>) to quickly focus the dock, open settings, or check for updates.
- **Default Demo Scene**: Added a lightweight `demo.tscn` so launching the project with <kbd>F5</kbd> runs cleanly without missing scene errors.

---

### ✨ Added
- **Plugin Updates Drawer**: Added a dedicated update checker in the dock Settings panel that queries GitHub Releases and performs in-engine replacement of plugin files.
- **Godot Command Palette Actions**:
  - `LittleHelper: Focus Dock`: Immediately focuses the dock prompt input.
  - `LittleHelper: Open Settings`: Opens the settings overlay panel.
  - `LittleHelper: Check for Updates`: Triggers GitHub release verification.
- **Legacy Folder Warning Guard**: Detects leftover `addons/little_helper/` directories on startup and pops up an advisory dialog.
- **Default Main Scene**: Created `demo.tscn` and registered `run/main_scene="res://demo.tscn"` in `project.godot`.

### 🔧 Changed
- **Folder Casing**: Standardized root addon folder to `addons/LittleHelper/` and release archive to `LittleHelper.zip`.
- **Namespace Cleanliness**: Removed global `class_name` definitions from internal scripts (`scene_tools.gd`, `node_tools.gd`, `project_tools.gd`, `code_tools.gd`, `tool_utils.gd`) to keep the user's project namespace 100% clean.
- **Settings Typography**: Removed hardcoded small font overrides in settings drawer so custom instructions and updater elements scale naturally with Godot's editor theme and HiDPI displays.
- **Release Packaging**: Added exclusions (`-x "*.DS_Store" "*Thumbs.db"`) in `.github/workflows/release.yml`.

---

## [1.1.0] - 2026-11-16

### 🚀 Highlights
- **Modern Prompt & Context System**: Streamlined prompt bar with intelligent `@` mentions (`@script`, `@node`, `@tree`, `@docs`, `@logs`) and a `+` attach menu for files, scenes, and actions.
- **Custom Line Iconography**: Completely replaced all emojis across the dock with clean, professional white-stroke line SVGs from SVG Repo.
- **Expanded Tool Suite (24 Tools)**: Added `write_script`, `patch_script`, `get_documentation`, and `create_resource` for full script lifecycle and resource instantiation with Undo/Redo.
- **Interactive Code Actions**: Generated code blocks now feature one-click `[Copy]`, `[Apply to Script]`, and `[Save as File]` buttons directly in the chat stream.
- **Updated Model Support**: Automatic sanitization for Google Gemini models and updated defaults to modern Gemini models (`gemini-flash-lite-latest`, `gemini-3.1-flash-lite`).

---

### ✨ Added
- **`@` Context Mentions Palette**: Type `@` anywhere in the prompt to open an inline autocomplete picker:
  - `@script`: Injects the active GDScript currently open in Godot's Script Editor.
  - `@node`: Injects selected node properties, class, and hierarchy path.
  - `@tree`: Injects active scene tree structure.
  - `@docs`: References engine ClassDB documentation standards.
  - `@logs`: Injects recent Godot debug and error logs.
- **`+` Attach Button & File Browser**:
  - Popup menu with quick shortcuts to attach context or trigger actions.
  - Built-in `FileDialog` to attach any `.gd`, `.tscn`, `.tres`, or data file from `res://` directly into prompts.
- **4 New MCP & Engine Tools**:
  - `write_script`: Programmatically create or update `.gd` scripts, rescan the editor filesystem, and open in the Script Editor.
  - `patch_script`: Perform surgical targeted search-and-replace edits on GDScript files without rewriting entire scripts.
  - `get_documentation`: Inspect Godot 4 class hierarchies, methods, signatures, properties, and signals from `ClassDB`.
  - `create_resource`: Instantiate Resources (e.g., `BoxShape3D`, `StandardMaterial3D`, `BoxMesh`), configure properties, and attach them to nodes or save to `.tres` with full Undo/Redo.
- **New In-Engine Slash Commands**:
  - `/doc <class>[.<symbol>]`: Look up Godot 4 API documentation directly in the dock.
  - `/script`: Inspect the active GDScript open in the editor.
- **Interactive Code Actions**: Clickable action links (`[Copy]`, `[Apply to Script]`, `[Save as File]`) injected into AI GDScript response blocks.
- **Custom Instructions & Persona**: Custom prompt/persona setting field in settings panel, injected into system prompts.
- **Persistent Chat History**: Automatically saves and restores conversation history (`user://little_helper_chat_history.json`).
- **Vector Iconography**: Added clean white-stroke line SVGs (`plus.svg`, `script.svg`, `node.svg`, `tree.svg`, `book.svg`, `terminal.svg`, `folder.svg`, `bolt.svg`, `copy.svg`).

### 🔧 Changed
- Replaced ambiguous toggle pill buttons with a clean, modern prompt bar (`Ask anything, @ to mention, / for actions`).
- Enhanced autocomplete navigation: <kbd>↑</kbd> / <kbd>↓</kbd> to navigate, <kbd>Tab</kbd> or <kbd>Enter</kbd> to apply token.
- Sanitized Google Gemini model requests to strip accidental `models/` prefixes and updated default model to `gemini-flash-lite-latest`.
- Updated release packaging workflow to attach POSIX `.zip` archives directly via `softprops/action-gh-release@v3` (Node 24).

### 🐛 Fixed
- Fixed untyped variant warnings and syntax issues in Godot 4.8 beta.
- Fixed 404 API error on Google Gemini caused by deprecated 1.5 model IDs on `v1beta`.

---

## [1.0.0] - 2026-10-24

### Initial Release
- **In-Engine AI Chat**: Direct LLM pair-programming inside Godot dock supporting OpenAI, Anthropic Claude, Google Gemini, DeepSeek, and local Ollama.
- **External Agent MCP Bridge**: Built-in Model Context Protocol server exposing 20 core Godot tools to external IDEs (Antigravity, Cursor, Claude Desktop).
- **Scene & Node Hierarchy Tools**: `get_selected_nodes`, `get_scene_tree`, `inspect_node`, `select_node`, `add_node`, `remove_node`, `instantiate_scene`, `reparent_node`, `set_node_property`, `connect_signal`, `attach_script`.
- **Project & Lifecycle Tools**: `save_scene`, `open_scene`, `run_project`, `stop_project`, `get_debug_logs`, `project_setting`, `execute_code`.
- **Slash Commands**: Command palette with `/help`, `/tree`, `/inspect`, `/selected`, `/select`, `/run`, `/stop`, `/logs`, `/setting`, `/eval`, `/save`, `/open`, `/remove`, `/tools`, `/clear`.
