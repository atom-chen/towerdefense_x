crypto = require("framework.crypto")
-- MD5
function MD5(str)
	-- local key = netfun.get_crykey()
	-- print("--------------------MD5_key:", key)
	-- return crypto.md5(str..key)

	local key = "kshyiu54difud*iuoit$%d"
	return crypto.md5(str .. key)
	-- return crypto.md5(str..netfun.get_crykey())
end

--混合msas生成新精灵
function mixedGraph(originSp,maskSp)
	rt = CCRenderTexture:create(rectWidth, rectHeight)
	maskSp:setAnchorPoint(ccp(0,0))
	originSp:setAnchorPoint(ccp(0,0))
	--[[指定了新来的颜色(source values)如何被运算。九个枚举型被接受使用：
	GL_ZERO, 
	GL_ONE, 
	GL_DST_COLOR,
	GL_ONE_MINUS_DST_COLOR,
	GL_SRC_ALPHA, 
	GL_ONE_MINUS_SRC_ALPHA, 
	GL_DST_ALPHA, 
	GL_ONE_MINUS_DST_ALPHA, 
	GL_SRC_ALPHA_SATURATE.
	
	参数 destfactor:
	指定帧缓冲区的颜色(destination values)如何被运算。八个枚举型被接受使用：
	GL_ZERO, 
	GL_ONE, 
	GL_SRC_COLOR, 
	GL_ONE_MINUS_SRC_COLOR, 
	GL_SRC_ALPHA, 
	GL_ONE_MINUS_SRC_ALPHA, 
	GL_DST_ALPHA,
	GL_ONE_MINUS_DST_ALPHA]]--
	
	blendFunc=ccBlendFunc:new()
	blendFunc.src = 1
	blendFunc.dst = 1
	maskSp:setBlendFunc(blendFunc)
	
	blendFunc.src = 6			-- mask图片的当前alpha值是多少，如果是0（完全透明），那么就显示mask的。如果是1（完全不透明）
	blendFunc.dst = 0				-- maskSprite不可见
	maskSp:setBlendFunc(blendFunc)
	
	
	local org_visit = originSp.visit
	
	function originSp.visit(self)
		glEnable(GL_SCISSOR_TEST)
		glScissor(0, 0, rectWidth, rectHeight)
		org_visit(self)
		glDisable(GL_SCISSOR_TEST);
	end
	rt:begin()
	maskSp:visit()
	originSp:visit()
	rt:endToLua()
	


	
	local retval = CCSprite:createWithTexture(rt:getSprite():getTexture())
	retval:setFlippedY(true)--是否翻转
	return retval
end

--[[ 获取所有子节点里的 CCSprite ]]
function getAllSprites( root )
	local sprites = {}

	local function _getAllSprites( _root )
		local childs_num = _root:getChildrenCount()
		if childs_num == 0 then return end

		local childs = _root:getChildren()
		-- for i = 0 , childs_num - 1 do
		-- 	local child = tolua.cast( childs:objectAtIndex(i) , "CCNode")

		-- 	if child:getTag() == 102 then
		-- 		sprites[#sprites + 1] = tolua.cast( child , "CCSprite")
		-- 	end

		-- 	_getAllSprites(child)
		-- end
		for i,v in ipairs(childs) do
			local child = tolua.cast(v , "cc.Node")
			if child:getTag() == 102 then
				sprites[#sprites + 1] = tolua.cast( child , "cc.Sprite")
			end
			_getAllSprites(child)			
		end
	end

	_getAllSprites( root )

	return sprites
end

--设置锚点与位置,x,y默认为0，锚点默认为0
function setAnchPos(node,x,y,anX,anY)
	local posX , posY , aX , aY = x or 0 , y or 0 , anX or 0 , anY or 0
	node:setAnchorPoint(ccp(aX,aY))
	node:setPosition(ccp(posX,posY))
end
local ConfigData = {}
--根据type读取相应的配置文件
function getConfig(type,cid,key,other)
	local config = ConfigData[type]
	if config == nil then
		if type == "equip" then
			config = requires("Config.Equipment")
		elseif type == "general" then
			config = requires("Config.Hero")
		elseif type == "pet"  then
			config = requires("Config.Pet")
		elseif type == "prop" then
			config = requires("Config.Prop")
		elseif type == "skill" or type == "generalskill" then
			config = requires("Config.Skill")
			if cid>10000 then
				cid = math.floor(cid/100)
			end
		elseif type == "natural" then
			config = requires("Config.CombinationAttributes")
		elseif type == "suit" then
			config = requires("Config.Suit")
		elseif type == "gn" then
			config = requires("Config.Generalnatrual")
		elseif type == "petskill" then
			config = requires("Config.Petskill")
		elseif type == "mission" then
			config = requires("Config.Mission")
		elseif type == "instance" then
			config = requires("Config.Instance")
		elseif type == "npc" then
			config = requires("Config.Npc")
		elseif type == "SkillExperience" then
			config = requires("Config.SkillExperience")
		elseif type == "StoneExperience" then
			config = requires("Config.StoneExperience")
		elseif type == "StoneVariety" then
			config = requires("Config.StoneVariety")
		elseif type == "LevelBriefIntroduction" then
			config = requires("Config.LevelBriefIntroduction")
		elseif type == "HeroExperience" then
			config = requires("Config.HeroExperience")
		elseif type == "LevelUpExperience" then
			config = requires("Config.LevelUpExperience")
		elseif type == "petlvexp" then
			config = requires("Config.petlvexp")
		elseif type == "transmission" then
			config = requires("Config.TransmissionConfig")
		elseif type == "natural" then
			config = requires("Config.CombinationAttributes")
		elseif type == "help" then
			config = requires("Config.help")
		elseif type == "generallead" then
			config = requires("Config.generallead")
		elseif type == "generalstageconfig" then
			config = requires("Config.generalstageconfig")
		elseif type == "user" then
			config = requires("Config.User")
		end

		ConfigData[type] = config
	else
		if type == "skill" or type == "generalskill" then
			if cid>10000 then
				cid = math.floor(cid/100)
			end
		end
	end
	--反回对应的配置文件
	if type and not cid then
		return config
	end
	
	if config[cid..""] then
		if other then
			return config[cid..""][key..""][other]
		elseif key then
			if type == "petskill" then
				return config[cid..""][key..""]
--				return config[cid..""]["1"][key..""]--这个是早之前的config取值方式 ，如果后边有报错，看一下这里，顺便把报错的改成上边的形式
			else
				return config[cid..""][key..""]
			end
		else
			return config[cid..""]
		end
	else
--		echo("配置文件未找到，请检查cid是否有误")
	end
end



--自定义table遍历的顺序，原理，将原table的索引取出，按自定义顺序存在数组中，然后按照顺序取即可
function tableIterator(t,sortRule)
	local index = {}								
	for key in pairs(t) do
		index[#index + 1] = key
	end		
	table.sort(index,sortRule) 
	local i = 0
	return function()		
		i = i + 1 
		return index[i], t[index[i]]  
	end
end

function getSortList(t, sortRule)
	local index = {}								
	for key in pairs(t) do
		index[#index + 1] = key
	end		
	table.sort(index,sortRule) 
	return index
end

--时间转换  
 function timeConvert( value , key )
	local hour,min,sec
	hour = math.floor(value / 3600)
	if hour >= 1 then
		min = math.floor((value - hour * 3600) / 60)
	else
		min = math.floor(value / 60)
	end
	sec = math.floor(value % 60 )
	
	hour = hour<10 and "0"..hour or hour 
	min = min<10 and "0"..min or min 
	sec = sec<10 and "0"..sec or sec
	
	if key == "hour" then
		return hour
	end
	if key == "min" then
		return min
	end
	if key == "sec" then
		return sec
	end
	
	return hour .. "：" .. min .. "：" .. sec
end

-- 获取美术字
function getImageNum( num , imagePath , params )
	if type(params) ~= "table" then params = {} end
	local decimals = params.decimals and true or false
	
	if not decimals then
		num = math.round( num )
	end
	num = num < 0 and 0 or num
	
	local image_path = imagePath
	local frames = display.newFramesWithImage( image_path , decimals and 11 or 10 )

	local count_str = tostring( num )
	local len = string.len( count_str )

	local sprite = display.newSpriteWithFrame( frames[1] )

	local skewing =  params.offset or 0
	local offset = 0
	local height = sprite:getContentSize().height
	
	local width = sprite:getContentSize().width

	local render = cc.RenderTexture:create(width * len , sprite:getContentSize().height)

	render:begin() -- must be called after scene replacing finished, or would crush
	for i = 1 , len do
		local label = ( string.sub( count_str , i , i ) == "." ) and 10 or ( string.sub( count_str , i , i ) )
		local sprite = display.newSpriteWithFrame( frames[label + 1])
		display.align(sprite, display.LEFT_BOTTOM , offset , 0)
		offset = offset + (width or sprite:getContentSize().width) + skewing
		sprite:visit()
	end
	render:endToLua()

	local final_sprite = CCSprite:createWithTexture( render:getSprite():getTexture() )
	final_sprite:setFlippedY(true)

	return final_sprite , offset , height
end
-- 获取CID对应的类型
function getCidType( _cid )
	return DATA_IDTYPE:getType( _cid )
end

-- 获取图片地址
function getImageByType(cid , size , onlyName)
	if size == nil then size = "s" end
	local specialElement = {
		gold		= IMG_PATH .. "image/prop/" .. cid .. ".png" ,		--黄金
		silver		= IMG_PATH .. "image/prop/" .. cid .. ".png" , 		--银两
		task_power	= IMG_PATH .. "image/prop/s_power.png" , 			--体力
		power	= IMG_PATH .. "image/prop/s_power.png" , 				--体力
		task_tribute= IMG_PATH .. "image/common/tribute.png" , 			--帮威
		task_exp	= IMG_PATH .. "image/common/tribute.png" , 			--帮贡
		soul1		= IMG_PATH .. "image/scene/forge/general_icon_1.png" , 			--一星英雄将魂
		soul2		= IMG_PATH .. "image/scene/forge/general_icon_2.png" , 			--二星英雄将魂
		soul3		= IMG_PATH .. "image/scene/forge/general_icon_3.png" , 			--三星英雄将魂
		soul4		= IMG_PATH .. "image/scene/forge/general_icon_4.png" , 			--四星英雄将魂
		chip1		= IMG_PATH .. "image/scene/forge/equip_icon_1.png" , 			--一星装备碎片
		chip2		= IMG_PATH .. "image/scene/forge/equip_icon_2.png" , 			--二星装备碎片
		chip3		= IMG_PATH .. "image/scene/forge/equip_icon_3.png" , 			--三星装备碎片
		chip4		= IMG_PATH .. "image/scene/forge/equip_icon_4.png" , 			--四星装备碎片
		animal1		= IMG_PATH .. "image/scene/forge/pet_icon_1.png" , 				--一星兽魂
		animal2		= IMG_PATH .. "image/scene/forge/pet_icon_2.png" , 				--二星兽魂
		animal3		= IMG_PATH .. "image/scene/forge/pet_icon_3.png" , 				--三星兽魂
		animal4		= IMG_PATH .. "image/scene/forge/pet_icon_4.png" , 				--四星兽魂
	}
	
	if specialElement[cid.. ""] then
		return specialElement[cid.. ""]
	end
	
	if cid == "体力" then
		return IMG_PATH .. "image/prop/s_power.png"
	end
	
	if cid == "扫荡令" then
		return IMG_PATH .. "image/prop/s_16016.png"
	end
	
	local type = getCidType(cid)
	local dir = type
	local prefix = size .. "_"
	local img_id = cid

	if type == "prop" then
		if size == "b" or size == "m" then
			prefix = "b_"
		else
			prefix = "s_"
		end
	elseif type == "general" or type == "hero" then
		dir = "hero"
		img_id = getConfig("general" , cid , "logo_id")
		if size == "b" then
			prefix = "b_general"
		elseif size == "m" then
			prefix = "general"
		else
			prefix = "s_general"
		end
	elseif type == "npc" then
		dir = "hero"
		img_id = getConfig("npc" , cid , "logo_id")
		if size == "b" then
			if img_id < 18000 then
				prefix = "b_general"		--boss npc有大图，
			else
				prefix = "general"		--npc没有大图，
			end
		elseif size == "m" then
			prefix = "general"
		else
			prefix = "s_general"
		end
	elseif type == "skill" then
		dir = "skill"
		if size == "b" or size == "m" then
			prefix = ""
		else
			prefix = ""
		end
		if tonumber(cid)>10000 then
			img_id = math.floor(tonumber(cid)/100)
		end
	elseif type == "equip" then
		if size == "b" or size == "m" then
			prefix = "b_"
		else
			prefix = ""
		end
	end

	if onlyName then
		return prefix .. img_id .. ".png"
	end

	return IMG_PATH .. "image/" .. dir .. "/" .. prefix .. img_id .. ".png"
end


--[[功能对应等级开放]]
function checkOpened(type)
	local Config_Open = requires( "Config.Open")
	local cur = DATA_Guide:get()
	
	if not isset(Config_Open , type) then return true end

	local config = Config_Open[type]
	if cur["map_id"] > config[1] or (cur["map_id"] == config[1] and cur["mission_id"] >= config[2]) then
		return true
	else
		return "需要玩家您打过关卡" .. config[1] .. "-" .. config[2] .. "才能开启"
	end
end

--[[获取引导提示信息]]
function getGuideInfo()
	local Config_Open = requires( "Config.Open")
	local cur = DATA_Guide:get()
	local old = DATA_Guide:getOld()

	-- 关卡无变化
	if cur["map_id"] == old["map_id"] and cur["mission_id"] == old["mission_id"] then
		return false
	end

	local id = cur["map_id"] .. "-" .. cur["mission_id"]
	if not isset(Config_Open , id) then return false end

	return Config_Open[id]
end

--根据传递进来的动作创建一个队列
function getSequenceAction(...)
	local arg = {...}
	-- local action = CCArray:create()
	-- for k, v in pairs(arg) do
	-- 	action:addObject(v)	
	-- end
	-- return CCSequence:create(action)
	return transition.sequence(arg)
end

--同时
-- function getSpawnAction(...)
-- 	local arg = {...}
-- 	local action = CCArray:create()
-- 	for k, v in pairs(arg) do
-- 		action:addObject(v)	
-- 	end
-- 	return CCSpawn:create(action)
-- end

function getTitle()
	return  {
		{10,"无"},
		{9,"小有名气"},
		{8,"青云直上"},
		{7,"锋芒毕露"},
		{6,"风华正茂"},
		{5,"声名鹊起"},
		{4,"名声显赫"},
		{3,"中流砥柱"},
		{2,"风云人物"},
		{1,"威震九州"},
		{0,"盖世英雄"},
	}
end

--背包是否已超出上限
function isBagFull(callback, items)
	local full
	local max = 100
	local tab = {
		general = "英雄",
		equip = "装备",
		pet = "幻兽",
		skill = "技能",
		prop = "道具",
	}

	for type, name in pairs(tab) do
		local list = DATA_Bag:get(type)
		
		if table.nums(list or {}) + (table.nums(items or {}) ) >= max  then
			local KNMask = requires("Common.KNMask")
			local KNBtn = requires("Common.KNBtn")
			
			full = true
			local layer = display.newLayer()
			local mask 
			
			local bg = display.newSprite(COMMONPATH.."tip_bg.png")
			setAnchPos(bg, 240, 425, 0.5, 0.5)
			
			layer:addChild(bg)
			
			local str = "您的" .. name .. "背包已满，无法容纳这么丰厚的关卡掉落啦！"
			if type == "general" or type == "equip" or type == "pet" then
				str = str.."\n点击确定按钮跳转到打造功能"
			else
				str = str.."\n点击确定按钮跳进入背包"
			end
			local tip = display.strokeLabel(str, 0, 0, 24, ccc3(0x2c, 0, 0), nil, nil, {
				dimensions_width = bg:getContentSize().width - 30,
				dimensions_height = bg:getContentSize().height
			})
			setAnchPos(tip, 240, 380, 0.5, 0.5)
			layer:addChild(tip)
			
			local cancel = KNBtn:new(COMMONPATH, {"btn_bg.png", "btn_bg_pre.png"}, 300, 350 ,{
				front = COMMONPATH.."cancel.png",
				priority = -151,
				callback = function()
					display.getRunningScene():removeChild(mask:getLayer(), true)
				end
			})
			layer:addChild(cancel:getLayer())
			
			
			local ok = KNBtn:new(COMMONPATH, {"btn_bg.png", "btn_bg_pre.png"}, 100, 350, {
				priority = -151,
				front = COMMONPATH.."ok.png",
				callback = function()
					if callback then
						callback()
					else
						if type == "general" then
							switchScene("forge")
						elseif type == "equip" then
							switchScene("forge")
						elseif type == "pet" then
							switchScene("forge")
						elseif type == "skill" then
							switchScene("bag")
						elseif type == "prop" then
							switchScene("bag")
						end
					end
				end
			})
			layer:addChild(ok:getLayer())
			
			mask = KNMask:new({item = layer, priority = -150})
			display.getRunningScene():addChild(mask:getLayer())
			break
		end
	end
	return full
end

--获取配置文件中的信息
function getConfigTable(kind, filter)
	local info
	local result = {}	
	if kind == "general" or kind == "hero" then
		info = requires("Config.Hero")
		for k, v in pairs(info) do
			if not filter then
				if v["hidden"] == 0 then --不是怪物
					result[k] = v
				end
			elseif type(filter) == "table" then
				local legal = true
				for sk, sv in pairs(filter) do
					if v[sk] ~= sv then
						legal = false
						break
					end
				end
				if legal and v["hidden"] == 0 then
					result[k] = v	
				end
			end
		end
	elseif kind == "equip" then
		info = requires("Config.Equipment")
		for k, v in pairs(info) do
			if not filter then
				result[k] = v
			elseif type(filter) == "table" then
				local legal = true
				for sk, sv in pairs(filter) do
					if v[sk] ~= sv then
						legal = false
						break
					end
				end
				if legal then
					result[k] = v	
				end
			end
		end
	end
	return result
end

--黄金不足提示
function countGold( _needGoldNum )
	_needGoldNum = tonumber(_needGoldNum)
	local my_gold = tonumber( DATA_User:get("gold") )
	if _needGoldNum > my_gold then
		KNMsg.getInstance():boxShow( "您当前的黄金数量不够，交易失败。\n请及时充值。" ,{ 
																			priority = -9999,
																			confirmText = COMMONPATH .. "chongzhi.png" , 
																			confirmFun = function() switchScene("pay") end , 
																			cancelFun = function() end 
																			} )
		--KNMsg.getInstance():flashShow("您当前的黄金数量不够")
		return false
	end
	return true
end

--判断附加属性是否激活
function checkActive(kind, params)
	local active
	local p = params or {}
	if kind == "general" or kind == "hero" then
		local nType = getConfig("natural", p.nid, "type")
		local need = getConfig("natural", p.nid, "condition")
		
		if not need then
			return false
		end
		
		if nType == 1 then   --齐上阵的
			local check = true
			for k, v in pairs(need) do
				local on = DATA_Formation:checkOnByCid(tonumber(v))
				if not on  then
					check = false
					break
				end
			end
			active = check
		else                 --装备穿戴
			local check = false
			for k, v in pairs(need) do
				if DATA_Formation:isDress(p.id, v) then
					check = true
					break
				end
			end
			active = check
		end
	elseif kind == "equip" then  --装备的附加属性是否被激活
		local heroId = DATA_Formation:checkEquip(tonumber(p.id))--DATA_ROLE_SKILL_EQUIP:getRoleId(tonumber(p.id), "equip")
		local needStar = getConfig("equip", p.cid, "apstar")
		local needRole = getConfig("equip", p.cid, "apstype")
		local heroCid = DATA_Bag:get("general", heroId, "cid")
		
		if getConfig("general", heroCid, "star") == needStar and
			getConfig("general", heroCid, "role") == needRole then
				active = true
		end
	end
	return active
end

--文字换行处理
function createLabel( params )
	params = params or {}
	local str = params.str or ""
	local total_width = params.width or 100		-- 文字总宽度
	local color = params.color or ccc3( 0x2c , 0x00 , 0x00 )
	local size = params.size or 20
	local x = params.x or 0
	local y = params.y or 0
	local line = 1														-- 行数
	-- 估算一行的字符数量
	local enter_num = string.len(str) - string.len(string.gsub(str , "\n" , ""))
	local label = CCLabelTTF:create(str , FONT , size )
	local label_size = label:getContentSize()
	local line_height = label_size.height

	if enter_num > 0 then
		line_height = CCLabelTTF:create("测" , FONT , size ):getContentSize().height
	end

	if label_size.width > total_width then			-- 大于一行
		line = math.ceil( label_size.width / total_width )
	end

	line = line + enter_num

	if line > 1 then
		label:setDimensions(total_width , line * line_height)
	end

	label:setColor( color )
	label:setHorizontalAlignment( 0 )			-- 文字左对齐
	setAnchPos(label , x , y )
	
	return label, line
end
function formatMsg(str , replace)
	if not str then return "" end

	if type(replace) == "table" and table.nums(replace) > 0 then
		local nums = 0

		str = string.gsub(str , "#s#" , function()
			nums = nums + 1
			if replace[nums] ~= nil then
				local replace_type = type(replace[nums])
				if replace_type == "string" or replace_type == "number" then
					return replace[nums]
				else
					return ""
				end
			end

			return ""
		end)
	end

	local return_str = ""
	while true do
		local start_pos , end_pos , color = string.find(str , "%[color=(#[a-f0-9]+)%]")
		if start_pos == nil then break end
		local start_pos_2 , end_pos_2 = string.find(str , "%[/color%]" , end_pos)
		if start_pos_2 == nil then break end
		local first_str = string.sub(str , 0 , start_pos - 1)
		local second_str = string.sub(str , end_pos + 1 , start_pos_2 - 1)

		return_str = return_str .. first_str .. second_str
		str = string.sub(str , end_pos_2 + 1)
	end


	return return_str .. str
end