# How to Use MCP Agents in Neovim

## Initial Setup

1. **Restart Neovim** (or run `:Lazy sync` in current session)
2. LazyVim will automatically install:
   - MCPHub.nvim
   - CopilotChat.nvim
3. MCP agents will auto-start when Neovim loads

## Quick Start Commands

### Open MCP Hub (see your agents)
```
:MCPHub
```
Or press: `<leader>mm` (usually `Space` then `mm`)

### Check Agent Status
```
:MCPHubStatus
```
Or press: `<leader>ms`

### Open Copilot Chat
```
:CopilotChatToggle
```
Or press: `<leader>cc`

## Using Your 3 Agents

### 1. Research Agent
**Press:** `<leader>cr` or type in chat:
```
"Research agent, what are the latest Python 3.12 features?"
"Find information about Rust async/await patterns"
"Search for MCP best practices"
```

### 2. Code Analyzer
**Press:** `<leader>ca` or type in chat:
```
"Code analyzer, scan this file for complexity issues"
"Analyze this function for performance problems"
"Check this project directory for code patterns"
```

### 3. Documentation Writer
**Press:** `<leader>cd` or type in chat:
```
"Doc writer, create a README for this project"
"Generate documentation for this function"
"Write API docs for this endpoint"
```

## Step-by-Step Example

1. **Open a file in Neovim**
   ```bash
   nvim myfile.py
   ```

2. **Open Copilot Chat**
   - Press `Space` then `cc`
   - Or type `:CopilotChatToggle`

3. **Ask an agent a question**
   In the chat window, type:
   ```
   Research agent, find the latest FastAPI features
   ```

4. **The agent will:**
   - Search the web
   - Store findings in its context memory
   - Return results to you in chat

5. **Chain agents together:**
   ```
   Research agent, find MCP best practices, then have the doc 
   writer create a guide based on what you found
   ```

## All Keybindings

| Key | Action |
|-----|--------|
| `<leader>mm` | Open MCP Hub |
| `<leader>ms` | MCP Status |
| `<leader>mr` | Restart MCP servers |
| `<leader>cc` | Toggle Copilot Chat |
| `<leader>ce` | Explain Code |
| `<leader>ct` | Generate Tests |
| `<leader>cf` | Fix Code |
| `<leader>cr` | Research Agent |
| `<leader>ca` | Code Analyzer |
| `<leader>cd` | Doc Writer |

*Note: `<leader>` is usually `Space` in LazyVim*

## Checking Agent Memory

Your agents remember things across sessions. View their memory:

```bash
# Research agent memory
cat ~/.config/github-copilot/shared-memory/research-agent-context.md

# Code analyzer memory
cat ~/.config/github-copilot/shared-memory/code-analyzer-context.md

# Doc writer memory
cat ~/.config/github-copilot/shared-memory/documentation-writer-context.md
```

## Troubleshooting

### Agents not showing up
1. Run `:MCPHubStatus` to check if servers are running
2. Run `:MCPHubRestart` to restart them
3. Check logs: `:messages` or `:checkhealth mcphub`

### Chat not responding
1. Make sure you're authenticated with Copilot: `:Copilot auth`
2. Check Copilot status: `:Copilot status`

### Need to reinstall plugins
```vim
:Lazy clean
:Lazy sync
```

## Testing Agents Work

1. Open Neovim
2. Type `:MCPHub`
3. You should see 3 servers listed:
   - research-agent
   - code-analyzer
   - documentation-writer
4. All should show as "Running" or "Connected"

## Example Workflow

```
1. Open project: nvim ~/Projects/myapp
2. Open chat: Space + cc
3. Ask: "Code analyzer, scan this project and find complex functions"
4. Wait for results
5. Ask: "Doc writer, create documentation for the complex functions 
   the analyzer found"
6. Agent uses analyzer's memory to create docs
7. Results appear in chat
```

## Advanced Usage

### Manual server control
```vim
:MCPHubStart research-agent
:MCPHubStop code-analyzer
:MCPHubRestart documentation-writer
```

### View server logs
```vim
:MCPHub
" Navigate to server > View Logs
```

### Configure custom prompts
Edit `~/.config/nvim/lua/plugins/mcphub.lua` to add more agent shortcuts.

---

**Location:** `~/.config/nvim/MCP_USAGE_GUIDE.md`
**Agent Config:** `~/.config/github-copilot/mcp.json`
**Memory Files:** `~/.config/github-copilot/shared-memory/*.md`
