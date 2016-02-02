
local NewbieGuide = requires("Config.NewbieGuide")
local PlayerGuide = {
	layer,
	clickfun ,
	width,
	point,
	step,
}

--[[

]]
function PlayerGuide:new()
	local this = {}
	setmetatable(this,self)
	self.__index = self
	this.params = params or {}
	this.item = {}
	this.textItems = {}
	this.layer = display.newLayer()
	setAnchPos(this.layer, x, y)
    	this.textshow = nil
--[[
	local function onTouch(type, x, y)
		--print("this.layer:onTouch========="..type.."..x:"..x.."..y:"..y)
		--this.clickfun()
		local function callback()
			this.clickfun()
		end

		if this.textshow and this.textshow.click==true then
			if type == CCTOUCHBEGAN then
				if this:getRange():containsPoint(ccp(x,y)) then
					this.layer:removeFromParent()
					callback()

					return false
				end
				return true
			elseif type == CCTOUCHMOVED then
					-- if this:getRange():containsPoint(ccp(x,y)) then
						
					-- else
						
					-- end
					return true
			elseif type == CCTOUCHENDED then
				if this:getRange():containsPoint(ccp(x,y)) then
					this.layer:removeFromParent()
					callback()
					return true
				else
					return true
				end
			end
		else
			this.layer:removeFromParent()
			callback()
			return true
		end
		return true
	end]]
	this.layer:setTouchEnabled(true)
	--设置按钮的优先级

	-- this.layer:registerScriptTouchHandler(onTouch,false,-135,true)

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event)
		local location = touch:getLocation()  
		local x, y = location.x, location.y
		
		local function callback()
			this.clickfun()
		end
		if this.textshow and this.textshow.click==true then				
			if this:getRange():containsPoint(ccp(event.x,event.y)) then
				this.layer:removeFromParent()
				callback()
				return false
			end
		else 
			this.layer:removeFromParent()
			callback()
		end
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function(touch, event)
		local location = touch:getLocation()  
		local x, y = location.x, location.y
	
	end,cc.Handler.EVENT_TOUCH_MOVED)	
	listener:registerScriptHandler(function(touch, event)
		local location = touch:getLocation()  
		local x, y = location.x, location.y
		if this:getRange():containsPoint(ccp(event.x,event.y)) then
			this.layer:removeFromParent()
			callback()
		end
	end,cc.Handler.EVENT_TOUCH_ENDED)
	this.layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, this.layer)



	return this
end

function PlayerGuide:getLayer()
	return self.layer
end

--获取所有父组件，取得按钮的绝对位置
function PlayerGuide:getRange()
	local x = self.point.x
	local y = self.point.y
	return CCRectMake(x-self.width,y-self.width,self.width*2,self.width*2)
end
--clickfun, width, point, step, pause
function PlayerGuide:show(parent, params)
	-- 判断当前有没有文字提示
	step = params.step or DATA_Guide:getGuide()
	self.textshow = NewbieGuide[step .. ""]
	local mask = PlayerGuide:new(parent)

	mask.clickfun = params.clickfun
	mask.width = params.width
	mask.point = params.point

	-- 创建提示的精灵
	local by
	if mask.point then
		if mask.point.y > display.cy then
			by = display.cy - 100
		else
			by = display.cy + 100
		end
	else
		by = display.cy + 100
	end
	local istip
	
	-- 添加一个半透明的灰显层
	if self.textshow.click==nil then
		local backLayerColor = CCLayerColor:create(ccc4(0, 0, 0, 160));--(0~255),越大越不透明
		mask.layer:addChild(backLayerColor)
	end
	local bg = display.newSprite("image/common/dialog_bg.png", display.cx, by)
	mask.layer:addChild(bg, 1)
	local sp = display.newSprite("image/common/guide_logo.png", display.cx+100, 115)
	bg:addChild(sp)

	-- 搭边文字
	local text = display.strokeLabel( self.textshow["text"] , 118 , 5 , 18 , ccc3( 0xff , 0xff , 0xff ) , -1 , ccc3( 0xa7 , 0xe1 , 0xe6 ) , {
		dimensions_width = 200,
		dimensions_height = 280,
		align = kCCTextAlignmentLeft,
		veralign = kCCVerticalTextAlignmentTop
	})
	text:setAnchorPoint(ccp(0.5,0.5))
	bg:addChild(text)

	-- tips
	if self.textshow["tips"] then
		istip = true
		local tips = display.strokeLabel( self.textshow["tips"] , 85 , 20 , 18 , ccc3( 0xff , 0xff , 0x00 ) )
		bg:addChild(tips)
	end

	-- local label = CCLabelTTF:create(textshow, FONT, 22, CCSize( 200, 280 ), kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop) 
	--  --255,255,0ccc3(0, 255, 0)黄ccc3(0, 255, 0)绿
	-- label:setPosition(118, 5)
	-- bg:addChild(label)

	if self.textshow.click == true then
		-- 创建cliper对象
		-- local pClip=CCClippingNode:create()
		-- -- 添加一个半透明的灰显层
		local backLayerColor = CCLayerColor:create(ccc4(0, 0, 0, 160));--(0~255),越大越不透明

		-- --绘制圆形区域
		-- local green = ccc4f(0, 1, 0, 1)--顶点颜色,这里我们没有实质上没有绘制,所以看不出颜色
		-- local fRadius=params.width --圆的半径
		-- local nCount=100--圆形其实可以看做正多边形,我们这里用正100边型来模拟园
		-- local coef = 2.0 * 3.14/nCount--计算每两个相邻顶点与中心的夹角
		-- local arrRectangle = CCPointArray:create(100)
		-- for i = 0, nCount do
		-- 	local rads = i*coef--弧度
		-- 	arrRectangle:add(ccp(fRadius * math.cos(rads), fRadius * math.sin(rads)))
		-- end
		-- local m_pAA=CCDrawNode:create()
		-- local ps = arrRectangle:fetchPoints()
		-- m_pAA:drawPolygon(ps, nCount, green, 0, green)--绘制这个多边形!
		-- arrRectangle:delPoints(ps)
		-- --动起来
		-- m_pAA:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCScaleBy:create(0.1, 0.95),
		-- 	CCScaleTo:create(0.25, 1))))
		-- --设置到屏幕的中心
		-- m_pAA:setPosition(params.point)

		-- --设置为pclip的模板
		-- pClip:setStencil(m_pAA)
		-- --是否反向?
		-- pClip:setInverted(true)
		local pClip = UICutLayer:createChip(params.width, params.point)
		pClip:addChild(backLayerColor)
		mask.layer:addChild(pClip)

		-- 箭头
		local arrow = display.newSprite(IMG_PATH .. "image/arrow.png")
		setAnchPos(arrow , params.point.x , params.point.y + 30 , 0.5)
		mask.layer:addChild(arrow)

		local arrowAction = nil
		arrowAction = function()
			transition.moveBy(arrow , {
				delay = 0.1,
				y = 40,
				time = 0.3,
				onComplete = function()
					transition.moveBy(arrow , {
						y = -40,
						time = 0.5,
						onComplete = arrowAction
					})
				end
			})
			
		end
		arrowAction()


		if istip == nil then
			label = CCLabelTTF:create("点击按钮位置", FONT, 22)
			point.y = point.y+50
			label:setPosition(params.point)
			label:setColor(ccc3(255,255,0))
			mask.layer:addChild(label)
		end
	else
		if istip == nil then
			label = CCLabelTTF:create("单击屏幕", FONT, 22)
			point.y = point.y+50
			label:setPosition(params.point)
			label:setColor(ccc3(0, 255, 0))
			mask.layer:addChild(label)
		end
	end

	parent:addChild(mask.layer , 999999 )
end

return PlayerGuide
