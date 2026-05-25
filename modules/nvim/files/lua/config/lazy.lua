-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	-- Temporary: use personal fork to dogfood the minimum_release_age feature.
	local lazyrepo = "https://github.com/h-michael/lazy.nvim.git"
	local out =
		vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=feat/minimum-release-age", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = ";"
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		{ import = "plugins" },
	},
	defaults = {
		-- Ignore freshly published commits/tags to mitigate supply-chain
		-- attacks. Provided by the feat/minimum-release-age branch of the
		-- personal lazy.nvim fork.
		minimum_release_age = "7d",
	},
	-- Configure any other settings here. See the documentation for more details.
	-- colorscheme that will be used when installing plugins.
	install = {
		missing = true,
		colorscheme = { "tokyonight-night" },
	},
	rocks = { enabled = false },
	-- automatically check for plugin updates
	checker = { enabled = true },

	change_detection = {
		-- automatically check for config file changes and reload the ui
		enabled = true,
		notify = true, -- get a notification when changes are found
	},

	-- Put lockfile in writable location (config dir is read-only on NixOS)
	lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})
