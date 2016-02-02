local GroupPanel = class("GroupPanel", function()
    return display.newNode()
end)
local TreeNode = import("common.KNTreeNode")
function GroupPanel:ctor( toolbar )
	--cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.panels = {}
	self.scroll = KNScrollView:new( 30,0, 240, display.height - 100, 2)
	self:addChild(self.scroll:getLayer())
	--self.scroll:getLayer():setPosition(cc.p(display.width-300,0))
	self.scroll:setPosition(cc.p(display.width-300,0))
	self.scroll.onItemSelected = function ( position ) 
        print("GroupPanel position",position)
    end
	toolbar:addEventListener("NEW_OBJECT",function ( event )
        self:addItem(event.object)
    end)
	self.treeNode = TreeNode:new("root")
	self.scroll:addChild(self.treeNode:getLayer(),1)
end
function GroupPanel:addItem( object )
	local node =TreeNode:new("abc111111111111")
	self.treeNode:addNode(node)
	-- local name = "新建Object"
	-- if object~=nil then
	-- 	name = object:getClassId()..object:getId()
	-- end
	-- local tipText = display.newTTFLabel({
	-- 			        text = name,
	-- 			        size = 18,
	-- 			        color = cc.c3b( 0x2c , 0x00 , 0x00 ),
	-- 			        x = 0,
	-- 			        y = 0,
	-- 			        --align = display.TEXT_ALIGN_CENTER
 --    				})		
	-- self.scroll:addChild(tipText,1)
	-- tipText:setAnchorPoint(cc.p(0.5,0))
end
return GroupPanel