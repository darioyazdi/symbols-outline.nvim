local function set_keymaps()
	vim.api.nvim_set_keymap("n", "tht", ":TreehouseTest<CR>", {})
end

local function greet()
	print("hello")
end

local function __refresh()
	print("called refresh")
end

local function close_outline()
	print("called close_outline")
end

local function open_outline()
	print("called open_outline")
end

local function toggle_outline()
	print("called toggle_outline")
end

local function testing()
	parser = vim.treesitter.get_parser(0, lang)
	if parser == nil then
		return {}
	end

	local hlQuery = vim.treesitter.get_query(parser:lang(), "highlights")
	for _, tree in pairs(parser:parse()) do
		for id, node in hlQuery:iter_captures(tree:root(), 0) do
			local parent = node:parent()
			local grandparent = parent and parent:parent() or nil
			local word = vim.treesitter.get_node_text(node, 0)
			local kind = hlQuery.captures[id]
			local type = node:type()
			print("node_text:", word, "node_kind:", kind, "node_type:", type)
		end
	end
end

return {
	greet = greet,
	toggle_outline = toggle_outline,
	open_outline = open_outline,
	close_outline = close_outline,
	__refresh = __refresh,
	testing = testing,
	set_keymaps = set_keymaps,
}
