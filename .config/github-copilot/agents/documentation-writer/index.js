#!/usr/bin/env node

import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import { readFile, writeFile, mkdir } from 'fs/promises';
import { existsSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const MEMORY_DIR = join(dirname(dirname(__dirname)), 'shared-memory');
const CONTEXT_FILE = join(MEMORY_DIR, 'documentation-writer-context.md');

// Ensure memory directory exists
if (!existsSync(MEMORY_DIR)) {
  await mkdir(MEMORY_DIR, { recursive: true });
}

// Initialize context file
if (!existsSync(CONTEXT_FILE)) {
  const initialContext = `# Documentation Writer Agent Context

## Agent Info
- **Name**: Documentation Writer Agent
- **Purpose**: Create, update, and maintain technical documentation
- **Created**: ${new Date().toISOString()}

## Documentation Style Guide
- Use clear, concise language
- Include code examples when relevant
- Follow markdown best practices
- Keep audience in mind (developers, users, etc.)

## Recent Documentation Tasks
(No tasks performed yet)

## Project Documentation Templates
### API Documentation
- Endpoint description
- Parameters (required/optional)
- Request/response examples
- Error codes

### Function Documentation
- Purpose/description
- Parameters with types
- Return value
- Usage examples
- Edge cases

## Documentation Standards Learned
None yet

## Active Documentation Projects
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

function generateFunctionDoc(functionInfo) {
  const { name, params, returns, description } = functionInfo;
  
  let doc = `## ${name}\n\n`;
  if (description) doc += `${description}\n\n`;
  
  doc += `### Parameters\n`;
  if (params && params.length > 0) {
    params.forEach(p => {
      doc += `- \`${p.name}\` (${p.type})${p.required ? ' *required*' : ' *optional*'}: ${p.description || 'No description'}\n`;
    });
  } else {
    doc += `No parameters\n`;
  }
  
  doc += `\n### Returns\n`;
  doc += returns ? `\`${returns.type}\` - ${returns.description}\n` : 'void\n';
  
  doc += `\n### Example\n\`\`\`javascript\n// TODO: Add usage example\n\`\`\`\n`;
  
  return doc;
}

function generateREADME(projectInfo) {
  const { name, description, features, installation, usage } = projectInfo;
  
  let readme = `# ${name}\n\n`;
  readme += `${description || 'Project description'}\n\n`;
  
  if (features && features.length > 0) {
    readme += `## Features\n\n`;
    features.forEach(f => readme += `- ${f}\n`);
    readme += `\n`;
  }
  
  readme += `## Installation\n\n\`\`\`bash\n${installation || 'npm install'}\n\`\`\`\n\n`;
  readme += `## Usage\n\n\`\`\`javascript\n${usage || '// Add usage example'}\n\`\`\`\n\n`;
  readme += `## Contributing\n\nContributions welcome! Please read CONTRIBUTING.md first.\n\n`;
  readme += `## License\n\nMIT\n`;
  
  return readme;
}

// Create MCP server
const server = new Server(
  {
    name: 'documentation-writer',
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
        name: 'generate_function_doc',
        description: 'Generate markdown documentation for a function or method',
        inputSchema: {
          type: 'object',
          properties: {
            name: {
              type: 'string',
              description: 'Function name',
            },
            description: {
              type: 'string',
              description: 'What the function does',
            },
            params: {
              type: 'array',
              description: 'Function parameters',
              items: {
                type: 'object',
                properties: {
                  name: { type: 'string' },
                  type: { type: 'string' },
                  required: { type: 'boolean' },
                  description: { type: 'string' },
                },
              },
            },
            returns: {
              type: 'object',
              description: 'Return value info',
              properties: {
                type: { type: 'string' },
                description: { type: 'string' },
              },
            },
          },
          required: ['name'],
        },
      },
      {
        name: 'generate_readme',
        description: 'Generate a README.md file for a project',
        inputSchema: {
          type: 'object',
          properties: {
            name: {
              type: 'string',
              description: 'Project name',
            },
            description: {
              type: 'string',
              description: 'Project description',
            },
            features: {
              type: 'array',
              items: { type: 'string' },
              description: 'List of features',
            },
            installation: {
              type: 'string',
              description: 'Installation instructions',
            },
            usage: {
              type: 'string',
              description: 'Usage example',
            },
          },
          required: ['name'],
        },
      },
      {
        name: 'format_markdown',
        description: 'Format and improve markdown content following best practices',
        inputSchema: {
          type: 'object',
          properties: {
            content: {
              type: 'string',
              description: 'Markdown content to format',
            },
          },
          required: ['content'],
        },
      },
      {
        name: 'get_context',
        description: 'Retrieve the agent\'s documentation context and style guide',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'add_standard',
        description: 'Add a documentation standard or guideline to remember',
        inputSchema: {
          type: 'object',
          properties: {
            standard: {
              type: 'string',
              description: 'The documentation standard to remember',
            },
          },
          required: ['standard'],
        },
      },
      {
        name: 'create_api_doc',
        description: 'Generate API endpoint documentation',
        inputSchema: {
          type: 'object',
          properties: {
            endpoint: {
              type: 'string',
              description: 'API endpoint path (e.g., /api/users)',
            },
            method: {
              type: 'string',
              enum: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
              description: 'HTTP method',
            },
            description: {
              type: 'string',
              description: 'What this endpoint does',
            },
            params: {
              type: 'array',
              description: 'Request parameters',
            },
            response: {
              type: 'string',
              description: 'Example response',
            },
          },
          required: ['endpoint', 'method'],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === 'generate_function_doc') {
      const doc = generateFunctionDoc(args);
      await updateContext('Recent Documentation Tasks', `Generated function doc for: ${args.name}`);
      
      return {
        content: [
          {
            type: 'text',
            text: doc,
          },
        ],
      };
    }

    if (name === 'generate_readme') {
      const readme = generateREADME(args);
      await updateContext('Recent Documentation Tasks', `Generated README for: ${args.name}`);
      
      return {
        content: [
          {
            type: 'text',
            text: readme,
          },
        ],
      };
    }

    if (name === 'format_markdown') {
      // Basic formatting improvements
      let formatted = args.content;
      // Ensure proper heading spacing
      formatted = formatted.replace(/^(#{1,6})\s*/gm, '$1 ');
      // Ensure blank line before headings
      formatted = formatted.replace(/([^\n])\n(#{1,6}\s)/g, '$1\n\n$2');
      
      return {
        content: [
          {
            type: 'text',
            text: formatted,
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

    if (name === 'add_standard') {
      const current = await loadContext();
      const updated = current.replace(
        '## Documentation Standards Learned',
        `## Documentation Standards Learned\n- ${args.standard}`
      );
      await writeFile(CONTEXT_FILE, updated, 'utf-8');
      
      return {
        content: [
          {
            type: 'text',
            text: `Standard added: ${args.standard}`,
          },
        ],
      };
    }

    if (name === 'create_api_doc') {
      const { endpoint, method, description, params, response } = args;
      
      let doc = `## ${method} ${endpoint}\n\n`;
      doc += `${description || 'API endpoint'}\n\n`;
      
      if (params && params.length > 0) {
        doc += `### Parameters\n`;
        params.forEach(p => {
          doc += `- \`${p.name}\` (${p.type}): ${p.description}\n`;
        });
        doc += `\n`;
      }
      
      doc += `### Response\n\`\`\`json\n${response || '{\n  "status": "success"\n}'}\n\`\`\`\n`;
      
      await updateContext('Recent Documentation Tasks', `Created API doc: ${method} ${endpoint}`);
      
      return {
        content: [
          {
            type: 'text',
            text: doc,
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
  console.error('Documentation Writer Agent MCP server running on stdio');
  console.error(`Context file: ${CONTEXT_FILE}`);
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
