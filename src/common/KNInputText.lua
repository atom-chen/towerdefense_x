--带光标输入文本框
local M = {}

function M:new( params )
	local this = {}
	setmetatable(this , self)
	self.__index = self
	params = params or {}
	
	this.width = params.width or 100		--文字框宽度
	this.height = params.height or 22		--文本框高度
	this.size = params.size or 20			--文字大小
	this.defStr = params.defStr or ""		--默认提醒字符串
	this.textstr = params.existStr or ""	--已经存在的字符(主要在用在帐号输入的地方，如果帐号已经存在，就将字符存起来)
	
	local defColor = params.defColor or ccc3( 0xff , 0xfb , 0xd4 )
	local inputColor = params.inputColor or ccc3( 0x4d , 0x15 , 0x15 )
	
	
				
	this.tempText = CCLabelTTF:create( this.textstr , FONT ,  this.size )
	this.handle = nil
	this.layer = display.newLayer()
	this.layer:addChild( this.tempText )
	this.tempText:setVisible( false )
	
	
	local windowlayer
	-- 输入框
	-- this.textfield = CCTextFieldTTF:textFieldWithPlaceHolder( this.defStr , FONT , this.size )
	this.textfield = ccui.TextField:create( this.defStr , FONT , this.size )
	this.textfield:setString( this.textstr )
	setAnchPos( this.textfield , 0 , 0 , 0 , 0.5 )
	this.textfield:setColor( defColor )
	-- this.textfield:setColorSpaceHolder( inputColor )
	this.textfield:setPlaceHolderColor( inputColor )
	
	windowlayer = UICutLayer:create()--WindowLayer:createWindow()
	windowlayer:setAnchorPoint( ccp( 0 , 0.5 ) )
	windowlayer:setContentSize( CCSizeMake( this.width , this.height + 5 ) )
	windowlayer:addChild( this.textfield )
	this.layer:addChild( windowlayer )
	
	this.cursor = display.newSprite( COMMONPATH .. "cursor.png" )
	setAnchPos(this.cursor , this.size/2 , 0 , 1 , 0.5 )
	this.layer:addChild( this.cursor )
	this.cursor:setVisible( false )
	this.cursor:setScaleY( this.cursor:getContentSize().height/this.height * 2 )
	return this
end

function M:getLayer()
	return self.layer
end

function M:startInput()
	local function refreshFun( isForce )
		local curStr = self.textfield:getString()
		if self.textstr ~= curStr or isForce then
			self.textstr = curStr
			self.tempText:setString( self.textstr )
			local curWidth =  self.tempText:getContentSize().width
			if  curWidth < self.width then
				setAnchPos( self.textfield , 0 , 0 , 0 , 0.5 )
			else
				setAnchPos( self.textfield , self.width , 0 , 1 , 0.5 )
			end
			
			setAnchPos(self.cursor , curWidth > self.width and self.width + self.size/2  or curWidth + self.size/2 , 0 , 1 , 0.5 )
		end
	end
	
	local delayTime = 0.5
	local function blinkFun()
		-- local actionAry = CCArray:create()
		-- actionAry:addObject( CCCallFunc:create( function() self.cursor:setVisible( true ) end ) )
		-- actionAry:addObject( CCDelayTime:create( delayTime ) )
		-- actionAry:addObject( CCCallFunc:create( function() self.cursor:setVisible( false ) end ) )
		-- actionAry:addObject( CCDelayTime:create( delayTime  ) )
		-- actionAry:addObject( CCCallFunc:create( blinkFun ) )
		-- self.layer:runAction( CCSequence:create( actionAry ) )

		local seq = transition.sequence({
			CCCallFunc:create( function() self.cursor:setVisible( true ) end ),
			CCDelayTime:create( delayTime ),
			CCCallFunc:create( function() self.cursor:setVisible( false ) end ),
			CCDelayTime:create( delayTime  ),
			CCCallFunc:create( blinkFun ),
		})
		self.layer:runAction(seq)
	end
	blinkFun()
	
	self.handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( function() refreshFun() end , 0.1 , false )
	refreshFun( true )
--	self.textfield:setString("")
	self.textfield:attachWithIME()
end

function M:stopInput( isClear )
	
	if self.handle then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.handle)
		self.handle = nil
		
		setAnchPos( self.textfield , 0 , 0 , 0 , 0.5 )
--		self.textfield:setString( self.textstr )
		if isClear then self.textfield:setString( "" ) end
		self.textfield:detachWithIME()
		self.cursor:setVisible( false )
		transition.stopTarget( self.layer )
	end
	
end

function M:getString()
	return self.textfield:getString()
end
--返回文字个数
function M:getCharCount()
	return self.textfield:getCharCount()
end

return M