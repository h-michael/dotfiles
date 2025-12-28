vim = vim

function vim.pp(...)
	if select("#", ...) == 1 then
		vim.api.nvim_command("echo '" .. vim.inspect(...) .. "'")
	else
		vim.api.nvim_command("echo '" .. vim.inspect({ ... }) .. "'")
	end
end
