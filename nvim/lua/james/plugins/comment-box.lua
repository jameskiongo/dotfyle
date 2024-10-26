return {
	"LudoPinelli/comment-box.nvim",
	lazy = false,
	config = function()
		-- ╭─────────────────────────────────────────────────────────╮
		-- │ set keymaps                                             │
		-- ╰─────────────────────────────────────────────────────────╯
		local keymap = vim.keymap.set -- for conciseness
		local opts = { noremap = true, silent = true }
		local cb = require("comment-box")

		keymap("n", "<leader>ac", "<cmd>lua require('comment-box').llbox()<CR>", { desc = "comment box" })
		keymap("n", "<leader>ac", "<cmd>lua require('comment-box').llbox()<CR>", { desc = "comment box" })
		-- left aligned fixed size box with left aligned text
		keymap({ "n", "v" }, "<Leader>cb", "<Cmd>CBllbox<CR>", opts)
		-- centered adapted box
		keymap({ "n", "v" }, "<Leader>cc", "<Cmd>CBacbox<CR>", opts)

		-- left aligned titled line with left aligned text
		keymap({ "n", "v" }, "<Leader>ct", "<Cmd>CBclline<CR>", opts)

		-- centered line
		keymap("n", "<Leader>cl", "<Cmd>CBccline<CR>", opts)
		-- keymap("i", "<M-l>", "<Cmd>CBcline<CR>", opts)

		-- remove a box or a titled line
		keymap({ "n", "v" }, "<Leader>cd", "<Cmd>CBd<CR>", opts)
	end,
}
