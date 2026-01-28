return {
  {
    "kndndrj/nvim-anthropic",
    opts = {
      -- Your custom options here
      api_key = os.getenv("ANTHROPIC_API_KEY"),
      model = "claude-sonnet-4-5-20250929",
      -- Add MCP server configs if needed
    },
  },
}
