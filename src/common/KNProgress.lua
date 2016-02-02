local KNProgress = {
	layer,
	params,
	progress,
	percent,
	text
}

function KNProgress:new(dir, res, x, y, params)
	local this = {} 
	setmetatable(this,self)
	self.__index = self
	
	this.params = params or {}
	this.layer = display.newLayer()
	
	local res = res or {}
	
	local bg = display.newSprite(dir..res[1])
	setAnchPos(bg)
	this.layer:addChild(bg)
	
	this.layer:setContentSize(bg:getContentSize())
	setAnchPos(this.layer, x, y)
	
	this.progress = CCProgressTimer:create(display.newSprite(dir..res[2]))
	setAnchPos(this.progress)
	
	this.percent  = this.params.cur / this.params.max * 100
	local percent
	if this.percent > 0 and this.percent < 20 then
		percent = 20
	else
		percent = this.percent
	end
	
	--进度条的属性设置
	this.progress:setType(kCCProgressTimerTypeBar)           --类型，kCCProgressTimerTypeBar 横向，kCCProgressTimerRidial 圆
	this.progress:setMidpoint(ccp(0, 0))                     --进度方向
	this.progress:setBarChangeRate(ccp(1,0))                 --对应方向上是否进行设置
	this.progress:setPercentage(percent)                           --进度0--100
	this.layer:addChild(this.progress)
	
	if this.params.showText then
		this.text = createLabel({str = this.params.cur.."/"..this.params.max, size = 16, color = this.params.color or ccc3(0x2c, 0, 0)})
		setAnchPos(this.text, this.layer:getContentSize().width / 2, this.layer:getContentSize().height / 2,0.5, 0.5)
		this.layer:addChild(this.text)
	end
	
	return this
end

function KNProgress:getCur()
	return self.percent
end

function KNProgress:getLayer()
	return self.layer
end



return  KNProgress