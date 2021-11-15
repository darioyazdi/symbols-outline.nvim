local ts_utils = require("nvim-treesitter.ts_utils")
local M = {}

-- export namespace SymbolKind {
-- 	export const File = 1;
-- 	export const Module = 2;
-- 	export const Namespace = 3;
-- 	export const Package = 4;
-- 	export const Class = 5;
-- 	export const Method = 6;
-- 	export const Property = 7;
-- 	export const Field = 8;
-- 	export const Constructor = 9;
-- 	export const Enum = 10;
-- 	export const Interface = 11;
-- 	export const Function = 12;
-- 	export const Variable = 13;
-- 	export const Constant = 14;
-- 	export const String = 15;
-- 	export const Number = 16;
-- 	export const Boolean = 17;
-- 	export const Array = 18;
-- 	export const Object = 19;
-- 	export const Key = 20;
-- 	export const Null = 21;
-- 	export const EnumMember = 22;
-- 	export const Struct = 23;
-- 	export const Event = 24;
-- 	export const Operator = 25;
-- 	export const TypeParameter = 26;
-- }

local function lsp_kind_from_capture(capture)
	local lookupTable = {
		keyword = -1,
		["keyword.function"] = -1,
		["keyword.return"] = -1,
		comment = -1,
		["punctuation.delimiter"] = -1,
		["punctuation.bracket"] = -1,
		conditional = -1,
		["function.builtin"] = -1,
		label = -1,

		method = 6,
		property = 7,
		field = 8,
		constructor = 9,
		["function"] = 12,
		["function.macro"] = 12,
		variable = 13,
		constant = 14,
		["constant.builtin"] = 14,
		string = 15,
		number = 16,
		boolean = 17,
		operator = 25,
		parameter = 26,
	}

	local res = lookupTable[capture]
	if res == -1 then
		return nil
	elseif res then
		return res
	end

	if capture then
		error("unable to map capture: " .. capture .. " to lsp_kind")
	end
	error("nil capture value")
end

-- name, kind, range, children
local function to_symbol_information(node_info)
	local lsp_kind = lsp_kind_from_capture(node_info.capture)
	if not lsp_kind then
		return nil
	end

	local range = {
		start = { line = node_info.start_pos[1], character = node_info.start_pos[2] },
		["end"] = { line = node_info.end_pos[1], character = node_info.end_pos[2] },
	}

	return {
		name = node_info.text,
		kind = lsp_kind,
		range = range,
		selectionRange = range,
	}
end

local function get_named_treesitter_nodes()
	parser = vim.treesitter.get_parser(0, lang)
	if parser == nil then
		return {}
	end

	local hlQuery = vim.treesitter.get_query(parser:lang(), "highlights")
	local captured_nodes = {}
	local results = {}

	for _, tree in pairs(parser:parse()) do
		for id, node, meta in hlQuery:iter_captures(tree:root(), 0) do
			captured_nodes[node:id()] = true
			-- if node:named() then
			-- end
		end

		for id, node, meta in hlQuery:iter_captures(tree:root(), 0) do
			if node:named() then
				local include_node = true
				local parent = node:parent()
				while parent do
					if captured_nodes[parent:id()] then
						include_node = false
						break
					end
          parent = parent:parent()
				end

				if include_node then
					start_row, start_col, end_row, end_col = node:range()
					table.insert(results, {
						text = vim.treesitter.get_node_text(node, 0),
						capture = hlQuery.captures[id],
						type = node:type(),
						start_pos = { start_row, start_col },
						end_pos = { end_row, end_col },
					})
				else
					print("skip")
				end
			end
		end
	end

	return results
end

function M.should_use_provider(bufnr)
	return pcall(vim.treesitter.get_parser, bufnr)
end

---@param on_symbols function
function M.request_symbols(on_symbols)
	local symbol_info = {}
	for _, res in pairs(get_named_treesitter_nodes()) do
		table.insert(symbol_info, to_symbol_information(res))
	end

	on_symbols({ [777777] = { result = symbol_info } })
end

return M
