return {
  {
    enabled = false,
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = false,
      show_help = "yes",
      question_header = "## User ",
      answer_header = "## Copilot ",
      error_header = "## Error ",
      auto_follow_cursor = true,
      auto_insert_mode = false,
      clear_chat_on_new_prompt = false,
      highlight_selection = true,
      model = "gpt-4o",
      temperature = 0.1,
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      chat.setup(opts)
    end,
    event = "VeryLazy",
    keys = {
      {
        "<leader>cc",
        function()
          require("CopilotChat").toggle()
        end,
        desc = "Toggle Copilot Chat",
        mode = { "n", "v" },
      },
      {
        "<leader>ce",
        "<cmd>CopilotChatExplain<cr>",
        desc = "Explain Code",
        mode = { "n", "v" },
      },
      {
        "<leader>ct",
        "<cmd>CopilotChatTests<cr>",
        desc = "Generate Tests",
        mode = { "n", "v" },
      },
      {
        "<leader>cf",
        "<cmd>CopilotChatFix<cr>",
        desc = "Fix Code",
        mode = { "n", "v" },
      },
    },
  },
}
