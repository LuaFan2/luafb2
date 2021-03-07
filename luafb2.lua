local xml2lua = require("thirdparty.xml2lua")
local handler = require("thirdparty.xmlhandler.tree")

local function file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end

local function toNormal(tag, content)
	return "<"..tag..">"..content.."</"..tag..">"
end

local luafb2 = {}

function luafb2.toHTML(tag, content)
	return toNormal(tag, content)
end

function luafb2.parse(content)
	local book = {}
		book.description = {}
			book.description.genres = {}
			book.description.authors = {}

	local parser = xml2lua.parser(handler)
		parser:parse(content)

	local root = handler.root
	if not root then return end
	local fb2 = root.FictionBook
	if not fb2 then return end

	if fb2.description then
		book.description.lang = fb2.description["title-info"].lang
		book.description.title = fb2.description["title-info"].title
		book.description.sequence = fb2.description["title-info"].sequence

		for k, v in ipairs(fb2.description["title-info"].annotation) do
			book.description.annotation = toNormal(k, v)
		end

		book.description.authors = fb2.description["title-info"].author
		book.description.genres = fb2.description["title-info"].genre

		book.description.date = fb2.description["document-info"].date._attr.value
		book.description.program_used = fb2.description["document-info"].program_used
		book.description.version = fb2.description["document-info"].version
		book.description.id = fb2.description["document-info"].id
	end

	book.body = fb2.body
	book.binaries = fb2.binary

	return book
end

function luafb2.parse_file(path)
	if not file_exists(path) then return end

	local f = io.open(path, "rb")
	local content = f:read("*a")
    f:close()

    return luafb2.parse(content)
end

return luafb2