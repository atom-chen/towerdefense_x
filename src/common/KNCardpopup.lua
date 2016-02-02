local KNMask = requires("Common.KNMask")
--[[卡片弹出-获得卡片效果]]
local KNCardpopup = {
	params,
	mask
}
	
function KNCardpopup:new(cid , callback , params)
	local this = {}
	setmetatable(this,self)
	self.__index = self

	this.params = {
		cid = cid,
		callback = callback or function() end,
		init_x = params.init_x or 0,
		init_y = params.init_y or 0,
		end_x = params.end_x or 0,
		end_y = params.end_y or 0,
		top_tips = params.top_tips or nil,
		top_tips_x = params.top_tips_x or 100,
		top_tips_y = params.top_tips_y or 720,
		offset_x = params.offset_x or 0,
		offset_y = params.offset_y or 0,
	}

	return this
end

--[[设置参数]]
function KNCardpopup:setParams(params)
	for key , v in pairs(params) do
		self.params[key] = v
	end
end

--[[开始播放]]
function KNCardpopup:play()

	local cid = self.params.cid
	local group = display.newLayer()


	-- 背景光影
	local light = display.newSprite(IMG_PATH .. "image/scene/newguy/light.png")
	setAnchPos(light , display.cx , 515 + self.params.offset_y , 0.5 , 0.5)
	group:addChild(light)

	-- 光影转动动作
	local light_action
	light_action = function(rotate)
		transition.rotateTo(light , {time = 10 , rotate = rotate , onComplete = function()
			if rotate == 180 then rotate = 360 else rotate = 180 end
			light_action(rotate)
		end})
	end
	light_action(180)

	-- 卡牌数据
	local cid_type = getCidType(cid)
	local config = getConfig(cid_type , cid)
	if cid_type == "petskill" and config ~= nil then
		config = config["1"]
	end


	-- 卡牌背景
	local bg = display.newSprite(IMG_PATH .. "image/scene/newguy/card_bg_1.png")
	setAnchPos(bg , display.cx , 315  + self.params.offset_y , 0.5)
	group:addChild(bg)

	-- 大图背景（只有技能有）
	if cid_type == "skill" or cid_type == "petskill" then
		local skill_bg = display.newSprite(IMG_PATH .. "image/scene/detail/skill_bg.png")
		setAnchPos(skill_bg , display.cx , 425  + self.params.offset_y , 0.5)
		group:addChild(skill_bg)
	end

	-- 卡牌大图
	local big_icon = display.newSprite(getImageByType(cid , "b"))
	setAnchPos(big_icon , display.cx , 395  + self.params.offset_y , 0.5)
	group:addChild(big_icon)
	if cid_type == "equip" then
		setAnchPos(big_icon , display.cx , 450  + self.params.offset_y , 0.5)
	elseif cid_type == "skill" or cid_type == "petskill" then
		setAnchPos(big_icon , display.cx - 3 , 527  + self.params.offset_y , 0.5)
	end


	-- 卡牌名字
	if config ~= nil and config["name"] then
		local name_bg = display.newSprite(IMG_PATH .. "image/scene/newguy/name_bg_small.png")
		setAnchPos(name_bg , display.cx , 355  + self.params.offset_y , 0.5)
		group:addChild(name_bg)

		local show_name = config["name"]
		if cid_type == "general" and config["bieming"] and config["bieming"] ~= "" then
			show_name = "[" .. config["bieming"] .. "]" .. config["name"]
		end
		local name_ttf = CCLabelTTF:create(show_name , FONT , 26)
		setAnchPos(name_ttf , display.cx , 365  + self.params.offset_y , 0.5)
		group:addChild(name_ttf)
	end

	-- 卡牌星级
	if config ~= nil and config["star"] then
		local star_num = config["star"]
		-- local star_init_x = 175 + (5 - star_num) * 14
		local star_init_y = 655 + self.params.offset_y
		for i = 1 , star_num do
			local star = display.newSprite(COMMONPATH .. "star.png")
			setAnchPos(star , 330 , 580 + self.params.offset_y - (i - 1) * 28 )
			group:addChild(star)
		end
	end

	if self.params.top_tips ~= nil then
		group:addChild(self.params.top_tips)
	end


	group:setScale(0.2)
	group:setPosition( self.params.init_x , self.params.init_y )
	transition.moveTo(group, {
		time = 0.1,
		x = 0,
		y = 0,
	})
	transition.scaleTo(group, {
		time = 1.2,
		scale = 1,
		easing = "ELASTICOUT",
	})


	group:setTouchEnabled( true )

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(false)
	listener:registerScriptHandler(function(touch, event)
		print("kncardpopup----------EVENT_TOUCH_BEGAN:")
		group:setTouchEnabled( false )
		-- local location = touch:getLocation()  
		-- local x, y = location.x, location.y
		
		transition.scaleTo(group, {
			time = 0.15,
			scale = 0.2,
		})
		transition.moveTo(group, {
			time = 0.15,
			x = self.params.end_x,
			y = self.params.end_y,
			onComplete = function()
				self.mask:remove()
				i7PlaySound(IMG_PATH .. "sound/reward.mp3")
				self.params.callback(index)
			end
		})
		return false
	end, cc.Handler.EVENT_TOUCH_BEGAN)
	group:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, group)

--[[
	group:addTouchEventListener(function()
		group:setTouchEnabled( false )

		transition.scaleTo(group, {
			time = 0.15,
			scale = 0.2,
		})
		transition.moveTo(group, {
			time = 0.15,
			x = self.params.end_x,
			y = self.params.end_y,
			onComplete = function()
--				group:removeSelf()
				self.mask:remove()
				i7PlaySound(IMG_PATH .. "sound/reward.mp3")
				-- 执行回调
				self.params.callback(index)
			end
		})
	end , false , -139)]]
	
	
	
	self.mask = KNMask:new({item = group})

	return self.mask:getLayer()
end


return KNCardpopup