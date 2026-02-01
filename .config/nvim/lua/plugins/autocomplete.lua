return {
  -- Completion engine
  {
    'saghen/blink.cmp',
    dependencies = {
      {
        "xiaket/codeium.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
        },
        opts = {},
      },
    },
    opts = {
      sources = {
        completion = {
          enabled_providers = { 'lsp', 'path', 'snippets', 'buffer', 'codeium' },
        },
        providers = {
          codeium = { name = 'Codeium', module = 'codeium.blink' },
        },
      },
    },
  }, }
