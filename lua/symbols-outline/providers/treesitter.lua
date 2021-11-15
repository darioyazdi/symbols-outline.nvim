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

		method = 6,
		property = 7,
		field = 8,
		constructor = 9,
		["function"] = 12,
		variable = 13,
		constant = 14,
		["constant.builtin"] = 14,
		string = 15,
		number = 16,
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

	return {
		name = node_info.name,
		kind = lsp_kind,
		range = { start = node_info.start_pos, ["end"] = node_info.end_pos },
	}
end

local function get_named_treesitter_symbols()
	-- todo: this errors is no parser is found
	parser = vim.treesitter.get_parser(0, lang)
	if parser == nil then
		return {}
	end

	local hlQuery = vim.treesitter.get_query(parser:lang(), "highlights")
	local results = {}

	for _, tree in pairs(parser:parse()) do
		for id, node, meta in hlQuery:iter_captures(tree:root(), 0) do
			if node:named() then
				start_row, start_col, end_row, end_col = node:range()
				table.insert(results, {
					text = vim.treesitter.get_node_text(node, 0),
					capture = hlQuery.captures[id],
					type = node:type(),
					start_pos = { start_row, start_col },
					end_pos = { end_row, end_col },
				})
			end
		end
	end

	return results
end

function M.should_use_provider(bufnr)
	return vim.treesitter.get_parser(0, lang)
end

---@param on_symbols function
function M.request_symbols(on_symbols)
	local symbol_info = {}
	for _, res in pairs(get_named_treesitter_symbols()) do
		table.insert(symbol_info, to_symbol_information(res))
	end

  print(vim.inspect(symbol_info))
	on_symbols(symbol_info)
end

return M
