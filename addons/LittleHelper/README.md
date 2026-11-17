# 🤖 LittleHelper for Godot 4

<p align="center">
  <img src="icon.svg" width="96" height="96" alt="LittleHelper Icon" />
  <br>
  <strong>In-Engine AI Copilot & Model Context Protocol (MCP) Bridge for Godot 4</strong>
  <br><br>
  <a href="https://github.com/bbs220/little-helper/actions/workflows/release.yml"><img src="https://github.com/bbs220/little-helper/actions/workflows/release.yml/badge.svg" alt="Package & Release Addon ZIP" /></a>
  <a href="https://github.com/bbs220/little-helper/releases/latest"><img src="https://img.shields.io/github/v/release/bbs220/little-helper?color=478cbf&label=Release" alt="Release" /></a>
  <br><br>
  <a href="https://github.com/bbs220/little-helper/releases"><strong>📦 Download Latest Release (.zip)</strong></a>
</p>

**LittleHelper** is a lightweight, zero-dependency Godot 4 editor plugin that bridges the gap between your game engine and modern AI models. It works in two flexible modes:

1. **In-Engine AI Chat:** Pair-program directly inside the Godot editor using your favorite LLM (OpenAI, Anthropic Claude, Google Gemini, DeepSeek, local Ollama, or custom OpenAI-compatible endpoints).
2. **External Agent (MCP Bridge):** Connect autonomous AI coding agents (Antigravity, Cursor, Claude Desktop) directly to your running Godot editor via the open [Model Context Protocol (MCP)](https://modelcontextprotocol.io/).

---

## ✨ Features

- **🎮 24 Native Engine Tools:** Live scene inspection, node creation/removal, scene instantiation, reparenting, property editing, resource creation, script writing/patching, signal wiring, project settings, ClassDB reflection, GDScript evaluation, scene management, project execution, and debug log tailing.
- **📄 Direct Script Writing & Patching:** Write full `.gd` scripts to disk or patch targeted functions with one-click **[Apply to Script]** directly from chat code blocks.
- **📎 Context Mentions (@) & Attachments (+):** Reference your active script (`@script`), selected node (`@node`), scene hierarchy (`@tree`), API docs (`@docs`), or debug logs (`@logs`) directly in prompts, or attach any project asset via the `+` menu.
- **↩️ Full Undo / Redo:** Scene and resource modifications (`add_node`, `remove_node`, `instantiate_scene`, `reparent_node`, `set_node_property`, `create_resource`, `attach_script`, `connect_signal`) integrate with Godot's `EditorUndoRedoManager` (`Ctrl+Z` / `Ctrl+Y`).
- **📚 In-Engine API Docs:** Look up real Godot 4 class methods, property signatures, and signals using the `/doc` command and `get_documentation` tool to eliminate hallucinated syntax.
- **⚙️ Custom Instructions / Persona:** Set custom developer rules in Settings (e.g. static typing, specific architecture, 2D/3D project conventions).
- **💾 Persistent Chat Sessions:** Chat history persists automatically across editor restarts in `user://little_helper_chat_history.json`.
- **⚡ Slash Commands:** Quick editor shortcuts with autocompletion (`/selected`, `/select`, `/tree`, `/inspect`, `/tools`, `/doc`, `/script`, `/save`, `/open`, `/remove`, `/run`, `/stop`, `/logs`, `/setting`, `/eval`, `/clear`).
- **🔒 Secure Credentials:** API keys are stored exclusively in `user://little_helper_settings.cfg`—never in `res://` or source control.
- **📦 Zero External Dependencies:** In-engine chat uses Godot's native `HTTPRequest`. The MCP bridge uses standard Node.js built-ins (`net`, `readline`). No `npm install` or third-party packages required.

---

## 📋 Compatibility & Requirements

- **Engine:** Godot 4.2+ (Tested on Godot 4.3 & 4.4).
- **In-Engine Chat:** **Zero external dependencies.** Uses Godot's built-in `HTTPRequest`.
- **MCP Bridge (Optional):** Requires [Node.js](https://nodejs.org/) (v18+ recommended) installed on your system only if you want to connect external agents (Cursor, Claude Desktop, Antigravity) via stdio MCP.

---

## 🚀 Quick Start

### 1. Installation
1. Download `LittleHelper.zip` from the [GitHub Releases](https://github.com/bbs220/little-helper/releases) page (or clone the repository).
2. Extract the `addons/LittleHelper` folder into your Godot project's `addons/` directory.
3. In the Godot editor, open **Project → Project Settings → Plugins**.
4. Enable the **LittleHelper** plugin.
5. The LittleHelper dock will appear in your editor docks (usually beside the Inspector or FileSystem).

### 2. Updating LittleHelper

Your API keys and chat history are stored in `user://` (outside the project directory), so they are never lost during updates.

- **Option A: In-Engine 1-Click Update (Recommended)**
  1. Click the **Settings** gear icon in the LittleHelper dock.
  2. Under **Plugin Updates**, click **Check for Updates**.
  3. When an update is detected, click **Download & Install Update**, then reload your project or restart Godot.

- **Option B: Manual ZIP Update**
  1. In Godot, go to **Project → Project Settings → Plugins** and disable **LittleHelper**.
  2. Delete the existing `addons/LittleHelper/` folder (or legacy `addons/little_helper/` if upgrading from < v1.2.0).
  3. Extract the new `LittleHelper.zip` into your `addons/` directory.
  4. Re-enable **LittleHelper** in Project Settings.

---

## 🛠️ Operating Modes

Open the **Settings drawer** (gear icon in the top header) to choose your operating mode:

### Mode 1: In-Engine Chat
Chat directly with an AI assistant inside the dock.
- **Supported Providers:**
  - **OpenAI:** `gpt-4o`, `gpt-4o-mini`, etc.
  - **Anthropic Claude:** `claude-3-5-sonnet-20241022`, etc.
  - **Google Gemini:** `gemini-flash-lite-latest`, `gemini-3.1-flash-lite`, `gemini-3-flash-preview`, etc.
  - **DeepSeek:** `deepseek-chat`, `deepseek-coder`
  - **Ollama (Local Offline):** `llama3`, `mistral`, `qwen2.5-coder`, etc.
  - **Custom Endpoint:** Any OpenAI-compatible server (LM Studio, LocalAI, vLLM, OpenRouter).

### Mode 2: External Agent (MCP Bridge)
Turn your Godot editor into an MCP server. External AI coding assistants can inspect and modify your project live while you work.

Add the following to your agent's MCP configuration (`mcp_config.json` or `claude_desktop_config.json`):

```json
{
  "mcpServers": {
    "godot-little-helper": {
      "command": "node",
      "args": [
        "addons/LittleHelper/bridge/mcp_bridge.js"
      ],
      "env": {
        "GODOT_PORT": "9099"
      }
    }
  }
}
```
*(Tip: You can click the **"Copy MCP Config"** button inside the LittleHelper settings drawer to copy your project's exact absolute path snippet).*

### Mode 3: Dual Mode
Both In-Engine Chat and the External MCP Bridge run concurrently.

---

## 📎 Context Mentions (`@`) & Attachments (`+`)

LittleHelper features a modern, intuitive copilot prompt interface (`Ask anything, @ to mention, / for actions`):

* **`+` Attach Button:** Click the `+` button beside the prompt to instantly attach the active script, selected node, scene hierarchy, debug logs, or browse project files (`.gd`, `.tscn`, `.tres`).
* **`@` Mentions:** Type `@` anywhere in your message to trigger the context autocomplete menu:
  - **`@script`**: Injects the active GDScript currently open in Godot's Script Editor.
  - **`@node`**: Injects the currently selected node(s), class, and inspector properties.
  - **`@tree`**: Injects the active scene hierarchy summary.
  - **`@docs`**: Injects Godot 4 engine API references from ClassDB.
  - **`@logs`**: Injects recent Godot engine debug & error logs.
  - **`res://...`**: Directly attach any project file path in your prompt.

---

## ⌨️ Slash Commands

Type `/` in the prompt input to open the command autocomplete menu:

| Command | Usage | Description |
| :--- | :--- | :--- |
| `/help` | `/help` | Show all commands and dock status |
| `/selected` | `/selected` | Inspect currently selected node(s) |
| `/select` | `/select <node_path>` | Select and focus a node in the scene tree & inspector |
| `/tree` | `/tree` | View full scene hierarchy |
| `/inspect` | `/inspect <node_path>` | Inspect node properties, transform, and script |
| `/tools` | `/tools` | List all 24 registered engine & MCP tools |
| `/doc` | `/doc <class>[.<symbol>]` | Fetch Godot 4 class/method API documentation |
| `/script` | `/script` | Inspect currently active GDScript in script editor |
| `/save` | `/save [all]` | Save the active scene (or `/save all` for all open scenes) |
| `/open` | `/open <scene_path>` | Open a scene (`.tscn`) in the editor tab |
| `/remove` | `/remove <node_path>` | Remove a node from scene with Undo/Redo |
| `/run` | `/run [scene_path]` | Run main project scene (or custom scene path) in debug mode |
| `/stop` | `/stop` | Stop the running debug instance |
| `/logs` | `/logs [lines]` | Tail recent engine output and error logs (`godot.log`) |
| `/setting` | `/setting <name_or_prefix> [value]` | Get, set, or search ProjectSettings (`project.godot`) |
| `/eval` | `/eval <code>` | Evaluate a GDScript expression or code block |
| `/clear` | `/clear` | Clear conversation history |

---

## 🧰 Registered MCP Tools

When connected via MCP, external agents have access to 24 real-time tools:

### Scene & Node Hierarchy
1. `get_selected_nodes`: Get currently selected editor nodes.
2. `get_scene_tree`: Traverse full node hierarchy with configurable `max_depth`.
3. `inspect_node`: Detailed node metadata, export properties, scripts, and configuration warnings.
4. `select_node`: Programmatically select and focus a node in Godot's inspector.
5. `add_node`: Instantiate and attach new child nodes with Undo/Redo.
6. `remove_node`: Delete nodes from the active scene with Undo/Redo.
7. `instantiate_scene`: Spawn packed sub-scene instances (`.tscn`) into the hierarchy with Undo/Redo.
8. `reparent_node`: Move nodes to a new parent in the active scene with Undo/Redo.
9. `set_node_property`: Mutate properties (types, vectors, colors) with Undo/Redo.
10. `create_resource`: Instantiate Resources (e.g. `BoxShape3D`, `StandardMaterial3D`, `BoxMesh`) and assign to nodes or save to disk with Undo/Redo.
11. `connect_signal`: Wire signals between nodes with Undo/Redo.
12. `attach_script`: Assign a GDScript file to a node with Undo/Redo.

### Scene & Project Lifecycle
13. `save_scene`: Save active scene or all modified scenes to disk.
14. `open_scene`: Open and switch active editor scene from path.
15. `run_project`: Launch debug instance of main scene or specified `.tscn`.
16. `stop_project`: Kill the running debug instance.
17. `get_debug_logs`: Tail the Godot engine log file (`user://logs/godot.log`).
18. `project_setting`: Get, set, or search project settings in `project.godot`.

### Reflection & Code Execution
19. `get_class_info`: Query Godot's built-in `ClassDB` for methods, properties, and signals.
20. `get_documentation`: Inspect full Godot 4 API documentation with exact method signatures and property types.
21. `read_script`: Read source code of any GDScript with optional line ranges.
22. `write_script`: Write or create complete GDScript files directly on disk and open them in Script Editor.
23. `patch_script`: Replace targeted code blocks or functions in existing scripts.
24. `execute_code`: Execute a dynamic GDScript snippet or expression inside the editor with scene root access.

---

## 📁 Directory Structure

```text
addons/LittleHelper/
├── plugin.cfg                  # Plugin metadata & editor registration
├── little_helper.gd            # Plugin lifecycle entry script
├── icon.svg                    # Mascot avatar & editor icon
├── LICENSE.txt                 # MIT License
├── README.md                   # Plugin documentation
├── demo/
│   └── demo.tscn               # Standalone test/welcome scene (F5)
├── bridge/
│   └── mcp_bridge.js           # Lightweight Node.js stdio MCP bridge
├── src/
│   ├── core/
│   │   ├── tool_registry.gd    # Central tool dispatcher & aggregator
│   │   └── bridge_server.gd    # Localhost TCP JSON-RPC bridge server
│   ├── tools/
│   │   ├── tool_utils.gd       # Shared engine utilities & variant sanitizing
│   │   ├── scene_tools.gd      # Scene hierarchy inspection & selection
│   │   ├── node_tools.gd       # Node creation, reparenting & Undo/Redo mutations
│   │   ├── project_tools.gd    # Scene lifecycle, debug logs & ProjectSettings
│   │   └── code_tools.gd       # ClassDB reflection & dynamic GDScript evaluation
│   ├── agent/
│   │   └── llm_client.gd       # Native HTTPRequest multi-provider LLM client
│   └── ui/
│       ├── little_helper_dock.gd   # Dock controller & slash command handling
│       └── little_helper_dock.tscn # Dock user interface & settings panel
└── icons/                      # Custom vector UI icons
```

---

## 📄 License

MIT License. Free to use, modify, and distribute in any personal or commercial Godot project.

