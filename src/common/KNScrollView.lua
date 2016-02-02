local KNBtn = require("common.KNBtn") 
--[[
Create Time:	2015.11.17
Author:			Sidney
Description:	背景层不影响触摸事件的实例~
]]
--列表自动滑动方向
local NEXT = 1
local PREVIOUS = 0
KNScrollView={
	x,
	y,
	width,
	height,
	mode,               --模式，0为列表模式，显示多个，能够自由滑动,1为切换模式，每次显示一页，且仅能翻一页
	index,              --切换模式有效，记录当前索引
	count,              --记录滑动列表中现有元素数
	dividerWidth,     	--元素间隔
	nextPos,          	--下一个元素起始位置
	xOffset,	      	-- 横向偏移量
	yOffset,	 		-- 纵向偏移量
	active,   			--当点击到窗口中时，处于激活状态
	horizontal,  		--滑动方向,默认为竖向(true,false)
	validRect,    		--有效的显示区域
	layer,        		--背景层（*好大一个背景层，影响触摸事件）
	baselayer,    		--窗口层
	contentLayer, 		--内容层，在此层中加入精灵等对象
	itemsWidth,   		--添加入元素的宽度，用来计算滑动切换的坐标(横和竖都可以)
	moving,       		--翻页模式正在移动的状态，此状态下禁止操作
	items,         		--添加的元素集合
	itemCount,
	onItemSelected		--点击事件onItemSelected(position)
}

local socket = require "socket"
function KNScrollView:getValidRange(  )
	return self.validRect
end
--params｛｝其它参数，在翻 页模式时可添加page_callback作为翻页回调函数
function KNScrollView:new(x,y,width,height,divider,horizontal,mode,params)
	local this= {}
	setmetatable(this,self)
	self.__index = self

	params = params or {}
  
	--初始化滚动窗口
	this.x = x
	this.y = y
	this.width = width
	this.height = height
	this.validRect = CCRectMake(x,y,width,height)
	
	--print("valid rect",this.validRect)
	this.dividerWidth = divider or 0
	this.nextPos = 0
	this.index = 1
	this.count = 0
	this.xOffset = 0
	this.yOffset = 0
	this.horizontal = horizontal
	this.mode = mode or 0
	this.layer = display.newLayer()--好大一个背景层，影响触摸事件
	this.priority = params.priority or -129



	this.items = {}
	this.itemCount = 0
	--滚动窗口位置与大小设置，超出此窗口的部分都将隐藏	
	this.baseLayer = display.newClippingRectangleNode(cc.rect(0, 0, width, height))
		:addTo(this.layer)
		:align(display.BOTTOM_LEFT, x, y)

	-- this.layer:addChild(this.baseLayer)

	--其他参数，如回调 函数等
	this.params = params or {}
	this.itemsWidth = {}
	--内容层
	this.contentLayer = cc.Layer:create()

	--注册触屏监听
	local tempPos = 0  --保存上一次点击的位置，判断滑动方向
	local lastTouchPt   --最后点击的点坐标
	local lastTime     --最后点击的时间
    	local selectedItem   --将选中的元素保存k
	local function scrollX(x,y)           --此函数在翻页模式时做滑动判断
		if math.abs(x - lastTouchPt.x) > 20 then  -- 当移动超过十个像素判断滑动
			if x > lastTouchPt.x then  --上一页
				if this.index > 1 and this.index <= this.count then
					this:autoScroll(PREVIOUS,this.params)
						else
							this:autoScroll()
						end
				else
					if this.index < this.contentLayer:getChildrenCount() then
						this:autoScroll(NEXT,this.params) --下一页
					else
						this:autoScroll()
					end
				end
		else  -- 否则返回原位置
			this:autoScroll()
		end
	end

	local function inertiaScroll(x,y) -- 此函数在列表模式时做惯性滑动的判断
		local params  --跟据触摸时间判断是否要惯性滑动
		if (device.platform == "ios") then --ios平台有惯性滑动
			if os.clock() - lastTime >0.06 and os.clock() - lastTime < 0.1  then
				local value
				if this.horizontal then
					value = (x - lastTouchPt.x) / (os.clock() - lastTime)
				else
					value = (y - lastTouchPt.y) / (os.clock() - lastTime)
				end
				params = {inertia = value }	--传递滑动的惯性速度
			end
		 else --android 惯性滑动
            if os.clock() - lastTime < 0.3 then
				local value
				if this.horizontal then
					value = (x - lastTouchPt.x) / (os.clock() - lastTime)
				else
					value = (y - lastTouchPt.y) / (os.clock() - lastTime)
				end
				params = {inertia = value }	--传递滑动的惯性速度
			end
		end

		
		this:autoScroll(nil,params)
	end

	this.contentLayer:setPosition(cc.p(0,0));
	this.contentLayer:setTouchEnabled(true)


	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	local lastY,legal = 0,true
	listener:registerScriptHandler(function(touch, event)
		--触摸事件详细解析
		--http://www.cnblogs.com/haogj/p/3784896.html
		if this.name_ then
			print("KNScrollView touch begin by",this.name_)
		else
			print("KNScrollView touch begin")
		end
		--if 1==1 then return true end
		-- if self:getLayer():getParent() then
		-- 	print("x",self:getLayer():getParent():getPositionX(),"y",self.getParent():getPositionY())
		-- end
		print("----------------")
		print("--------")
		print("----",this.validRect)
		local location = touch:getLocation()  
		local x, y = location.x, location.y
		--if this.validRect:containsPoint(cc.p(x,y)) then		
		if this.validRect:containsPoint(cc.p(x,y)) then		
			print("KNScrollView validRect containsPoint点击")
			if this.moving then   --正在移动状态，则屏蔽点击
				print("正在移动状态，则屏蔽点击")
				return false
			end
			this.active = true
			this.contentLayer:stopAllActions()  --点击时停止所有动作
			lastTouchPt = cc.p(x,y)
			lastTime = os.clock()    --保存点击的时间计算滑动的位置
			if this.horizontal then
				this.xOffset = this.contentLayer:getPositionX()
				tempPos = x
			else
				tempPos = y
				this.yOffset = this.contentLayer:getPositionY()
			end	
			-- 滑动偏移判断
			lastY = y
		else
			if this.active then

				this.active = false
				if this.mode == 0 then          --列表模式
					if selectedItem then
						selectedItem:setEnabled(true)
						selectedItem = nil
					end
					inertiaScroll(x,y) --移出后做惯性判断

				else     --翻页模式
					this.moving = true
					scrollX(x,y)
				end
			end
			lastTime = nil
			print("vect 外，则屏蔽点击")
			return false
		end
		print("传递点击")
		return true
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	
		
	listener:registerScriptHandler(function(touch, event)
		
		local location = touch:getLocation()  

		local x, y = location.x, location.y
		local nodePoint = this.contentLayer:convertToNodeSpace(location)
		print("KNScrollView touch move",socket.gettime(),nodePoint.x,nodePoint.y)
		if this.active then    --若激活
			if this.horizontal then
				this.xOffset = this.xOffset + (x - tempPos)
				this.contentLayer:setPosition(cc.p(this.xOffset, this.yOffset))
				tempPos = x
			else
				this.yOffset = this.yOffset + (y - tempPos)
				this.contentLayer:setPosition(cc.p(this.xOffset,this.yOffset))
				tempPos = y
			end
			-- 滑动偏移判断
			if math.abs(y - lastY) > 20 then
	 			legal = false
	 		end
		end	

		print("KNScrollView touch move__",socket.gettime(),this.xOffset,this.yOffset)
	end, cc.Handler.EVENT_TOUCH_MOVED)	
	listener:registerScriptHandler(function(touch, event)
		print("KNScrollView touch end",touch)
		local location = touch:getLocation()  
		local x, y = location.x, location.y
		if this.active then
			print("KNScrollView mode",this.mode)
			if this.mode == 0 then   --列表模式，当点击结束后自动调整菜单
				if selectedItem then
					selectedItem:setEnabled(true)
					selectedItem = nil
				end

				inertiaScroll(x,y)
				--只要不是惯性滑动太厉害，执行点击事件
				if legal then
					local nodePoint = this.contentLayer:convertToNodeSpace(location)
					if this.items[1] then
						local totalHeight = 0
						for k,v in pairs(this.itemsWidth) do
							totalHeight = totalHeight + v
						end
						totalHeight = math.max(totalHeight,this.validRect.height)
						--local selected = (nodePoint.y - this.validRect.height)/80
						local currentHeight = -(nodePoint.y - totalHeight)
						local selectedCursor = 0
						local selected = -1
						for k,v in pairs(this.itemsWidth) do
							selectedCursor = selectedCursor + v
							if selectedCursor >= currentHeight and selected==-1 then
								selected = k
							end
							print("cur cursor",selectedCursor,currentHeight)
						end
						print("KNScrollView selected index",nodePoint.y,totalHeight)
						if this.onItemSelected then
							--selected,poi = math.modf(selected)
							--this.onItemSelected(this.itemCount - math.abs(selected - 1))
							this.onItemSelected(selected)
						end
					end
				end
				legal = true
			else --视图切换模式，当点击结束后换到下一个页面
				this.moving = true
				if this.horizontal then
					scrollX(x,y)
				else
					if y > lastTouchPt.y then
					else
					end
				end
			end
			this.active = false
			tempPos = 0
			lastTouchPt = nil
			lastTime = nil
		end	
	end,cc.Handler.EVENT_TOUCH_ENDED)
	this.layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, this.layer)	


	this.baseLayer:addChild(this.contentLayer)

	--若有加入翻页按钮选项,则将滑动组件两边添加按钮,按钮需要向前的方向，程序中进行翻转
	if this.params["turnBtn"] then
		local str = this.params["turnBtn"]
		local i, index = 0

		while true do
			i = string.find(str,"/",i + 1)
			if i ~= nil then
				index = i
			else
				break
			end
		end
		local btn1 = KNBtn:new(string.sub(str,0,index-1),
						{string.sub(str,index+1,string.len(str))},
						x,y,{
						priority = this.params.turnBtnPriority or nil ,
						callback=
						function()
							if this.xOffset >= 0 then --若已到最左边

							else
								local total = 0
								for i,v in pairs(this.itemsWidth) do
									total = total + v
									if total + this.xOffset>= 0 then
										this.xOffset = -(total - v)
										this.contentLayer:runAction(cc.MoveTo:create(0.2,cc.p(this.xOffset,this.yOffset)))
										break
									end
								end
							end
						end})
		local btn2 = KNBtn:new(string.sub(str,0,index-1),
						{string.sub(str,index+1,string.len(str))},
						x,y,{
						priority = this.params.turnBtnPriority or nil ,
						callback=
						function()
							if this.xOffset + this.nextPos <= this.width  then --若已到最右边
								print("最右")
							else
								local total = 0
								for i,v in pairs(this.itemsWidth) do
									total = total + v
									if total + this.xOffset >= 0 then
										if total + this.xOffset > 0 then
											this.xOffset = -total
										else
											this.xOffset = -(total + v)
										end
										this.contentLayer:runAction(cc.MoveTo:create(0.2,cc.p(this.xOffset,this.yOffset)))
										break
									end
								end
							end
						end})
		if horizontal then
			btn1:setPosition(x - btn1:getWidth(),y + (height - btn1:getHeight()) / 2)
			btn2:setPosition(x + width,y + (height - btn2:getHeight()) / 2)
		else
			btn1:setPosition(x + ( width - btn1:getWidth() ) / 2 ,200 )
			btn2:setPosition(x + ( width - btn1:getWidth() ) / 2 ,100)
		end

		btn1:setFlip(true)

		this.layer:addChild(btn1:getLayer())
		this.layer:addChild(btn2:getLayer())
	end
	return this
end

--向view中添加元素，自行调 整位置,添加按钮时将按钮元素加入表中
function KNScrollView:addChild(content,item)
	if item then
		table.insert(self.items,item)
		self.itemCount = self.itemCount + 1
	end
	content:setAnchorPoint(cc.p(0,0))
	if self.horizontal then
		--content:setPosition(cc.p(self.dividerWidth + self.nextPos,0))
		content:setPosition(cc.p(self.dividerWidth + self.nextPos, content:getPositionY()))
		self.nextPos =  content:getPositionX() + content:getContentSize().width

		table.insert(self.itemsWidth,content:getContentSize().width)
	else
		print("KNScrollView addChild,contentLayer=",self.contentLayer:getChildrenCount())
		if self.contentLayer:getChildrenCount()== 0 then
			self.nextPos = self.height - content:getContentSize().height
		else
			self.nextPos = self.nextPos - content:getContentSize().height
		end
		--content:setPosition(cc.p(0,self.nextPos - self.dividerWidth))
		content:setPosition(cc.p(content:getPositionX(),self.nextPos - self.dividerWidth))
		self.nextPos = self.nextPos - self.dividerWidth

		table.insert(self.itemsWidth,content:getContentSize().height)
	end
	self.count = self.count + 1
	self.contentLayer:addChild(content)
end

function KNScrollView:addChild2(content,item)
	if item then
		table.insert(self.items,item)
	end
	content:setAnchorPoint(cc.p(0,0))
	if self.horizontal then
		content:setPosition(cc.p(self.dividerWidth + self.nextPos,0))
		self.nextPos =  content:getPositionX() + content:getContentSize().width

		table.insert(self.itemsWidth,content:getContentSize().width)
	else
		if self.contentLayer:getChildrenCount()== 0 then
			self.nextPos = self.height - content:getContentSize().height
		else
			self.nextPos = self.nextPos - content:getContentSize().height
		end
		content:setPosition(cc.p(0,self.nextPos - self.dividerWidth))
		self.nextPos = self.nextPos - self.dividerWidth

		table.insert(self.itemsWidth,content:getContentSize().height)
	end
	self.count = self.count + 1
	self.contentLayer:addChild(content)
end

function KNScrollView:addBatch(batch)
	self.contentLayer:addChild(batch)
end

--设置元素居中显示
function KNScrollView:alignCenter()
	local group = self.contentLayer:getChildren()
	local item
	if group then
		-- for i = 0,group:count()-1 do
		print("---------count:", #group)
		-- for i,v in ipairs(group) do
		-- 	print(i,v)

		-- end
		for i = 1,#group do
			-- item = group:objectAtIndex(i)	
			item = group[i]	
			-- tolua.cast(item,"CCLayer")
			tolua.cast(item,"cc.Layer")
			if self.horizontal then
				item:setPositionY((self.height - item:getContentSize().height) / 2)
			else
				item:setPositionX((self.width - item:getContentSize().width) / 2)
			end
		end
	end
end

--滑动组件进入动画效果
function KNScrollView:effectIn()
	local group = self.contentLayer:getChildren()
	local item
	local time, count = 0.1, 1
	if group then
		-- for i = 0, group:count() - 1 do
		-- 	item = group:objectAtIndex(i)
		-- 	local posX = item:getPositionX()
		-- 	local posY = item:getPositionY()
		-- 	if (posY + self.yOffset > -item:getContentSize().height) and (posY + self.yOffset < self.height) then
		-- 		item:setPositionX(-item:getContentSize().width)	
		-- 		item:runAction(CCMoveTo:create(time,cc.p(posX,item:getPositionY())))
		-- 		time = time + count * 0.02
		-- 		count = count + 1
		-- 	end
		-- end
		for i,v in ipairs(group) do
			item = v
			local posX = item:getPositionX()
			local posY = item:getPositionY()
			if (posY + self.yOffset > -item:getContentSize().height) and (posY + self.yOffset < self.height) then
				item:setPositionX(-item:getContentSize().width)	
				item:runAction(cc.MoveTo:create(time,cc.p(posX,item:getPositionY())))
				time = time + count * 0.02
				count = count + 1
			end			
		end
	end
end
function KNScrollView:getChildren2(  )
	return self.contentLayer:getChildren()
end
--跟据视图状态自动滚动
function KNScrollView:autoScroll(direction,params,noAni) --参数在视图切换模式时使用
	local autoMove
	local cha --菜单项与显示栏的差值，若小于显示窗则自动滚动时回到原点
	local time = 0.2 
	
	if noAni then
		time = 0
	end
	
	if self.horizontal then
		if self.mode == 0 then  -- 列表模式
			if self.xOffset + self.nextPos < self.width then  --若已滑动到最右端
				cha = self.width - self.nextPos -- 若菜单 小于可显示区域
				if cha < 0 then
					cha = 0
				end
				self.xOffset = self.width - self.nextPos - cha
				--时间为0的时候直接设置位置,可以避免取绝对位置的误差
				if time == 0 then
					setAnchPos(self.contentLayer, self.xOffset, self.contentLayer:getPositionY())
				else
					autoMove = cc.MoveTo:create(time,cc.p(self.xOffset,self.contentLayer:getPositionY()))
					self.contentLayer:runAction(autoMove)
				end
			elseif self.xOffset > 0 then           --若已滑动到最左端
				self.xOffset = 0
				if time == 0 then
					setAnchPos(self.contentLayer, self.xOffset, self.contentLayer:getPositionY())
				else
					autoMove = cc.MoveTo:create(time,cc.p(self.xOffset,self.contentLayer:getPositionY()))
					self.contentLayer:runAction(autoMove)
				end
			else
				if params and params["inertia"] then    --惯性滑动条件
					self.xOffset = params["inertia"] + self.xOffset
					--当滑动的位置大超出边界，则将最终位置设置为能够启用回弹效果的位置
					if self.xOffset > 0 then
						self.xOffset = self.width / 8
					elseif self.xOffset + self.nextPos < self.width then
						self.xOffset =self.width / 1.2 -self.nextPos
					end
					-- local array = CCArray:create()
					-- array:addObject(CCEaseExponentialOut:create(CCMoveTo:create(1,cc.p(self.xOffset,self.yOffset))))
					-- array:addObject(CCCallFunc:create(function() self:autoScroll() end))
					-- self.contentLayer:runAction(CCSequence:create(array))

					local seq = transition.sequence({
						cc.EaseExponentialOut:create(cc.MoveTo:create(1,cc.p(self.xOffset,self.yOffset))),
						cc.CallFunc:create(function() self:autoScroll() end)
					})
					self.contentLayer:runAction(seq)

				elseif params and params["scrollTo"] then --在列表模式时设置将第几个元素滑动到可见位置
					local total = 0
					for i = 1, params["scrollTo"] do
						total = total + self.itemsWidth[i]
					end
					if total + self.xOffset < self.itemsWidth[params["scrollTo"]] / 2 then
						self.xOffset = -(total - self.itemsWidth[params["scrollTo"]])
					elseif total + self.xOffset > self.width then
						self.xOffset = self.xOffset - self.itemsWidth[params["scrollTo"]]
					end
					if time == 0 then
						setAnchPos(self.contentLayer, self.xOffset, self.yOffset)	
					else
						self.contentLayer:runAction(cc.MoveTo:create(time,cc.p(self.xOffset,self.yOffset)))
					end
				end
			end
		else     -- 视图切换模式
			if direction == NEXT then   -- 下一页
				self.index = self.index + 1
			elseif direction == PREVIOUS then
				self.index = self.index - 1
			elseif params and params["index"] then    --设置滑动到第几页
				self.index = params["index"]
			end
			self.xOffset = -(self.width + self.dividerWidth) * (self.index - 1)
			--翻页后的callback

			-- local array = CCArray:create()
			-- array:addObject(CCMoveTo:create(time,cc.p(self.xOffset,self.contentLayer:getPositionY())))
			-- array:addObject(CCCallFunc:create(function()
			-- 	self.moving = false
			-- end))
			-- if params and params["page_callback"] then
			-- 	array:addObject(CCCallFunc:create(params["page_callback"]))
			-- end
			-- autoMove = CCSequence:create(array)


			if params and params["page_callback"] then
				autoMove = transition.sequence({
					cc.MoveTo:create(time,cc.p(self.xOffset,self.contentLayer:getPositionY())),
					CCCallFunc:create(function()
						self.moving = false
					end),
					cc.CallFunc:create(params["page_callback"])
				})
			else
				autoMove = transition.sequence({
					cc.MoveTo:create(time,cc.p(self.xOffset,self.contentLayer:getPositionY())),
					cc.CallFunc:create(function()
						self.moving = false
					end),
				})
			end


			self.contentLayer:runAction(autoMove)
		end
	else     --纵向滑动
		if self.mode == 0 then   --列表模式
			if self.nextPos + self.yOffset > 0 then --已到最底部
				if self.nextPos < 0 then
					self.yOffset = math.abs(self.nextPos)
				else
					self.yOffset = 0
				end
				if time == 0 then
					setAnchPos(self.contentLayer, self.contentLayer:getPositionX(), self.yOffset)
				else
					autoMove = cc.MoveTo:create(time,cc.p(self.contentLayer:getPositionX(),self.yOffset))
					self.contentLayer:runAction(autoMove)
				end
			elseif self.yOffset < 0 then   -- 已到最顶部
				self.yOffset = 0
				autoMove = cc.MoveTo:create(time,cc.p(self.contentLayer:getPositionX(),self.yOffset))
				if time == 0 then
					setAnchPos(self.contentLayer, self.contentLayer:getPositionX(), self.yOffset)
				else
					autoMove = cc.MoveTo:create(time,cc.p(self.contentLayer:getPositionX(),self.yOffset))
					self.contentLayer:runAction(autoMove)
				end	
			else  --惯性滑动位置
				if params and params["inertia"] then    --惯性滑动条件
					self.yOffset = params["inertia"] + self.yOffset
					if self.yOffset < 0 then
						self.yOffset = -self.height / 8
					elseif self.yOffset + self.nextPos > 0  then
						self.yOffset = math.abs(self.nextPos) + self.height / 8
					end
					-- local array = CCArray:create()
					-- array:addObject(CCEaseExponentialOut:create(CCMoveTo:create(1,cc.p(self.xOffset,self.yOffset))))
					-- array:addObject(CCCallFunc:create(function() self:autoScroll() end))
					-- self.contentLayer:runAction(CCSequence:create(array))

					local seq = transition.sequence({
						cc.EaseExponentialOut:create(cc.MoveTo:create(1,cc.p(self.xOffset,self.yOffset))),
						cc.CallFunc:create(function() self:autoScroll() end)
					})	
					self.contentLayer:runAction(seq)
				end
			end
		else  --  翻页切换模式
		end
	end
end
--返回主布局对象
function KNScrollView:getLayer()
--	return self.baseLayer
	return self.layer
end

function KNScrollView:getX()
	return self.x
end

function KNScrollView:getY()
	return self.y
end

function KNScrollView:getOffsetX()
--	return self.xOffset						--最终的偏移量
	return self.contentLayer:getPositionX() --实际的偏移量
end

function KNScrollView:getOffsetY()
	return self.contentLayer:getPositionY() --实际偏移量
--	return self.yOffset						--最终编移量
end

function KNScrollView:getOffset()
	if self.horizontal then
		return self:getOffsetX()
	else
		return self:getOffsetY()
	end
end

function KNScrollView:getWidth()
	return self.width
end

function KNScrollView:getHeight()
	return self.height
end

function KNScrollView:getCurIndex()
	return self.index
end

--返回所有元素
function KNScrollView:getItems(index)
	if index then
		return self.items[index]
	else
		return self.items
	end
end

--点击范围 是否有效
function KNScrollView:isLegalTouch(x,y)
	return CCRectMake(self.x,self.y,self.width,self.height):containsPoint(cc.p(x,y))
end

function KNScrollView:removeAll()
	for k,v in pairs(self.items) do
		if v.release then
			self.itemCount = self.itemCount - 1
			v:release()
		end
	end
end


--设置当前的选项
function KNScrollView:setIndex(index,noAni,space)
	self.index = index
	if self.horizontal then	
		self.xOffset = -(space or self.itemsWidth[1] + self.dividerWidth) * (self.index - 1)
		if noAni then
			self.contentLayer:setPosition(cc.p(self.xOffset,self.contentLayer:getPositionY()))
		end
	else
		self.yOffset = (space or self.itemsWidth[1] + self.dividerWidth) * (self.index - 1)
		if noAni then
			self.contentLayer:setPosition(cc.p(self.contentLayer:getPositionX(),self.yOffset))
		end
	end
	self:autoScroll(nil,nil,noAni)
end

function KNScrollView:scrollTo(id)
	local index
	for k, v in pairs(self.items) do
		if v:getId() == id then
			index = k
			break
		end
	end
	if index then
		self:setIndex(index)
	end
end
--重新设置大小暂不可用，没调好
function KNScrollView:setContentSize( x , y , width , height , addValue )
	self.x = x 
	self.y = y 
	self.width = width 
	self.height = height 
	
	self.contentLayer:setPosition( cc.p( self.contentLayer:getPositionX() , self.contentLayer:getPositionY() + addValue ))
	self.baseLayer:setPosition(cc.p(x, y))
	--self.baseLayer:setContentSize( CCSizeMake( width , height ) )
	self.baseLayer:setContentSize( cc.rect( width , height ) )
end
function KNScrollView:setOffset(offset)
	if self.horizontal then
		self.xOffset = offset
		self.contentLayer:setPositionX(offset)
	else
		self.yOffset = offset
		self.contentLayer:setPositionY(offset)
	end
end
function KNScrollView:setPosition( p )
	print("KNScrollView setPosition",p.x,p.y)
	local x,y=p.x,p.y
	self:getLayer():setPosition(p)
	
	self.validRect = CCRectMake(x,y,self.width,self.height)

end
function KNScrollView:setEnable(bool)
	self.contentLayer:setTouchEnabled(bool)
end