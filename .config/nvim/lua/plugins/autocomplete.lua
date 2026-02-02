return {
  "supermaven-inc/supermaven-nvim",
  opts = {
    keymaps = {
      accept_suggestion = "<C-l>",
      clear_suggestion = "<C-]>",
      accept_word = "<C-j>",
    },
    ignore_filetypes = { cpp = true }, -- optional: disable for specific filetypes
    color = {
      suggestion_color = "#ffffff",
      cterm = 244,
    },
  },
}
