--[[
Thie is an obj general properties inspector
]]
local GeneralPanel = class("GeneralPanel", function()
    return display.newNode()
end)
local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
local EditBoxLite = import("common.EditBoxLite")
function GeneralPanel:ctor( ... )
	-- local event = function ( ... )
	-- 	print("GeneralPanel xyz.......")
	-- end
	-- -- self.eventListenerCustom_ = cc.EventListenerCustom:create("xyz", event)
 -- --    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self.eventListenerCustom_, 1)
 -- 	EventHandler:addEventListener("xyz",event)
 -- 	local event2 = function ( ... )
	-- 	print("GeneralPanel xyz.......")
	-- end
	-- EventHandler:addEventListener("xyz",event2)
	self:addNodeEventListener(cc.NODE_EVENT, function(e) 
        if e.name == "enter" then 
            self:onEnter() 
        elseif e.name == "exit" then 
            eventDispatcher:removeEventListener(self.eventListenerCustom_)
        end 
    end)

    --EventHandler:addEventListener("edit.ObjectChange",{callback=handler(self,self.setObj)})
end

function GeneralPanel:onEnter( ... )
	local tipText = display.newTTFLabel({
				        text = "   x:",
				        size = 18,
				        color = cc.c3b( 0x2c , 0x00 , 0x00 ),
				        x = 0,
				        y = 0,
				        --align = display.TEXT_ALIGN_CENTER
    				})		
	self:addChild(tipText)


	local locationEditbox
	local locationEditboxY
	-- 输入事件监听方法
	local function onEdit(event, editbox)
	    if event == "began" then
	    -- 开始输入
	        print("开始输入")
	    elseif event == "changed" then
	    -- 输入框内容发生变化
	        print("输入框内容发生变化",editbox.key)
	        print("输入框内容发生变化 befor",locationEditbox:getText())
	        local text = editbox:getText()
	        print(text)
	        

	    elseif event == "ended" then
	    -- 输入结束
	        print("输入结束",editbox.key)
	        local text = locationEditbox:getText()
	        local textY = locationEditboxY:getText()
	        if editbox.key=="x" then
	        	if text~=self.m_x then
	        		EventHandler:dispatchEvent("edit.positionSet",{source="GeneralPanel.lu",x=text,y=textY})
	        		m_x=text
	        	end
	        elseif editbox.key=="y" then
	        	if textY~=self.m_y then
	        		EventHandler:dispatchEvent("edit.positionSet",{x=textY,y=textY,source="GeneralPanel.lu"})
	        		m_y = textY
	        	end
	        end
	        
	    elseif event == "return" then
	    -- 从输入框返回
	        print("从输入框返回")
	    end
	end
	 -- edit line
    locationEditbox = EditBoxLite.create({
	    image = "#ButtonNormal.png",
	    listener = onEdit,
        size = cc.size(50, 40),
        x = 12,
        y = -25,
    })
    locationEditbox.key="x"
    locationEditbox:setAnchorPoint(0,0)
    locationEditbox:setText("121")
    self.m_x = "121"
    self:addChild(locationEditbox)
    self.locationEditbox = locationEditbox
    -- local editButton = display.newSprite("#BehaviorLabelBackground.png", 0, 0)
    -- self:addChild(editButton)
    
	tipTextY = display.newTTFLabel({text="y:",
		size = 18,color=cc.c3b(0x2c,0x00,0x00),
		x=100,y=0})
	self:addChild(tipTextY)


	locationEditboxY = EditBoxLite.create({
		image = "#ButtonNormal.png",
		listener = onEdit,
		size = cc.size(50,40),
		x = 105, y =-25
		})
	locationEditboxY.key="y"
	locationEditboxY:setAnchorPoint(cc.p(0,0))
	locationEditboxY:setText("131")
	self.m_y="131"
	self:addChild(locationEditboxY)
	self.locationEditboxY = locationEditboxY

	--结构树
	-- local btnLeft = cc.Sprite:create("")
	-- self:addChild(btnLeft)

	-- local btnRight = cc.Sprite
end

-- function GeneralPanel:setObj( event,params )
-- 	print("setObj")
-- 	--local x,y = params.obj:getPosition()
-- 	local x,y=3,3
-- 	self:setPositionXandY(x,y)
-- end
function GeneralPanel:setObject( obj )
	print("general panel setObject")
	local x,y=obj:getPosition()
	self:setPositionXandY(x,y)
end
function GeneralPanel:setPositionXandY( x,y )
	x = math.floor(x)
	y = math.floor(y)
	print("setPositionXandY",x,y)
	self.locationEditbox:setText(x)
	self.m_x = x
	self.locationEditboxY:setText(y)
	self.m_y = y
end


return GeneralPanel
