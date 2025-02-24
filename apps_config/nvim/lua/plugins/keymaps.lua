return {
  -- change trouble config
  {
    "folke/snacks.nvim",
    keys = {
      -- disable the default flash keymap
      -- { "<leader>fe", mode = { "n", "x", "o" }, false },
      {
        "<Char-0xAC>",
        function()
          Snacks.explorer({ cwd = LazyVim.root() })
        end,
        desc = "Explorer Snacks (root dir)",
      },
    },
  },
}
