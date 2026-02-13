return {
  -- Real-time autocomplete (ghost text)
  -- Chat & advanced AI features with Claude



  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp",
      "stevearc/dressing.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = { adapter = "anthropic" },
          inline = { adapter = "anthropic" },
          agent = { adapter = "anthropic" },
        },
        adapters = {
          anthropic = function()
            return require("codecompanion.adapters").extend("anthropic", {
              env = { api_key = "ANTHROPIC_API_KEY" },
              schema = {
                model = { default = "claude-sonnet-4-5-20250929" },
              },
            })
          end,
        },
        display = {
          chat = {
            window = {
              width = 0.2 -- 30% of screen width (use 0.2-0.4 to adjust)
            },
          },
        },
      })

      -- Keybindings
      vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle Chat" })
      vim.keymap.set("v", "<leader>cc", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle Chat" })
      vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
      vim.keymap.set("v", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
    end,
  },
}
