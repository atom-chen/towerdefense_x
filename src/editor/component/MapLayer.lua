--[[
地图层，必须要如下属性
由于toolbar必须要以下函数
	getCamera()
	getObjects()
	getMarksLayer
    
]]
-- local MapLayer = {}
local MapLayer = class("MapLayer", function()
    --return display.newNode()
    return display.newLayer()
end)
require("common.KNScrollView")
local MapCamera     = require("app.map.MapCamera")
local EditorConstants = require("editor.EditorConstants")
local ObjectFactory = require("app.map.ObjectFactory")
function MapLayer:ctor( ... )
	print("ctor")
	


	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
	local frame = sharedSpriteFrameCache:getSpriteFrame("CreateObjectButton.png")
	local btnAdd = cc.Sprite:createWithSpriteFrame(frame)
	
	btnAdd:setPosition(cc.p(100,display.height - 10))
	
	frame = sharedSpriteFrameCache:getSpriteFrame("RemoveObjectButton.png")
	local btnRemove = cc.Sprite:createWithSpriteFrame(frame)
	btnRemove:setPosition(cc.p(150,display.height - 10))

	--self:setTouchEnabled(true)


	--self.scroll:alignCenter()
	self.btnAdd = btnAdd
	self.btnRemove = btnRemove
    --self.tempNode = display.newNode()
    --self.tempNode:addChild(self.scroll:getLayer())
   -- self:addChild(self.tempNode)

	self:addChild(btnAdd)
	self:addChild(btnRemove)
	--直接用这个nodeEventListener，事件会被KNScrollView吃掉
	--self:addNodeEventListener(cc.NODE_TOUCH_EVENT,handler(self,self.onTouch_))
	local listener = cc.EventListenerTouchOneByOne:create()
	--listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event)
		local loc = touch:getLocation()
		local x,y = loc.x,loc.y
		if self.btnRemove:getCascadeBoundingBox():containsPoint(cc.p(x,y))
			or self.btnAdd:getCascadeBoundingBox():containsPoint(cc.p(x,y)) then
			return true
		end
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function ( touch,event )
		print("listener move")
	end,cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(handler(self,self.onTouchEnded_),cc.Handler.EVENT_TOUCH_ENDED)
	self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)


	self.uiLayer_ = display.newNode()
    self.uiLayer_:setPosition(display.cx, display.cy)
	-- 创建工具栏
    self.toolbar_ = require("editor.Toolbar").new(self)
    --self.toolbar_:addTool(require("editor.GeneralTool").new(self.toolbar_, self.map_))
    self.toolbar_:addTool(require("editor.ObjectTool").new(self.toolbar_, self))
    --self.toolbar_:addTool(require("editor.PathTool").new(self.toolbar_, self.map_))
    --self.toolbar_:addTool(require("editor.RangeTool").new(self.toolbar_, self.map_))

    -- 创建工具栏的视图
    self.editorUIScale, self.toolbarLines = 1,1
    self.toolbarView_ = self.toolbar_:createView(self, "#ToolbarBg.png", EditorConstants.TOOLBAR_PADDING, self.editorUIScale, self.toolbarLines)
    self.toolbarView_:setPosition(500,200)
    self.toolbar_:setDefaultTouchTool("ObjectTool")
    self.toolbar_:selectButton("ObjectTool", 1)

    local objectInspectorScale = 1
    self.objectInspector_ = require("editor.ObjectInspector").new(self, objectInspectorScale, self.toolbarLines)
    self.objectInspector_ = require("editor.component.PropertyPanel").new(self)
    self:addChild(self.objectInspector_)
    self.objectInspector_:addEventListener("UPDATING_OBJECT", function(event)
    	print("MapLayer tick")
        --self.toolbar_:dispatchEvent(event)
    end)
    -- self.objectInspector_:createView(self)
    -- 注册工具栏事件
    self.toolbar_:addEventListener("SELECT_OBJECT", function(event)
        print("MapLayer on Event_select_object")
        self.objectInspector_:setObject(event.object)
    end)
    self.toolbar_:addEventListener("UPDATE_OBJECT", function(event)
        self.objectInspector_:setObject(event.object)
    end)
    self.toolbar_:addEventListener("UNSELECT_OBJECT", function(event)
        self.objectInspector_:removeObject()
    end)
   

    -- self.scroll = KNScrollView:new( 330,0, 140, display.height - 100, 2)
    -- self.scroll.name_="group tree"
    -- --local btnTest = cc.Sprite:createWithSpriteFrame(frame)
    -- --self.scroll:addChild2(btnTest,btnTest)
    -- self:addItem()
    -- self.scroll.onItemSelected = function ( position ) 
    --     print("position",position)
    -- end
    -- self:addChild(self.scroll:getLayer())
    self.groupPanel = require("editor.component.GroupPanel").new(self.toolbar_)
    self:addChild(self.groupPanel)
	local eve = function ( event,params )
		print("MapLayer ctor testing")
		print(params.x,params.y,params.source)
	end
	EventHandler:addEventListener("edit.positionSet",{callback=eve})

	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        return self:onTouch(event.name, event.x, event.y)
    end)

	self.objects_ = {}
	self.width_ = 1200
    self.height_ = 1200
    self.nextObjectIndex_   = 1
    self.objects_ = {}
    self.objectsByClass_ = {}

	-- 计算地图位移限定值
    self.camera_ = MapCamera.new(self)
    self.camera_:resetOffsetLimit()

    self.marksLayer_ = display.newNode()
    self:addChild(self.marksLayer_)

    self.batch_ = display.newNode()
    self:addChild(self.batch_)

    self.debugLayer_ = display.newNode()
    self:addChild(self.debugLayer_)

end
function MapLayer:onTouch( eventName,x,y )
	print("MapLayer on touch",eventName)
	return self.toolbar_:onTouch(eventName,x,y)
end
function MapLayer:getSize()
    return self.width_, self.height_
end
function MapLayer:getCamera(  )
	return self.camera_
end
function MapLayer:getAllObjects( )
	return self.objects_
end
--[[--

返回用于显示地图标记的层

]]
function MapLayer:getMarksLayer()
    return self.marksLayer_
end

--[[--

创建新的对象，并添加到地图中

]]
function MapLayer:newObject(classId, state, id)

	if not id then
        id = string.format("%s:%d", classId, self.nextObjectIndex_)
        self.nextObjectIndex_ = self.nextObjectIndex_ + 1
    end

    local object = ObjectFactory.newObject(classId, id, state, self)
    --object:setDebug(self.debug_)
    --object:setDebugViewEnabled(self.debugViewEnabled_)
    object:resetAllBehaviors()

    -- validate max object index
    local index = object:getIndex()
    if index >= self.nextObjectIndex_ then
        self.nextObjectIndex_ = index + 1
    end

    -- add object
    self.objects_[id] = object
    if not self.objectsByClass_[classId] then
        self.objectsByClass_[classId] = {}
    end
    self.objectsByClass_[classId][id] = object

    -- validate object
    --if self.ready_ then
        object:validate()
        if not object:isValid() then
            echoInfo(string.format("Map:newObject() - invalid object %s", id))
            self:removeObject(object)
            return nil
        end

        -- create view
        --if self:isViewCreated() then
            object:createView(self.batch_, self.marksLayer_, self.debugLayer_)
            object:updateView()
        --end
    --end

    return object
end
function MapLayer:isDebug( ... )
	return true
end
--[[--

从地图中删除一个对象

]]
function MapLayer:removeObject(object)
    local id = object:getId()
    assert(self.objects_[id] ~= nil, string.format("Map:removeObject() - object %s not exists", tostring(id)))

    self.objects_[id] = nil
    self.objectsByClass_[object:getClassId()][id] = nil
    if object:isViewCreated() then object:removeView() end
end
--[[--

按照 Y 坐标重新排序所有可视对象

]]
function MapLayer:setAllObjectsZOrder()
    -- local batch = self.batch_
    -- for id, object in pairs(self.objects_) do
    --     local view = object:getView()
    --     if view then
    --         if object.viewZOrdered_ then
    --             batch:reorderChild(view, MapConstants.MAX_OBJECT_ZORDER - object.y_)
    --         elseif type(object.zorder_) == "number" then
    --             batch:reorderChild(view, object.zorder_)
    --         else
    --             batch:reorderChild(view, MapConstants.DEFAULT_OBJECT_ZORDER)
    --         end
    --         object:updateView()
    --     end
    -- end
end
-- function MapLayer:create( params )
-- 	local this = {}
-- 	setmetatable(this,self)
-- 	self.__index = self

-- 	this.map = params.map
-- 	--this.layer = cc.LayerColor:create(cc.c4b(0xFF, 0x00, 0x00, 0x80))
-- 	this.layer = display.newLayer()
-- 	--self.layer:setContentSize(cc.size(200,200))
-- 	local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
-- 	local frame = sharedSpriteFrameCache:getSpriteFrame("CreateObjectButton.png")
-- 	local btnAdd = cc.Sprite:createWithSpriteFrame(frame)
-- 	this.layer:addChild(btnAdd)
-- 	btnAdd:setPosition(cc.p(100,display.height - 10))
	
-- 	frame = sharedSpriteFrameCache:getSpriteFrame("RemoveObjectButton.png")
-- 	local btnRemove = cc.Sprite:createWithSpriteFrame(frame)
-- 	btnRemove:setPosition(cc.p(150,display.height - 10))
-- 	this.layer:addChild(btnRemove)
-- 	this.layer:setTouchEnabled(true)
-- 	--this.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT,  handler(this, this.onTouch_))
-- 	this.layer:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
--         print("xxxxxxx")
--     end)
-- 	this.btnRemove = btnRemove
-- 	this.btnAdd = btnAdd
-- 	--this.map:addChild(this.layer)
-- 	return this.layer
-- end

function MapLayer:onTouchEnded_( touch,event )
	local loc = touch:getLocation()
	local x,y = loc.x,loc.y
	print("onTouchEnded")
	if self.btnAdd:getCascadeBoundingBox():containsPoint(cc.p(x,y)) then
		self:addItem()
		local x,y=100,100
		EventHandler:dispatchEvent("edit.ObjectAdd",{x=x,y=y})
		EventHandler:dispatchEvent("edit.ObjectChange",{x=x,y=y})
	elseif self.btnRemove:getCascadeBoundingBox():containsPoint(cc.p(x,y)) then
		local event = function ( ... )
			print("xxx")
		end
		--self.eventListenerCustom_ = cc.EventListenerCustom:create("xyz", event)
		--cc.Director:getInstance():getEventDispatcher():dispatchEvent(eventcustom)
		EventHandler:dispatchEvent("edit.ObjectChange",{obj={x=3,y=4}})
		--self:getEventDispatcher():dispatchEvent("xyz")
	end
end
function MapLayer:onItemClick_( position )
	print("on item click",position)
end
-- function MapLayer:onTouch_( event )
-- 	print("MapLayer MapLayer MapLayer _ontouch")
-- 	if event.name=="began" then

-- 		if self.btnRemove:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y))
-- 			or self.btnAdd:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y)) then
-- 			return true
-- 		end
-- 	elseif event.name=="ended" then
-- 		if self.btnAdd:getCascadeBoundingBox():containsPoint(cc.p(event.x,event.y)) then
-- 			self:addItem()
-- 		end
-- 		print("MapLayer ontouch ended")

-- 	end
-- end
function MapLayer:addItem( object )

	local tipText = display.newTTFLabel({
				        text = "新建Object",
				        size = 18,
				        color = cc.c3b( 0x2c , 0x00 , 0x00 ),
				        x = 0,
				        y = 0,
				        --align = display.TEXT_ALIGN_CENTER
    				})		
	self.scroll:addChild(tipText,1)
	tipText:setAnchorPoint(cc.p(0.5,1))

	local sp = cc.Sprite:create("GreenButton.png")
	self:addChild(sp)
	-- local sharedSpriteFrameCache = cc.SpriteFrameCache:getInstance()
	-- local frame = sharedSpriteFrameCache:getSpriteFrame("RemoveObjectButton.png")
	-- local btnTest = cc.Sprite:createWithSpriteFrame(frame)
	-- btnTest:setAnchorPoint(cc.p(0.5,1))
	-- self.scroll:addChild2(btnTest,btnTest)

end
-- function MapLayer:show(  )
-- 	--self.map:addChild(self.layer)
-- end
return MapLayer