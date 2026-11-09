local loadstring = function(...)
	local res, err = loadstring(...)
	if err then
		error(err)
	end
	return res
end
local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/7GrandDadPGN/RobloxTranslationLayer/'..readfile('tlayer/commit.txt')..'/'..select(1, path:gsub('tlayer/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after tlayer updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local place = 8768229691
if isfile('tlayer/games/'..place..'.lua') then
	return loadstring(readfile('tlayer/games/'..place..'.lua'), 'skywars')(...)
else
	if not shared.VapeDeveloper then
		local success, data = pcall(downloadFile, 'tlayer/games/'..place..'.lua')

		if success and data then
			return loadstring(data, 'skywars')(...)
		end
	end
end