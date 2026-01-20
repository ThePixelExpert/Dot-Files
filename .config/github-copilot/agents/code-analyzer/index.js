#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { readFile, writeFile, mkdir, readdir, stat } from 'fs/promises';
import { existsSync } from 'fs';
import { join, dirname, extname } from 'path';
import { fileURLToPath } from 'url';
import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

const __dirname = dirname(fileURLToPath(import.meta.url));
const MEMORY_DIR = join(dirname(dirname(__dirname)), 'shared-memory');
const CONTEXT_FILE = join(MEMORY_DIR, 'code-analyzer-context.md');

// Ensure memory directory exists
if (!existsSync(MEMORY_DIR)) {
  await mkdir(MEMORY_DIR, { recursive: true });
}

// Initialize context file
if (!existsSync(CONTEXT_FILE)) {
  const initialContext = `# Code Analyzer Agent Context

## Agent Info
- **Name**: Code Analyzer Agent
- **Purpose**: Analyze code structure, patterns, complexity, and quality
- **Created**: ${new Date().toISOString()}

## Analysis History
(No analysis performed yet)

## Code Patterns Identified
None

## Known Issues & Recommendations
None

## Project Insights
None
`;
  await writeFile(CONTEXT_FILE, initialContext, 'utf-8');
}

// Helper functions
async function loadContext() {
  return await readFile(CONTEXT_FILE, 'utf-8');
}

async function updateContext(section, newContent) {
  const timestamp = new Date().toISOString();
  const current = await loadContext();
  const updated = current.replace(
    `## ${section}`,
    `## ${section}\n\n### ${timestamp}\n${newContent}\n`
  );
  await writeFile(CONTEXT_FILE, updated, 'utf-8');
}

async function analyzeCode(code, language) {
  const lines = code.split('\n');
  const analysis = {
    lines: lines.length,
    nonEmpty: lines.filter(l => l.trim()).length,
    comments: lines.filter(l => l.trim().startsWith('//')).length,
    functions: (code.match(/function\s+\w+|const\s+\w+\s*=\s*\(|=>\s*{/g) || []).length,
    complexity: 'Low',
  };
  
  // Simple complexity heuristic
  const branches = (code.match(/if\s*\(|for\s*\(|while\s*\(|switch\s*\(/g) || []).length;
  if (branches > 10) analysis.complexity = 'High';
  else if (branches > 5) analysis.complexity = 'Medium';
  
  return analysis;
}

async function scanDirectory(dirPath, extensions = ['.js', '.ts', '.py', '.java', '.go']) {
  const results = [];
  
  async function scan(dir) {
    try {
      const entries = await readdir(dir, { withFileTypes: true });
      
      for (const entry of entries) {
        const fullPath = join(dir, entry.name);
        
        if (entry.isDirectory() && !entry.name.startsWith('.') && entry.name !== 'node_modules') {
          await scan(fullPath);
        } else if (entry.isFile() && extensions.includes(extname(entry.name))) {
          const stats = await stat(fullPath);
          results.push({
            path: fullPath,
            size: stats.size,
            extension: extname(entry.name),
          });
        }
      }
    } catch (error) {
      // Skip inaccessible directories
    }
  }
  
  await scan(dirPath);
  return results;
}

async function executeCode(code, language, timeout = 30000) {
  const languageCommands = {
    'python': 'python3 -c',
    'py': 'python3 -c',
    'javascript': 'node -e',
    'js': 'node -e',
    'bash': 'bash -c',
    'sh': 'bash -c',
    'ruby': 'ruby -e',
    'rb': 'ruby -e',
  };
  
  const cmd = languageCommands[language.toLowerCase()];
  if (!cmd) {
    throw new Error(`Unsupported language: ${language}. Supported: ${Object.keys(languageCommands).join(', ')}`);
  }
  
  try {
    const { stdout, stderr } = await execAsync(`${cmd} ${JSON.stringify(code)}`, {
      timeout,
      maxBuffer: 1024 * 1024, // 1MB
    });
    return { stdout, stderr, error: null };
  } catch (error) {
    return {
      stdout: error.stdout || '',
      stderr: error.stderr || '',
      error: error.message,
    };
  }
}

async function executeShellCommand(command, cwd = null, timeout = 30000) {
  try {
    const options = { timeout, maxBuffer: 1024 * 1024 };
    if (cwd) options.cwd = cwd;
    
    const { stdout, stderr } = await execAsync(command, options);
    return { stdout, stderr, error: null };
  } catch (error) {
    return {
      stdout: error.stdout || '',
      stderr: error.stderr || '',
      error: error.message,
    };
  }
}

async function createFile(path, content) {
  try {
    // Ensure parent directory exists
    const dir = dirname(path);
    if (!existsSync(dir)) {
      await mkdir(dir, { recursive: true });
    }
    
    await writeFile(path, content, 'utf-8');
    return { success: true, path };
  } catch (error) {
    throw new Error(`Failed to create file: ${error.message}`);
  }
}

async function readFileContent(path) {
  try {
    const content = await readFile(path, 'utf-8');
    return { success: true, content };
  } catch (error) {
    throw new Error(`Failed to read file: ${error.message}`);
  }
}

// Create MCP server
const server = new Server(
  {
    name: 'code-analyzer',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// Define available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'analyze_code',
        description: 'Analyze code snippet for complexity, structure, and patterns. Stores analysis in agent memory.',
        inputSchema: {
          type: 'object',
          properties: {
            code: {
              type: 'string',
              description: 'The code to analyze',
            },
            language: {
              type: 'string',
              description: 'Programming language (js, py, java, etc.)',
            },
          },
          required: ['code'],
        },
      },
      {
        name: 'scan_project',
        description: 'Scan a project directory to analyze code structure and generate insights',
        inputSchema: {
          type: 'object',
          properties: {
            path: {
              type: 'string',
              description: 'Path to project directory',
            },
          },
          required: ['path'],
        },
      },
      {
        name: 'get_context',
        description: 'Retrieve the agent\'s full context and memory from previous analysis sessions',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'add_pattern',
        description: 'Record a code pattern or anti-pattern identified during analysis',
        inputSchema: {
          type: 'object',
          properties: {
            pattern: {
              type: 'string',
              description: 'Description of the pattern',
            },
            severity: {
              type: 'string',
              enum: ['info', 'warning', 'critical'],
              description: 'Severity level',
            },
          },
          required: ['pattern'],
        },
      },
      {
        name: 'recommend',
        description: 'Add a recommendation to improve code quality',
        inputSchema: {
          type: 'object',
          properties: {
            recommendation: {
              type: 'string',
              description: 'The recommendation',
            },
          },
          required: ['recommendation'],
        },
      },
      {
        name: 'execute_code',
        description: 'Execute code snippet and return output. Supports Python, JavaScript, Bash, and Ruby.',
        inputSchema: {
          type: 'object',
          properties: {
            code: {
              type: 'string',
              description: 'The code to execute',
            },
            language: {
              type: 'string',
              enum: ['python', 'py', 'javascript', 'js', 'bash', 'sh', 'ruby', 'rb'],
              description: 'Programming language',
            },
            timeout: {
              type: 'number',
              description: 'Timeout in milliseconds (default: 30000)',
            },
          },
          required: ['code', 'language'],
        },
      },
      {
        name: 'run_shell',
        description: 'Execute shell command and return output. Use with caution.',
        inputSchema: {
          type: 'object',
          properties: {
            command: {
              type: 'string',
              description: 'Shell command to execute',
            },
            cwd: {
              type: 'string',
              description: 'Working directory (optional)',
            },
            timeout: {
              type: 'number',
              description: 'Timeout in milliseconds (default: 30000)',
            },
          },
          required: ['command'],
        },
      },
      {
        name: 'create_file',
        description: 'Create a new file with specified content. Creates parent directories if needed.',
        inputSchema: {
          type: 'object',
          properties: {
            path: {
              type: 'string',
              description: 'File path (absolute or relative)',
            },
            content: {
              type: 'string',
              description: 'File content',
            },
          },
          required: ['path', 'content'],
        },
      },
      {
        name: 'read_file',
        description: 'Read contents of a file',
        inputSchema: {
          type: 'object',
          properties: {
            path: {
              type: 'string',
              description: 'File path to read',
            },
          },
          required: ['path'],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === 'analyze_code') {
      const analysis = await analyzeCode(args.code, args.language || 'unknown');
      const report = `**Code Analysis**:
- Language: ${args.language || 'auto-detected'}
- Lines: ${analysis.lines} (${analysis.nonEmpty} non-empty)
- Comments: ${analysis.comments}
- Functions: ${analysis.functions}
- Complexity: ${analysis.complexity}`;
      
      await updateContext('Analysis History', report);
      
      return {
        content: [
          {
            type: 'text',
            text: report,
          },
        ],
      };
    }

    if (name === 'scan_project') {
      const files = await scanDirectory(args.path);
      const byExtension = {};
      let totalSize = 0;
      
      files.forEach(f => {
        byExtension[f.extension] = (byExtension[f.extension] || 0) + 1;
        totalSize += f.size;
      });
      
      const report = `**Project Scan**: ${args.path}
- Total files: ${files.length}
- Total size: ${(totalSize / 1024).toFixed(2)} KB
- By type: ${Object.entries(byExtension).map(([ext, count]) => `${ext}: ${count}`).join(', ')}`;
      
      await updateContext('Project Insights', report);
      
      return {
        content: [
          {
            type: 'text',
            text: report,
          },
        ],
      };
    }

    if (name === 'get_context') {
      const context = await loadContext();
      return {
        content: [
          {
            type: 'text',
            text: context,
          },
        ],
      };
    }

    if (name === 'add_pattern') {
      const severity = args.severity || 'info';
      const current = await loadContext();
      const updated = current.replace(
        '## Code Patterns Identified',
        `## Code Patterns Identified\n- [${severity.toUpperCase()}] ${args.pattern}`
      );
      await writeFile(CONTEXT_FILE, updated, 'utf-8');
      
      return {
        content: [
          {
            type: 'text',
            text: `Pattern recorded: ${args.pattern}`,
          },
        ],
      };
    }

    if (name === 'recommend') {
      const current = await loadContext();
      const updated = current.replace(
        '## Known Issues & Recommendations',
        `## Known Issues & Recommendations\n- ${args.recommendation}`
      );
      await writeFile(CONTEXT_FILE, updated, 'utf-8');
      
      return {
        content: [
          {
            type: 'text',
            text: `Recommendation added: ${args.recommendation}`,
          },
        ],
      };
    }

    if (name === 'execute_code') {
      const result = await executeCode(args.code, args.language, args.timeout);
      const output = `**Code Execution (${args.language})**:

\`\`\`
${args.code}
\`\`\`

**Output:**
${result.stdout || '(no output)'}

${result.stderr ? `**Stderr:**\n${result.stderr}\n` : ''}${result.error ? `**Error:**\n${result.error}` : ''}`;
      
      await updateContext('Analysis History', output);
      
      return {
        content: [
          {
            type: 'text',
            text: output,
          },
        ],
      };
    }

    if (name === 'run_shell') {
      const result = await executeShellCommand(args.command, args.cwd, args.timeout);
      const output = `**Shell Command**: \`${args.command}\`${args.cwd ? `\n**Working Directory**: ${args.cwd}` : ''}

**Output:**
${result.stdout || '(no output)'}

${result.stderr ? `**Stderr:**\n${result.stderr}\n` : ''}${result.error ? `**Error:**\n${result.error}` : ''}`;
      
      await updateContext('Analysis History', output);
      
      return {
        content: [
          {
            type: 'text',
            text: output,
          },
        ],
      };
    }

    if (name === 'create_file') {
      const result = await createFile(args.path, args.content);
      const output = `**File Created**: ${result.path}\n**Size**: ${args.content.length} bytes`;
      
      await updateContext('Analysis History', output);
      
      return {
        content: [
          {
            type: 'text',
            text: output,
          },
        ],
      };
    }

    if (name === 'read_file') {
      const result = await readFileContent(args.path);
      const output = `**File**: ${args.path}\n**Size**: ${result.content.length} bytes\n\n**Content:**\n\`\`\`\n${result.content}\n\`\`\``;
      
      return {
        content: [
          {
            type: 'text',
            text: output,
          },
        ],
      };
    }

    throw new Error(`Unknown tool: ${name}`);
  } catch (error) {
    return {
      content: [
        {
          type: 'text',
          text: `Error: ${error.message}`,
        },
      ],
      isError: true,
    };
  }
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error('Code Analyzer Agent MCP server running on stdio');
  console.error(`Context file: ${CONTEXT_FILE}`);
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
