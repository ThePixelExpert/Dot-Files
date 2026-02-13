-- change some telescope options and a keymap to browse plugin files
return {
  -- change some telescope options and a keymap to browse plugin files
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {

      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = { "^.git/" }, -- Still ignore .git directory
        },
        pickers = {
          find_files = {
            hidden = true, -- Show hidden/dot files by default
          },
        },
      })

      vim.keymap.set("n", "<leader>ff", function()
        require("telescope.builtin").find_files({ hidden = true })
      end, { desc = "Find Files" })
    end,
  } -- stylua: ignore
  -- change some options
}
