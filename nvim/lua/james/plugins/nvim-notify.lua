return {
	{
		"rcarriga/nvim-notify",
		keys = {
			{
				"<leader>un",
				function()
					require("notify").dismiss({ silent = true, pending = true })
				end,
				desc = "Dismiss All Notifications",
			},
		},
		opts = {
			stages = "static",
			timeout = 500,
			max_height = function()
				return math.floor(vim.o.lines * 0.75)
			end,
			max_width = function()
				return math.floor(vim.o.columns * 0.75)
			end,
			on_open = function(win)
				vim.api.nvim_win_set_config(win, { zindex = 100 })
			end,
		},
		config = function()
			require("notify").setup({
				background_colour = "#000000",
			})
		end,
		init = function()
			local banned_messages = {
				"No information available",
				"LSP[tsserver] Inlay Hints request failed. Requires TypeScript 4.4+.",
				"LSP[tsserver] Inlay Hints request failed. File not opened in the editor.",
			}
			vim.notify = function(msg, ...)
				for _, banned in ipairs(banned_messages) do
					if msg == banned then
						return
					end
				end
				return require("notify")(msg, ...)
			end
		end,
	},
}
