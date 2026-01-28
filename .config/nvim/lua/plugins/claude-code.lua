-- In your lazy.nvim plugin spec file (usually ~/.config/nvim/lua/plugins/claudecode.lua or similar)
return {
  {
    "kndndrj/nvim-anthropic",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      api_key = os.getenv("ANTHROPIC_API_KEY"),
    },
  },
}
