--[[

		换行文本条 可设置行间距

]]--
local M = {}
--h
function M:new(_str , fontSize , total_width , split_height , color )
	local this = {}
	setmetatable(this,self)
	self.__index  = self

	if fontSize == nil then fontSize = 16 end
	local layer = display.newLayer()
	local line = 0 --行数
	local index = 0
	local font_h = 0
	local isFrist = true
	local texts = {}

	local length = this:utf8_length(_str)

	local word_width = fontSize										-- 估算一个字的宽度
	local line_words = math.floor( total_width / word_width )		-- 估算一行的字数

	while index <= length do
		local first_time = true
		local offset_char = 1
		while true do
			if first_time then
				first_time = false
				offset_char = line_words
			end

			local text = this:utf8_sub(_str , index , index + offset_char)
			local label = CCLabelTTF:create(text , FONT , fontSize)
			if (index + offset_char) >= length or label:getContentSize().width >= total_width then
				if isFrist then
					isFrist = false
					font_h = label:getContentSize().height
				end
				line = line +1
				index = index + offset_char
				texts[line] = text

				break
			else
				offset_char = offset_char + 1
			end
		end
	end
--[[
	for i = 0 , length do
		local text = this:utf8_sub(_str , index , i + 1)
		local label = CCLabelTTF:create(text , FONT , fontSize)
		if label:getContentSize().width >= w then
			if isFrist then
				isFrist = false
				font_h = label:getContentSize().height
			end
			line = line +1
			index = i + 1
			texts[line] = text
		end
	end
]]
	
	local line_height = font_h + split_height
	local total_height = line * line_height
	for i = 1 , line do
		-- local title_font = display.strokeLabel(texts[i] , 0 , total_height - line_height * i , fontSize , color or ccc3( 0x2c , 0x00 , 0x00 ) )
		local title_font = CCLabelTTF:create(texts[i] , FONT , fontSize)
		title_font:setColor( color or ccc3( 0x2c , 0x00 , 0x00 ) )
		setAnchPos(title_font , 0 , total_height - line_height * i)
		layer:addChild( title_font )
	end
	
	function layer:getLine()
		return line + 1
	end
	
	function layer:getHeight()
		return total_height
		
	end
	
	return layer , total_height
end


function M:utf8_length(str)
	local len = 0
	local pos = 1
	local length = string.len(str)
	while true do
		local char = string.sub(str , pos , pos)
		local b = string.byte(char)
		if b >= 128 then
			pos = pos + 3
		else
			pos = pos + 1
		end
		len = len + 1
			-- print(word)
			-- print("pos: " .. pos)
		if pos > length then
			break
		end
	end

	return len
end	
	
function M:utf8_sub(str , s , e)
	local t = {}
	local length = string.len(str)
	local pos = 1
	local offset = 1

	while true do		
		local word = nil
		local char = string.sub(str , pos , pos)
		local b = string.byte(char)
		if b >= 128 then
			if offset > s then
				word = string.sub(str , pos , pos + 2)
				table.insert(t , word)
			end

			pos = pos + 3
		else
			if offset > s then
				word = char
				table.insert(t , word)
			end

			pos = pos + 1
		end
		offset = offset + 1
			-- print(word)
			-- print("pos: " .. pos)
		if offset > e or pos > length then
			break
		end
	end

	return table.concat(t)
end



function M:create( params )
	params = params or {}
	local str = params.str or ""
	local total_width = params.width or 100		-- 文字总宽度
	local color = params.color or ccc3( 0x2c , 0x00 , 0x00 )
	local size = params.size or 20
	local x = params.x or 0
	local y = params.y or 0
	local line = 1														-- 行数
	-- 估算一行的字符数量
	-- local enter_num = string.len(str) - string.len(string.gsub(str , "\n" , ""))
	local lines = string.split(str , "\n")
	local enter_num = #lines - 1
	local label = CCLabelTTF:create(str , FONT , size )
	local label_size = label:getContentSize()
	local line_height = label_size.height

	if enter_num > 0 then
		local temp = CCLabelTTF:create("测" , FONT , size ):getContentSize()
		line_height = temp.height

		if label_size.width > total_width then			-- 大于一行
			local oneline_word_num = math.floor( total_width / temp.width )
			line = 0
			for i = 1 , #lines do
				local length = math.ceil( string.len(lines[i]) / 3 )
				if oneline_word_num >= length then
					line = line + 1
				else
					line = line + math.ceil( length / oneline_word_num )
				end

				
			end
		end
	else
		if label_size.width > total_width then			-- 大于一行
			line = math.ceil( label_size.width / total_width )
		end
	end

	

	-- line = line + enter_num

	if line > 1 then
		label:setDimensions(total_width , line * line_height)
	end

	label:setColor( color )
	label:setHorizontalAlignment( 0 )			-- 文字左对齐
	setAnchPos(label , x , y )
	print("# line num : " .. line )
	
	return label
end
return M