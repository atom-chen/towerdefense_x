--按钮滑动条


local M = {}
function M:new(path , params )
	local this = {}
	setmetatable(this,self)
	self.__index = self
	
	if type(params) ~= "table" then params = {} end
	
	this.priority = params.priority or -128
	this.path=path
	this.x= params.x or 0
	this.y= params.y or 0
	this.minimum = params.minimum or 0;
	this.maximum = params.maximum or 1;
	-- print("###########KNSlider->minimum:", this.minimum, " maximum:", this.maximum)
	this.value = params.initial or 0;
	this.onNewValue = params.callback or function () end 
	
	local container = CCLayer:create()--创建对像容器
	container:ignoreAnchorPointForPosition(false)
	
	
	local imagePath = IMG_PATH .. "image/start_bar/"..this.path.."/"
	this.bg = display.newSprite(imagePath.."bg.png")
	container:addChild(this.bg, -2)
	
	this.progress  = display.newSprite(imagePath.."fore.png")
	container:addChild(this.progress, -1)
	
	this.thumb = display.newSprite(imagePath.."icon.png")
	container:addChild(this.thumb, 0)
	
	container:setContentSize(this.bg:getContentSize())--获取大小
	local s = container:getContentSize()
	
	this.bg:setAnchorPoint(ccp(0.5, 0.5));
	this.bg:setPosition(ccp(s.width/2, s.height/2))
	
	this.progress:setAnchorPoint(ccp(0.0, 0.5));
	this.progress:setPosition(ccp(0, s.height/2))
	
	this.thumb:setPosition(ccp(s.width/2, s.height/2))
	
	container:setAnchorPoint(ccp(0, 1));
	container:setPosition(ccp(this.x,this.y))--设置坐标
	

	container:setTouchEnabled( true );


	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(function(touch, event)

		local location = touch:getLocation()  
		local x, y = location.x, location.y

		if this.minimum == -0.1 then
			return false
		end
		local where = container:convertToNodeSpace(cc.p(x, y))
		--local nodeBB = container:getBoundingBox()
		--echoLog("[KNSlider]","touchbegan",nodeBB.x,nodeBB.y)
		local thumbBB = this.thumb:getBoundingBox()
		--local tp = cc.pAdd(cc.p(nodeBB.x, nodeBB.y), cc.p(thumbBB.x, thumbBB.y))
		--thumbBB.x = tp.x; thumbBB.y = tp.y
		echoLog("[KNSlider]","touchbegan where.x,y",where.x,where.y)
		local isIn = cc.rectContainsPoint(thumbBB, where)
		echoLog("[KNSlider]","isIn",isIn)
		return isIn
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(function(touch, event)
		local location = touch:getLocation()  
		local x, y = location.x, location.y
		local nodeBB = container:getBoundingBox()
		container:setValue((this.maximum - this.minimum) * (x-nodeBB.x)/nodeBB.width + this.minimum)		
	end,cc.Handler.EVENT_TOUCH_MOVED)	
	container:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, container)	



	
	function container:layout()
		if this.minimum > this.maximum then this.minimum = this.maximum - 0.1 end -- sanity check
		if this.value < this.minimum then this.value = this.minimum end
		if this.value > this.maximum then this.value = this.maximum end
		local percent
		if this.maximum == this.minimum then
			percent = 1
		else 
			percent = (this.value - this.minimum)/(this.maximum - this.minimum)
		end

		local posx = this.thumb:getPositionX()
		posx = percent * this.bg:getContentSize().width
		this.thumb:setPositionX(posx)
		local textureRect = this.progress:getTextureRect();
		-- textureRect =  CCRectMake(textureRect.origin.x, textureRect.origin.y, posx, textureRect.size.height)
		textureRect =  CCRectMake(textureRect.x, textureRect.y, posx, textureRect.height)
		-- this.progress:setTextureRect(textureRect, this.progress:isTextureRectRotated(), textureRect.size)
		this.progress:setTextureRect(textureRect, this.progress:isTextureRectRotated(), cc.size(textureRect.width, textureRect.height))
		
	end
	
	function container:setMinimumValue(v) this.minimum = v end
	function container:setMaximumValue(v) print("最小值是"..v) this.maximum = v end
	
	function container:reset()
		this.value = 1
		container:layout()
	end
	
	function container:setValue(v)
		this.value = v
		container:layout()
		this.onNewValue(math.floor(this.value))
	end
	function container:setMax(v)
		this.maximum = v
		container:layout()
		this.onNewValue(math.floor(this.value))
	end
	function container:getMax()
		return this.maximum
	end
   function container:getValue() return this.value end
   
	--初始进度
	container:setValue( this.value )
	return container 
end
return M
