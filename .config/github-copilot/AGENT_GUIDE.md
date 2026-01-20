# MCP Agents Setup Guide

## Overview

You now have **3 specialized AI agents** that work with GitHub Copilot using the Model Context Protocol (MCP). Each agent has **persistent memory** stored in markdown files.

## Your Agents

### 1. Research Agent
**Location**: `~/.config/github-copilot/agents/research-agent/`
**Context File**: `~/.config/github-copilot/shared-memory/research-agent-context.md`

**Capabilities**:
- `web_search` - Search the web for current information
- `summarize` - Summarize and analyze text
- `get_context` - Retrieve agent's memory
- `add_fact` - Store facts in long-term memory

**Example Usage**:
```
You: "Research agent, search for the latest Python 3.12 features"
Copilot: *delegates to research agent* → results stored in context
```

### 2. Code Analyzer Agent
**Location**: `~/.config/github-copilot/agents/code-analyzer/`
**Context File**: `~/.config/github-copilot/shared-memory/code-analyzer-context.md`

**Capabilities**:
- `analyze_code` - Analyze code complexity and structure
- `scan_project` - Scan entire project directories
- `get_context` - Retrieve previous analysis
- `add_pattern` - Record code patterns found
- `recommend` - Store improvement recommendations

**Example Usage**:
```
You: "Code analyzer, scan my project at ~/Projects/myapp"
Copilot: *delegates to analyzer* → insights stored in context
```

### 3. Documentation Writer Agent
**Location**: `~/.config/github-copilot/agents/documentation-writer/`
**Context File**: `~/.config/github-copilot/shared-memory/documentation-writer-context.md`

**Capabilities**:
- `generate_function_doc` - Create function documentation
- `generate_readme` - Generate README files
- `create_api_doc` - Document API endpoints
- `format_markdown` - Format markdown content
- `get_context` - Retrieve style guide and standards
- `add_standard` - Store documentation standards

**Example Usage**:
```
You: "Doc writer, create a README for my project called 'DataFlow'"
Copilot: *delegates to doc writer* → generates formatted README
```

## How It Works

### Agent Delegation
When you chat with Copilot, you can ask it to delegate tasks to these agents:

```
You: "Hey, can you have the research agent look up MCP best practices, 
      then have the doc writer create a guide based on what it finds?"

Copilot will:
1. Call research-agent's web_search tool
2. Research agent stores findings in its context.md
3. Call documentation-writer's generate_readme tool
4. Doc writer uses the research and stores the doc task in its context
```

### Persistent Memory
Each agent maintains a **markdown context file** that persists across sessions:

- **Research Agent**: Stores search history, learned facts, active projects
- **Code Analyzer**: Stores analysis history, identified patterns, recommendations
- **Doc Writer**: Stores documentation tasks, style guides, standards

### Context Updates
Agents automatically update their context files when:
- You use their tools
- They complete tasks
- You ask them to remember something

**View an agent's memory**:
```bash
cat ~/.config/github-copilot/shared-memory/research-agent-context.md
```

## Configuration File
**Location**: `~/.config/github-copilot/mcp.json`

This file tells GitHub Copilot about your agents. VS Code/Copilot reads this on startup.

## Testing Your Agents

### Test Research Agent
```bash
cd ~/.config/github-copilot/agents/research-agent
node index.js
# Should output: "Research Agent MCP server running on stdio"
# Press Ctrl+C to stop
```

### Test Code Analyzer
```bash
cd ~/.config/github-copilot/agents/code-analyzer
node index.js
# Should output: "Code Analyzer Agent MCP server running on stdio"
# Press Ctrl+C to stop
```

### Test Doc Writer
```bash
cd ~/.config/github-copilot/agents/documentation-writer
node index.js
# Should output: "Documentation Writer Agent MCP server running on stdio"
# Press Ctrl+C to stop
```

## Using in VS Code

1. **Restart VS Code** to load the MCP configuration
2. **Open Copilot Chat**
3. **Ask Copilot to use agents**:
   - "Use the research agent to find..."
   - "Have the code analyzer check..."
   - "Ask the doc writer to create..."

## Project-Specific Agents

For project-specific agents, create `.mcp/agent.js` in your project root and add to your project's config.

**Example**: Create a Django-specific agent for a Django project that knows your models, views, and URL patterns.

## Customization

### Add More Tools
Edit the agent's `index.js` file and add new tools to the `ListToolsRequestSchema` handler.

### Change Memory Format
The markdown context files are fully customizable. Edit the initial template in each agent's `index.js`.

### Add API Keys
Some tools (like advanced web search) need API keys. Add them to the `env` section in `mcp.json`:

```json
{
  "mcpServers": {
    "research-agent": {
      "command": "node",
      "args": ["..."],
      "env": {
        "BRAVE_API_KEY": "your-key-here"
      }
    }
  }
}
```

## Troubleshooting

### Agents not appearing in Copilot
- Restart VS Code
- Check `mcp.json` syntax
- Verify agent paths are correct

### Agent errors
- Check agent logs in terminal when running manually
- Verify all dependencies installed (`npm install`)
- Check memory directory permissions

### Context not persisting
- Verify `~/.config/github-copilot/shared-memory/` exists
- Check file permissions
- Ensure agents have write access

## Next Steps

1. **Try the agents** - Ask Copilot to use them in a conversation
2. **Check the context files** - See how agents remember information
3. **Customize** - Add your own tools and memory sections
4. **Create project agents** - Build specialized agents for your projects

## Resources

- MCP Documentation: https://modelcontextprotocol.io
- GitHub Copilot Agent Mode: https://docs.github.com/copilot/agent-mode
- Your agent context files: `~/.config/github-copilot/shared-memory/*.md`

---

**Created**: ${new Date().toISOString()}
**Location**: `~/.config/github-copilot/AGENT_GUIDE.md`
