return {
	"NvChad/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		require("colorizer").setup({
			filetypes = {
				"html",
				"css",
				"javascript",
				"typescript",
				"typescriptreact",
				"javascriptreact",
				"lua",
			},
			user_default_options = {
				mode = "background",
				tailwind = false, -- Enable tailwind colors
			},
		})
	end,
}
