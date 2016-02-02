--[[

切换场景

** Param **
	name 场景名
	temp_data 临时变量，可传递到下一个场景
	callback 回调函数

]]
function switchScene( name , temp_data , callback )
--	local cur_scene = display.getRunningScene()
--	if cur_scene and cur_scene["name"] == name then return end

	-- 去掉所有未完成的动作
	CCDirector:sharedDirector():getActionManager():removeAllActions()
	local curscene = display.getRunningScene()
	if curscene then
		curscene:removeAllChildren()
		display.removeUnusedSpriteFrames()
		-- curscene:removeAllChildrenWithCleanup(true)
		-- CCTextureCache:sharedTextureCache():removeUnusedTextures()
	end
	local scene_file = "Scene." .. name .. ".scene"

	local scene = requires(scene_file)


	-- echoLog("Scene" , "Load Scene [" .. name .. "]")
	display.replaceScene( scene:create(temp_data) )

	if type(callback) == "function" then
		-- 必须延迟，不然会在替换场景之前执行
		local handle
		handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
			handle = nil

			callback()
		end , 0.1 , false)
		
	end
end

function pushScene(name,params)
	--local scene_file = "Scene." .. name .. ".scene"
	--local scene = requires(scene_file)
	local scene_file = "scenes."..name.."Scene"
	local scene =require(scene_file)
	params = params or {}
	params.isPush = true
	--cc.Director:getInstance():pushScene(scene:create(params))
	cc.Director:getInstance():pushScene(scene:new(params))
end

function popScene()
	CCDirector:sharedDirector():popScene()
end

function pushLayer( parent,layer )
	local temp = cc.Layer:create()
	parent:addChild(temp)
	temp:addChild(layer)
end
function addFrames( patten,num)

	local frameCache = cc.SpriteFrameCache:getInstance()
	patten="attackagile/%02d.PNG"
	for i=1,8 do
		local imageUri=string.format(patten,i)
		local texture=cc.Director:getInstance():getTextureCache():addImage(imageUri)
	    local texSize=texture:getContentSize()
	    local texRect = cc.rect(0, 0, texSize.width, texSize.height);
	    local frame=cc.SpriteFrame:createWithTexture(texture,texRect)
	    local name = string.gsub(imageUri,'/','.')
	    print("abc",name)
		cc.SpriteFrameCache:getInstance():addSpriteFrame(frame,name);
	end
end