local EffectScene = class("EffectScene", function()
    return display.newScene("EffectScene")
end)

local KNBtn = require("Common.KNBtn")
function EffectScene:ctor()
	local sp = display.newSprite("GreenButton.png");
	self:addChild(sp)

	addFrames('',8)

	-- local tt = display.newSprite("#attackagile.03.PNG");
	-- tt:setPosition(200,200)
	-- self:addChild(tt)

	local frames    = display.newFrames("attackagile.%02d.PNG", 1, 8)
    local boom      = display.newSprite(frames[1])

    --local x, y = self.sprite_:getPosition()
    boom:setPosition(200,200)
--    boom:setScale(math.random(100, 120) / 100 * self.boomSpriteScale_)
	--boom:playAnimation(animation)
    
    self:addChild(boom)

    local cancel = KNBtn:new("", {"GreenButton.png", "GreenButton.png"}, 300, 350 ,{
		front = "GreenButton.png",
		priority = -151,
		callback = function()
			--display.getRunningScene():removeChild(mask:getLayer(), true)
			-- print(animation)
			local animation = display.newAnimation(frames, 4 / 8)
			
			boom:playAnimationOnce(animation)
			--boom:playAnimationOnce(animation, "removeWhenFinished")
			self:i7PlaySound("attackagile/agile.caf")

			
		end
	})

   	self:addChild(cancel:getLayer())
end
function EffectScene:i7PlaySound(file)
	--if isSoundAllowed then
		audio.playSound(file)
	--end
end
return EffectScene