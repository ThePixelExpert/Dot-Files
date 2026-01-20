# Quick Reference: Using Your MCP Agents

## ✅ What You Have

**3 AI Agents** integrated with GitHub Copilot:
1. 🔍 **Research Agent** - Web search & information gathering
2. 📊 **Code Analyzer** - Code analysis & project scanning  
3. 📝 **Documentation Writer** - README, API docs, function docs

## 🎯 How To Use Them

### In VS Code with Copilot Chat:

**Direct delegation:**
```
"Research agent, what are the latest FastAPI features?"
"Code analyzer, scan my project at ~/Projects/webapp"
"Doc writer, create a README for a tool called 'LogParser'"
```

**Chained tasks:**
```
"Have the research agent find MCP best practices, then ask the 
doc writer to create a guide based on those findings"
```

**Context-aware requests:**
```
"Code analyzer, what patterns did you find in my last scan?"
"Research agent, what facts have you learned about Python async?"
```

## 📁 Context Files (Persistent Memory)

All agent memories stored as markdown:
```
~/.config/github-copilot/shared-memory/
├── research-agent-context.md
├── code-analyzer-context.md
└── documentation-writer-context.md
```

**View context:**
```bash
cat ~/.config/github-copilot/shared-memory/research-agent-context.md
```

## 🛠️ Agent Tools Quick List

### Research Agent
- `web_search(query)` - Search the web
- `summarize(content, format)` - Summarize text
- `get_context()` - View memory
- `add_fact(fact)` - Store a fact

### Code Analyzer  
- `analyze_code(code, language)` - Analyze code snippet
- `scan_project(path)` - Scan project directory
- `add_pattern(pattern, severity)` - Record pattern
- `recommend(recommendation)` - Add recommendation
- `get_context()` - View memory

### Documentation Writer
- `generate_function_doc(name, params, returns)` - Function docs
- `generate_readme(name, description, features)` - README
- `create_api_doc(endpoint, method, params)` - API docs
- `format_markdown(content)` - Format markdown
- `add_standard(standard)` - Remember doc standard
- `get_context()` - View style guide

## 🔄 How It Actually Works

1. You ask Copilot something in chat
2. Copilot recognizes you want to use an agent
3. Copilot calls the agent's tool via MCP
4. Agent processes the request
5. Agent updates its context.md file
6. Agent returns results to Copilot
7. Copilot shows you the results

**The magic**: Next time you ask, the agent remembers what it learned!

## ⚡ Quick Test

```bash
# Test if agents start correctly
node ~/.config/github-copilot/agents/research-agent/index.js
# Should see: "Research Agent MCP server running on stdio"
# Ctrl+C to exit
```

## 📝 Example Conversation

```
You: "Research agent, find information about Rust async/await"

Copilot: *calls research-agent.web_search("Rust async await")*
         *agent stores results in context.md*
         
         "Found 5 results about Rust async/await:
          1. Async/await syntax basics...
          2. Tokio runtime..."

You: "Now doc writer, create a README explaining what you just learned"

Copilot: *calls research-agent.get_context() to fetch research*
         *calls documentation-writer.generate_readme(...)*
         *doc writer stores task in its context.md*
         
         "# Rust Async/Await Guide
          
          ## Overview
          ..."
```

## 🎓 Next Steps

1. **Restart VS Code** to activate agents
2. **Try asking Copilot** to use the agents
3. **Check context files** to see memory updates
4. **Read the full guide**: `~/.config/github-copilot/AGENT_GUIDE.md`

---

**Config**: `~/.config/github-copilot/mcp.json`
**Agents**: `~/.config/github-copilot/agents/*/index.js`
**Memory**: `~/.config/github-copilot/shared-memory/*.md`
