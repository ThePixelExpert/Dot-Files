return {
  {
    "catppuccin/nvim",
    optional = true,
    opts = { integrations = { bufferline = false } },
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        show_buffer_close_icons = false,
        show_close_icon = false,
        separator_style = "slant",
      },
      highlights = {
        buffer_selected = {
          bg = "#DADEE8",
          fg = "#3165E8",
          bold = true,
        },
        background = {
          bg = "#2e3440",
          fg = "#888888",
        },
      },
    },
  },
}
