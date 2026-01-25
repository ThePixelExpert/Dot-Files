return {
  {
    "ravitemer/mcphub.nvim",
    lazy = false,
    priority = 100,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua",
    config = function()
      vim.env.PATH = vim.env.HOME .. "/.local/npm-global/bin:" .. vim.env.PATH

      require("mcphub").setup({
        use_bundled_binary = true,
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
    end,

    cmd = { "MCPHub", "MCPHubStart", "MCPHubStop", "MCPHubRestart", "MCPHubStatus" },
    keys = {
      { "<leader>mm", "<cmd>MCPHub<cr>", desc = "Open MCP Hub" },
      { "<leader>ms", "<cmd>MCPHubStatus<cr>", desc = "MCP Status" },
      { "<leader>mr", "<cmd>MCPHubRestart<cr>", desc = "MCP Restart" },
    },
  },
}
