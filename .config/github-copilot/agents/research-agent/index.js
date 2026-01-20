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
import fetch from 'node-fetch';
import * as cheerio from 'cheerio';

const __dirname = dirname(fileURLToPath(import.meta.url));
const MEMORY_DIR = join(dirname(dirname(__dirname)), 'shared-memory');
const CONTEXT_FILE = join(MEMORY_DIR, 'research-agent-context.md');

// Ensure memory directory exists
if (!existsSync(MEMORY_DIR)) {
  await mkdir(MEMORY_DIR, { recursive: true });
}

// Initialize context file if it doesn't exist
if (!existsSync(CONTEXT_FILE)) {
  const initialContext = `# Research Agent Context

## Agent Info
- **Name**: Research Agent
- **Purpose**: Web research, information gathering, and summarization
- **Created**: ${new Date().toISOString()}

## Research History
(No research performed yet)

## Learned Facts
- Agent is ready to assist with research tasks

## Active Projects
None
`;
  await writeFile(CONTEXT_FILE, initialContext, 'utf-8');
}

// Helper functions
async function loadContext() {
  return await readFile(CONTEXT_FILE, 'utf-8');
}

async function updateContext(newContent) {
  const timestamp = new Date().toISOString();
  const current = await loadContext();
  const updated = current.replace(
    '## Research History',
    `## Research History\n\n### ${timestamp}\n${newContent}\n`
  );
  await writeFile(CONTEXT_FILE, updated, 'utf-8');
}

async function webSearch(query) {
  // Using DuckDuckGo HTML search (no API key needed)
  try {
    const url = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; ResearchAgent/1.0)',
      },
    });
    const html = await response.text();
    
    // Basic parsing - extract snippets
    const snippets = [];
    const regex = /<a class="result__snippet"[^>]*>([^<]+)<\/a>/g;
    let match;
    let count = 0;
    while ((match = regex.exec(html)) && count < 5) {
      snippets.push(match[1].replace(/&[^;]+;/g, ' ').trim());
      count++;
    }
    
    return snippets.length > 0 ? snippets : ['Search completed but no results extracted. Try refining query.'];
  } catch (error) {
    return [`Search error: ${error.message}`];
  }
}

async function scrapeWebpage(url, selector = null) {
  try {
    const response = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (compatible; ResearchAgent/1.0)',
      },
    });
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }
    
    const html = await response.text();
    const $ = cheerio.load(html);
    
    let result = {};
    
    if (selector) {
      // If a selector is provided, extract that specific content
      const elements = $(selector);
      result.selected = elements.map((i, el) => $(el).text().trim()).get();
      result.count = elements.length;
    } else {
      // Extract common page elements
      result.title = $('title').text().trim();
      result.headings = $('h1, h2, h3').map((i, el) => $(el).text().trim()).get().slice(0, 10);
      result.paragraphs = $('p').map((i, el) => $(el).text().trim()).get().filter(p => p.length > 50).slice(0, 5);
      result.links = $('a[href]').map((i, el) => ({
        text: $(el).text().trim(),
        href: $(el).attr('href')
      })).get().slice(0, 10);
    }
    
    return result;
  } catch (error) {
    throw new Error(`Scraping failed: ${error.message}`);
  }
}

// Create MCP server
const server = new Server(
  {
    name: 'research-agent',
    version: '1.0.0',
  },
  {
    capabilities: {
      tools: {},
      resources: {},
    },
  }
);

// Define available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: 'web_search',
        description: 'Search the web for current information and research topics. Updates agent context with findings.',
        inputSchema: {
          type: 'object',
          properties: {
            query: {
              type: 'string',
              description: 'The search query',
            },
          },
          required: ['query'],
        },
      },
      {
        name: 'summarize',
        description: 'Summarize and analyze text or information. Stores summary in agent memory.',
        inputSchema: {
          type: 'object',
          properties: {
            content: {
              type: 'string',
              description: 'The content to summarize',
            },
            format: {
              type: 'string',
              enum: ['brief', 'detailed', 'bullet-points'],
              description: 'Summary format preference',
            },
          },
          required: ['content'],
        },
      },
      {
        name: 'get_context',
        description: 'Retrieve the agent\'s full context and memory from previous research sessions',
        inputSchema: {
          type: 'object',
          properties: {},
        },
      },
      {
        name: 'add_fact',
        description: 'Add a learned fact to the agent\'s long-term memory',
        inputSchema: {
          type: 'object',
          properties: {
            fact: {
              type: 'string',
              description: 'The fact to remember',
            },
          },
          required: ['fact'],
        },
      },
      {
        name: 'scrape_webpage',
        description: 'Scrape content from a webpage. Can extract all content or use CSS selectors for specific elements.',
        inputSchema: {
          type: 'object',
          properties: {
            url: {
              type: 'string',
              description: 'The URL of the webpage to scrape',
            },
            selector: {
              type: 'string',
              description: 'Optional CSS selector to extract specific elements (e.g., ".article-content", "#main", "p.description")',
            },
          },
          required: ['url'],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  try {
    if (name === 'web_search') {
      const results = await webSearch(args.query);
      const resultText = `**Search Query**: ${args.query}\n\n**Results**:\n${results.map((r, i) => `${i + 1}. ${r}`).join('\n')}`;
      
      await updateContext(resultText);
      
      return {
        content: [
          {
            type: 'text',
            text: resultText,
          },
        ],
      };
    }

    if (name === 'summarize') {
      const format = args.format || 'brief';
      const summary = `**Summary (${format})**:\n\n${args.content.substring(0, 500)}${args.content.length > 500 ? '...' : ''}`;
      
      await updateContext(summary);
      
      return {
        content: [
          {
            type: 'text',
            text: summary,
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

    if (name === 'add_fact') {
      const current = await loadContext();
      const updated = current.replace(
        '## Learned Facts',
        `## Learned Facts\n- ${args.fact}`
      );
      await writeFile(CONTEXT_FILE, updated, 'utf-8');
      
      return {
        content: [
          {
            type: 'text',
            text: `Fact added to memory: ${args.fact}`,
          },
        ],
      };
    }

    if (name === 'scrape_webpage') {
      const data = await scrapeWebpage(args.url, args.selector);
      const resultText = `**Scraped URL**: ${args.url}\n${args.selector ? `**Selector**: ${args.selector}\n` : ''}\n**Results**:\n${JSON.stringify(data, null, 2)}`;
      
      await updateContext(resultText);
      
      return {
        content: [
          {
            type: 'text',
            text: resultText,
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
  console.error('Research Agent MCP server running on stdio');
  console.error(`Context file: ${CONTEXT_FILE}`);
}

main().catch((error) => {
  console.error('Server error:', error);
  process.exit(1);
});
