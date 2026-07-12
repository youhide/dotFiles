return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  lazy = false,
  opts = {
    window = {
      position = "left",
      width = 35,
    },
    filesystem = {
      filtered_items = {
	visible = true,
	never_show = {
	  ".DS_Store"
	}
      }
    }
  },
}
