return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      -- Accept suggestion with Ctrl+L
      vim.keymap.set("i", "<C-l>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
      })
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
    end,
  },
}
