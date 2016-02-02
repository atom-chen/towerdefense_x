--[[
event name 前缀:
	edit.positionSet	--编辑器系统事件.坐标改变事件
]]
local M = {}
EventHandler = M
local tables = {}
function M:create(  )
	local this = {}
	setmetatable(this,self)
	self.__index = self
	return this		
end
function M:addEventListener( name,event )
	if isset(event,"callback")==false then
		assert("EventHandler,eventlistner unset callback function")
		return
	end
	if tables[name] == nil then
		tables[name] = {}
	end

	if self:checkExist(name,event) == false then
		table.insert(tables[name],event)
	end
end
function M:dispatchEvent( name ,params)
	if tables[name]==nil then return end
	for k,v in pairs(tables[name]) do
		v.callback(event,params)
	end
end
function M:checkExist( name,event )
	if tables[name] == nil then return false end
	for k,v in pairs(tables[name]) do
		if v==event then
			return true
		end
	end 

	return false
end

return M