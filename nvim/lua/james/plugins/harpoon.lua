return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	opts = {
		menu = {
			width = vim.api.nvim_win_get_width(0) - 4,
		},
		settings = {
			save_on_toggle = true,
		},
	},
	keys = function()
		local keys = {
			{
				"<leader>ha",
				function()
					require("harpoon"):list():add()
				end,
				desc = "Harpoon File",
			},
			{
				"<leader>hl",
				"<cmd>Telescope harpoon marks<cr>",
				{ desc = "harpoon list with telescope" },
			},
			{
				"<leader>hn",
				function()
					require("harpoon"):list():next()
				end,
				-- "<cmd>lua require('harpoon.ui').nav_next()<cr>",
				{ desc = "Go to next harpoon mark" },
			},
			{
				"<leader>hp",
				function()
					require("harpoon"):list():prev()
				end,

				-- "<cmd>lua require('harpoon.ui').nav_prev()<cr>",
				{ desc = "Go to previous harpoon mark" },
			},
			{
				"<leader>hq",
				function()
					local harpoon = require("harpoon")
					harpoon.ui:toggle_quick_menu(harpoon:list())
				end,
				desc = "Harpoon Quick Menu",
			},
		}

		for i = 1, 5 do
			table.insert(keys, {
				"<leader>" .. i,
				function()
					require("harpoon"):list():select(i)
				end,
				desc = "Harpoon to File " .. i,
			})
		end
		return keys
	end,
}
