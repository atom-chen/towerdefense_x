--[[

消息框

]]

local KNBtn = requires("Common.KNBtn")

KNMsg = {}

function KNMsg:new()
	local store = nil

	return function(self)
		if store then return store end

		local o = {}
		setmetatable(o , self)
--		self._index=self

		store = o
		store.text = ""
		store.isAction = false    --是否有动画在执行

		local KNMask = requires("Common.KNMask")
		local mask = nil

		--检查及初始化参数
		local function checkData(str , param)
			store.text = str or ""
			
			-- 如果提示文字 为空  则不执行本次提示 
			if(store.text == "") then
				return 0 , param
			end
			-- 动画是否在执行中，如果执行中则不执行新动画 (该判断会导致在提示动画未执行完切换场景后，提示不出现，所以暂时注释掉)
--			if(store.isAction) then
--				return 0 , param
--			end
			-- 初始化动画执行时间
			local time = 1.5
			if args ~= nil then
				time = args.time or 1.5
			end

			return time , param
		end

		-- 创建 对应UI布局
		local function createLayout(type , args)
			args = args or {}
			local content = nil
			local textField = CCLabelTTF:create(store.text , FONT , 20)

			if type == 0 then
				content = display.newSprite(IMG_PATH .. "image/common/prompt_bg.png")
				content:setAnchorPoint( ccp(0 , 0) )
				textField:setColor(ccc3( 0xff , 0xff , 0xff ))
				textField:setAnchorPoint( ccp( 0 , 1 ) )

				if textField:getContentSize().width > 360 then
					textField:setDimensions(360 , 70)

					textField:setPosition( ccp( ( content:getContentSize().width - textField:getContentSize().width ) / 2 , content:getContentSize().height / 1.5 + 3 ) )
				else
					textField:setPosition( ccp( ( content:getContentSize().width - textField:getContentSize().width ) / 2 , content:getContentSize().height / 1.5 - 8 ) )
				end

				content:addChild(textField)

				
				
			else  --带按钮的提示框
				content =  display.newSprite(IMG_PATH .. "image/common/tip_bg.png")

				textField:setDimensions(360 , 124)
				textField:setHorizontalAlignment( isset(args , "align") and args.align or 1 )

				setAnchPos(textField , display.cx - 30 , 110 , 0.5)
				
				
				content:setAnchorPoint( ccp(0 , 0) )

				local cSize = content:getContentSize()

				-- --Wolf：设置存在取消，不存在确定				
				-- local isCancel = true--是否存在 取消 回调
				-- local isConfirm = false--是否存在 确定 回调

				isCancel = isset(args , "cancelFun")
				isConfirm = isset(args , "confirmFun")
				content:retain()
				local function backFun()
					mask:remove()--移除msak
					content:setVisible(false)
					content:removeSelf()	-- 清除自己
					store.isAction = false
				end

				local confirmBtn , cancelBtn = nil
				if isConfirm then
					confirmBtn = KNBtn:new(IMG_PATH .. "image/common/" , {"btn_bg_red.png"} , 0 , 0 , {
						front = args.confirmText or IMG_PATH .. "image/common/confirm.png" ,
						priority = args.priority or  -500,
						scale = true,
						callback = 
						function()
							args.confirmFun()
							backFun()
						end,
					}):getLayer()
					content:addChild(confirmBtn)
				end

				--如果有取消时按钮
				if isCancel then
					cancelBtn = KNBtn:new(IMG_PATH .. "image/common/" , {"btn_bg_red.png"} , 0 , 0 , {
						front = args.cancelText or IMG_PATH .. "image/common/cancel.png",
						scale = true,
						priority = args.priority or  -500,
						callback = function()
							args.cancelFun()
							--args.cancelFun()
							backFun()
						end,
					}):getLayer()
					content:addChild(cancelBtn)
				end

				content.click = function( eventType , x , y )
					local rec
					if isConfirm then
						rec = confirmBtn:onTouch(eventType, x , y)
					end
					if isCancel then
						cancelBtn:onTouch(eventType , x , y)
					end
				end

				--按钮位置计算
				if isConfirm and isCancel then--如果两个按钮同时存在的坐标设置
					--重新设置确定按钮坐标
					setAnchPos(confirmBtn , display.cx - 208 , 35)
					setAnchPos(cancelBtn , display.cx + 5 , 35)
				else
					if isConfirm then--如果只有确认按钮时的坐标
						setAnchPos(confirmBtn , display.cx - 102 , 35)
					elseif isCancel then--如果只有取消按钮时的坐标
						setAnchPos(cancelBtn , display.cx - 102 , 35)
					end
				end


				content:addChild(textField)

				textField:setColor( ccc3(0 , 0 , 0) )
			end

			local tempX = ( display.width - content:getContentSize().width ) / 2
			local tempY = ( display.height + content:getContentSize().height / 2 ) / 2 - content:getContentSize().height + 100
			content:setPosition( ccp( tempX , tempY ) )

			
			return content , textField
		end

		-- 执行动画效果
		local function createAction(target , time , type , args)
			target:setVisible( true )
			local scene = display.getRunningScene()
			if not args then args = {} end
			local showTime = time  -- 动画效果总时间
			local startEfTime = showTime / 5  -- 显示前渐变动画效果时间
			local endEfTime = showTime / 5  -- 消失时渐变动画时间
			local move_y = args.y or 100

			store.isAction = true
			if type == 0 then  -- 无遮罩，展示后消失
			 	scene:addChild(target)

			 	startEfTime = 0.2
			 	endEfTime = 0.2

				-- 渐变显示
				transition.fadeIn(target , {
					time = startEfTime,
				})
---[[
				transition.moveBy(target , {
					y = 20,
					time = startEfTime,
					onComplete = function()
						transition.moveBy(target , {
							delay = showTime,
							y = 20,
							time = endEfTime,
							onComplete = function()
								target:setVisible(false)
								target:removeSelf()	-- 清除自己
								store.isAction = false
							end
						})
					end
				})
--]]
				

				-- 显示动画
				--[[
				transition.moveTo(target , {
					onStart = function() end,
					y = target.y + move_y,
					time = showTime,
					onComplete = function()
						target:setVisible(false)
						target:removeSelf()	-- 清除自己
						store.isAction = false
					end
				})
]]

				-- 消失动画
				transition.fadeOut(target , {
					time = endEfTime,
					delay = showTime + startEfTime,
				})
			elseif type == 1 then  -- 有遮罩，显示后存在于屏幕上，等待操作
				--渐变显示
				mask = KNMask:new({item = target , priority = -500, click=target.click })
				scene:addChild(mask:getLayer())

				transition.fadeIn(target , {
					time = startEfTime,
				})

				-- 显示动画
				transition.moveTo(target , {
					y = target:getPositionY() + move_y,
					time = showTime,
				})
			end
		end

		--单纯文字展示
		function store:textShow(str , args)
			local time , args = checkData(str,args)
			if time == 0 then return end

			local textField = CCLabelTTF:create(store.text , FONT , 15)
			textField:setAnchorPoint( ccp(0 , 1) )
			local tempX = (display.width - textField:getContentSize().width ) / 2
			local tempY = (display.height + textField:getContentSize().height / 2 ) / 2
			textField:setPosition( ccp(tempX , tempY) )
			createAction(textField , time , 0)
		end

		-- 闪现
		function store:flashShow(str , args)
			local time , args = checkData(str , args)
			if time == 0 then return end
			-- 生成显示对像
			local tempContent , textField = createLayout(0)
			-- 设置文字
			textField:setString(store.text)
			-- 判断是否是两行文字
			if string.find(store.text , "\n") then
				textField:setPositionY( textField:getPositionY() + 15 )
			end
			-- 执行动画
			createAction(tempContent , time , 0)
		end


		--有确认 提示框
		function store:boxShow(str , args)
			--[[args={confirmFun=function,和cancelFun=function}
				（1）调用boxShow方法，显示对像在创建时会判断confirmFun和cancelFun是否存，存在则创建，否则不创建
				（2）confifmFun和cancelFun同时存在则创建两个按钮，如果只存在两个中的一个，则创建对应的确定或取消按钮
				（3）按钮的位置自动生成
			]]--
			local time , args = checkData(str , args)
			if time == 0 then return end

			-- time 强制设置成0.2
			time = 0.2

			--生成显示对像
			local tempContent , textField = createLayout( 1 , args )
			--设置文字
			textField:setString(store.text)
			--执行动画
			createAction(tempContent , time , 1 , {y = 50})
		end

		-- 设置文字
		function store:setText(args)
			store.text = args
		end

		-- 返回文字
		function store:getText()
			print(store.text)
		end
		return o
	end
end

KNMsg.getInstance = KNMsg:new()
