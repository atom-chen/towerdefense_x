--[[
	时钟
	
	
	使用例子
	local count = 1
	local function testFun()
		dump("执行到这里了" , count) 
		count = count + 1 
		if count>=10 then
			Clock:removeTimeFun("home")
		end
	end
	Clock:addTimeFun("test" , testFun ) 
]]--

Clock = {}
local handle
local funGather = {}

function Clock:new()
	
	local function refreshTime()
		for key , v in pairs(funGather) do
			--这里做一个计时器的异常处理
			xpcall(v, function()
				print("计时器中方法:"..key.."捕获到异常,从计时器删除")
				funGather[key] = nil
			end)	
		end
	end
	
    handle = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( refreshTime , 1 , false )
end

function Clock:addTimeFun( key , _fun )
	key = tostring(key)
--	assert( not funGather[key] , "key: '" .. key .. "' exists")
	
	if not funGather[key] then
		funGather[key] = _fun
	else
		print("当前定时器"..key.."已更新")
		funGather[key] = _fun
	end
end

function Clock:removeTimeFun( key )
	if key == nil then
		funGather={}
		return
	end
	key = tostring(key)
--	assert( funGather[key] , "key: '" .. key .. "' nonentity")
	
	if funGather[key] then
		funGather[key] = nil
	end
end
--key是否存在
function Clock:getKeyIsExist( key )
	key = tostring(key)
	local isExist = false
	if funGather[key] then
		isExist = true
	end
	return isExist
end

function Clock:stop()
	funGather={}
	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(handle)
end
return Clock







