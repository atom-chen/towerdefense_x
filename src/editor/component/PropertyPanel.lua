local PropertyPanel = class("PropertyPanel", function()
    return display.newNode()
end)
--local KNScrollView = import("common.KNScrollView")
function PropertyPanel:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
	self.panels = {}
	self.scroll = KNScrollView:new( 30,0, 240, display.height - 100, 2)
	self:addChild(self.scroll:getLayer())
	self:addPanel("General")
	self:setPosition(cc.p(display.width-200,0))


end
function PropertyPanel:onTouch(event, x, y)
    print("PropertyPanel on touth")
end
function PropertyPanel:setObject( object )
    self:dispatchEvent({name = "UPDATING_OBJECT", object = self.object_})
	local isVisible = self.isVisible_
    local changeVisible = self.object_ ~= object
    --if self.panel_ then self:removeObject() end
    if not changeVisible then
        self.isVisible_ = isVisible
    end

   	-- local panel = display.newNode()
    -- self.sprite_:addChild(panel)
    -- self.panel_ = panel
   	self.panels["General"]:setObject(object)
   
end
function PropertyPanel:removeObject( )
	if self.panel_ then
        self.sprite_:setVisible(false)
        self.panel_:removeSelf()
        self.panel_ = nil
        self.object_ = nil
        self.isVisible_ = true
    end
end
function PropertyPanel:addPanel( key )
	local panel = require("editor.component."..key.."Panel").new()
	self.scroll:addChild(panel,1)
	self.panels[key] = panel
end

return PropertyPanel