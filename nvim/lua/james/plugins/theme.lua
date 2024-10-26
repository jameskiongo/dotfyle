return {
	"EdenEast/nightfox.nvim",
	-- "folke/tokyonight.nvim",
	priority = 1000,
	config = function()
		-- local transparent = true -- set to true if you would like to enable transparency

		require("nightfox").setup({

			options = {
				-- Compiled file's destination location
				compile_path = vim.fn.stdpath("cache") .. "/nightfox",
				compile_file_suffix = "_compiled", -- Compiled file suffix
				transparent = true, -- Disable setting background
				terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
				dim_inactive = true, -- Non focused panes set to alternative background
				module_default = true, -- Default enable value for modules
				styles = { -- Style to be applied to different syntax groups
					comments = "italic", -- Value is any valid attr-list value `:help attr-list`
					keywords = "bold",
					types = "italic,bold",
				},
			},

			style = "nightfox",
			-- transparent = transparent,
			-- styles = {
			-- 	sidebars = transparent and "transparent" or "dark",
			-- 	floats = transparent and "transparent" or "dark",
			-- },
		})

		vim.cmd("colorscheme nightfox")
	end,
}
