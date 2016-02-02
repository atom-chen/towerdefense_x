KNFileManager = {}
local save_path
if INIT_FUNCTION.platform == 0 then 			-- windows
	save_path = ""
elseif INIT_FUNCTION.platform == 1 then 		-- Android
	-- save_path = "/mnt/sdcard/eagle/" .. CHANNEL_ID .. "/"
	save_path = device.writablePath
else --if INIT_FUNCTION.platform == 2 or INIT_FUNCTION.platform == 3 then 		-- IOS
	save_path = device.writablePath
end

function KNFileManager.readfile(filename , key , reg)
	if not io.exists(save_path .. filename) then
		return ""
	end

    local data = io.open(save_path .. filename , "r")
	local back_str = nil
	for line in data:lines() do
		line = string.trim(line)
		local str = string.split(line , reg)
		if str[1] == key then
			back_str = str[2]
		end		
	end
	data:close()
	return back_str
end

function KNFileManager.isExist(filename)
	if io.exists(save_path .. filename) then
		return true
	end
	return false
end

function KNFileManager.updatafile(filename , key , reg , value)
	local connect = ""

	if not io.exists(save_path .. filename) then
		connect = key .. reg .. value .. "\n"
	else
		local data_old = io.open(save_path .. filename , "r")
		local has_set = false
		for line in data_old:lines() do
			line = string.trim(line)
			local str = string.split(line , reg)
			if str[1] == key then
				connect = connect .. str[1] .. reg .. value .. "\n"
				has_set = true
			else
				connect = connect .. line .. "\n"
			end
		end

		if not has_set then
			connect = connect .. key .. reg .. value .. "\n"
		end

		data_old:close()
	end

	-- 写文件	
	local data = io.open(save_path .. filename , "w")
    if data then
        data:write(connect)
        data:close()
    end

	return true
end

