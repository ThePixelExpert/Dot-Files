return {
  {
    "ravitemer/mcphub.nvim",
    lazy = false,
    priority = 100,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.env.PATH = vim.env.HOME .. "/.local/npm-global/bin:" .. vim.env.PATH

      require("mcphub").setup({
        config = vim.fn.expand("~/.config/mcphub/servers.json"),
        auto_toggle_mcp_servers = true,

        model = "gpt-4o", -- ✅ MOVE IT HERE (inside setup)

        extensions = {
          copilotchat = {
            enabled = true,
            convert_tools_to_functions = true,
            convert_resources_to_functions = true,
            add_mcp_prefix = false,
          },
        },

        log = {
          level = vim.log.levels.INFO,
        },
      })

      vim.defer_fn(function()
        require("mcphub.extensions.copilotchat.functions").register({
          enabled = true,
          convert_tools_to_functions = true,
          convert_resources_to_functions = true,
          add_mcp_prefix = false,
        })
      end, 5000)
    end,
    cmd = { "MCPHub", "MCPHubStart", "MCPHubStop", "MCPHubRestart", "MCPHubStatus" },
    keys = {
      { "<leader>mm", "<cmd>MCPHub<cr>", desc = "Open MCP Hub" },
      { "<leader>ms", "<cmd>MCPHubStatus<cr>", desc = "MCP Status" },
      { "<leader>mr", "<cmd>MCPHubRestart<cr>", desc = "MCP Restart" },
    },
  },
}
