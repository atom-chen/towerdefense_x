local M = {
	node,
	nodeText,
	nodeIcon,
	level,
	children
}
function M:new( nodeText,nodeIcon )
	local this = {}
	setmetatable(this,self)
	self.__index  = self
	-- body
	this.children = {}
	this.level = 1
	this.node = cc.Node:create()

	local text = cc.LabelTTF:create(nodeText,FONT,24)
	text:setAnchorPoint(cc.p(0,0.5))
	this.node:addChild(text)
	return this
end
function M:findNode( parent, node )
	
	for k,v in pairs(parent.children) do
		if v==node then
			return true,{v.level,k}
		end

		local ret,data = v:findNode(v,node)
		if ret == true then
			return true,data
		end
	end

	return false
end
function M:layout(  )
	dump(self.children,5)
	for k,v in pairs(self.children) do
		local x,y = v:getLayer():getPosition()
		print(k,x,y)
		v:getLayer():setPosition(cc.p(15,-24*(k)))
	end
end
function M:addNode( node )
	node.level = self.level + 1
	table.insert(self.children,node)
	print("treenode addnode node",node:getLayer())
	--self.node:addChild(node:getLayer())
	--self.node:addChild(cc.LabelTTF:create("11111111111",FONT,24))
	self.node:addChild(node:getLayer())
	self:layout()
end

function M:clearChildren( ... )
	for k ,v in pairs(self.children) do
		self.children:removeSelf()
	end
	self.children = {}
end
function M:getLayer(  )
	return self.node
end
function M:initTouchListener( ... )
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event)
		
	end,cc.Handler.EVENT_TOUCH_BEGAN)


end
return M