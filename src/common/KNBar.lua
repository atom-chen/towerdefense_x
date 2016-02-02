--[[
	进度条
]]--
local M = {}
--KNBar = {path="",x=0,y=0,percent = 0,container = nil,param={}}
--这句是重定义元表的索引，就是说有了这句，这个才是一个类。具体的解释，请百度。
--KNBar.__index = KNBar
--构造体，构造体的名字是随便起的，习惯性改为new()
function M:new(pathStr,x,y, param)
		--[[{
			"icon" : {"icon_x" : 100,"icon_y" : 188}
			"text" : {}
		}]]--

		--        local this = {}  --初始化this，如果没有这句，那么类所建立的对象改变，其他对象都会改变
		--        setmetatable(this, KNBar)  --将this的元表设定为Class
        local this = {}
        this.path = path   --属性值初始化
        this.x = x
        this.y = y
        this.actionOne = true	--是否是第一次执行动画效果
        this.percent = 0
        
        local isOnlyCur = param.isOnlyCur or false
        local barOffset = param.barOffset or 0
        local textColor = param.color or ccc3( 0xff , 0xff ,0xff )
        local actionTime = param.actionTime or 0.1	--进度条动画时间
        
        if actionTime~= 0.1 then
        	this.actionOne = false
        end
        
        --设置默认值
        if param == nil or type( param ) ~= "table"  then param = { maxValue = 100 , curValue = 0 } end
        -- local isDrag = param.isDrag or false 	--用于圆角类进度条
        local isDrag = false
        local direction = param.direction or 1	--1为从右到左 0 为从左到右
        this.textSize = param.textSize or 18
	this.maxValue = param.maxValue or 100	--最大值
	this.curValue = param.curValue or 0		--当前值
        -- print("################################maxValue:"..this.maxValue)
        -- print("################################curValue:"..this.curValue)

        local container = CCNode:create()	--创建对像容器
		
        local KNBarPath = IMG_PATH.. "image/start_bar/" .. pathStr .. "/"


       	-- 进度条背景
        this.bg = display.newSprite(KNBarPath .. "bg.png")  -- 创建背景
        local curSize = this.bg:getContentSize()
        this.bg:setAnchorPoint(ccp(0 , 0.5))	-- 设置锚点
        container:addChild(this.bg)
        
        -- 进度条前景
        local front = display.newSprite(KNBarPath .. "fore.png")
        local frontSize = front:getContentSize()
        local frontLayer = nil
        -- if isDrag then
        -- 	frontLayer = UICutLayer:create()--WindowLayer:createWindow()
        -- 	container:setAnchorPoint(ccp(0,0.5))
        -- 	setAnchPos( front , -this.x , -( display.height - this.y ) - 3 , 0  , 0.5)
        -- 	frontLayer:addChild(front)
        	
        -- 	frontLayer:setContentSize( CCSizeMake( frontSize.width , 854 ) )
        -- 	setAnchPos( frontLayer , 0 , display.height-this.y , 0, 1 )
        -- else
        container:setAnchorPoint(ccp(0,0))
        this.KNBar = CCProgressTimer:create(front)
        this.KNBar:setType(kCCProgressTimerTypeBar)
        this.KNBar:setMidpoint(CCPointMake(0 , 0))--设置进度方向 (0-100)
        this.KNBar:setAnchorPoint(ccp(0 , 0.5)) --设置锚点
        this.KNBar:setBarChangeRate(CCPointMake(1, 0)) --动画效果值(0或1)
        this.KNBar:setPosition(CCPointMake(0, 0))
        this.KNBar:setPercentage(0)	--设置默认进度值
     	-- end
		
	   	--进度条文字
	   	this.text = CCLabelTTF:create("0/" .. this.maxValue , FONT , 15)
	   	this.text:setAnchorPoint( ccp(0.5 , 0.5) )
	   	this.text:setColor( textColor )
	   	
	   	local textSize = this.text:getContentSize()
	   	local bgSize = this.bg:getContentSize()
	   	this.text:setPosition( bgSize.width / 2 , 0 )
	   	container:addChild(this.text , 7)
	   	

	   	--进度条Icon
	   	if(isset(param , "icon")) then
		   	local icon = display.newSprite(KNBarPath .. "icon.png")
		   	local iconX = param.icon.x or 0
		   	local iconY = param.icon.y or 0
		   	local iconSize = icon:getContentSize()
		   	icon:setAnchorPoint(ccp(0 , 0.5))
		   	icon:setPosition(0,0)
		   	container:addChild( icon , 6)
		   	this.KNBar:setPosition(CCPointMake(iconSize.width/2 + 12 + barOffset, 0))
		   	this.bg:setPosition(ccp(iconSize.width/2 + 12 + barOffset , 0))
		   	local textSize = this.text:getContentSize()
	   		setAnchPos(this.text , bgSize.width / 2 + iconSize.width/2 + 10+ barOffset , 0 , 0.5 , 0.5 )
	   	end



		if isDrag then
			container:addChild(frontLayer)
		else
			container:addChild(this.KNBar)
		end
                 container:setPosition(ccp( this.x , this.y ) )--设置坐标




        --通过设置绝对值，修改界面。
        function container:setCurValue(_num , is_action)
            this.curValue = _num
            local percent = this.curValue / this.maxValue
            

            if is_action then
                container:setActionPercent(percent)
            else
                container:setPercent(percent)
            end
        end

        --通过设置百分比，修改界面。   无动画设置进度值
        function container:setPercent(_num)
        	--无动画
        	this.percent = _num
        	if _num > 0 then
	        	_num = _num > 0.1 and _num or 0.1
        	end
        	
        	this.curValue = this.percent * this.maxValue
        	
        	if isOnlyCur then
	        	this.text:setString(this.curValue )
        	else
	        	this.text:setString(this.curValue .. "/" .. this.maxValue)
        	end
        	
        	if isDrag then
        		local addX = direction == 0 and ( frontSize.width - ( frontSize.width * _num ) ) - this.x or ( frontSize.width * ( _num - 1) )
        		transition.moveTo( front , { x = addX , time = 0.1 } ) 
        	else
                    -- print("################################setPercent:", _num * 100)
	        	this.KNBar:setPercentage(_num * 100)   --无动画效果
        	end
        end

        --通过设置百分比，修改界面。   有动画进度设置
        function container:setActionPercent(_num)
        	--无动画
        	this.percent = _num
        	_num = _num > 0.1 and _num or 0.1
        	this.curValue = this.percent * this.maxValue
        	
        	if isOnlyCur then
	        	this.text:setString( this.curValue )
        	else
	        	this.text:setString(this.curValue .. "/" .. this.maxValue)
        	end
        	--有动画效果
        	if isDrag then
        		container:setPercent( _num )
        	else
	    	 local to1
	        	if  this.actionOne  then
	        		this.actionOne = false
	    	 	 to1 = CCProgressTo:create(0,_num * 100)
	        		this.KNBar:runAction(to1)--执行一次
	        	else
	        		if this.curValue < this.maxValue then
		    	       	to1 = CCProgressTo:create( actionTime ,_num * 100 )
		        		this.KNBar:runAction(to1)--执行一次
		        	end
	        	end
        	end

        end

        --返回进度值
        function container:getPercent()
        	return this.percent * 100
        end

        --返回当前值
        function container:getPercentValue()
        	return this.percent * this.maxValue
        end

        --设置最大值
        function container:setMaxValue(_num)
        	this.maxValue=_num
        	container:setPercent(this.curValue/this.maxValue)
        end
        --返回最大值
        function container:getMaxValue()
        	return this.maxValue
        end


        --是否显示文字
        function container:setIsShowText( isShow )
        	this.text:setVisible( isShow )
        end
        
		container:setContentSize( CCSize( curSize.width , curSize.height ) )
                container:setPercent(this.curValue/this.maxValue)
     	return container  --返回自身
end



return M







