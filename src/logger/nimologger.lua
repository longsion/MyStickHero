-- nimologger
-- xlchen@nimostudio.cn
-- 2015-09-14
local nimologger = {}

-- 构造函数, 默认构造成
function nimologger:new()
	nimologger:setDefaultAppendFunc()
	return nimologger
end

-- 设置append function
function nimologger:setAppendFunc(append)
	require "logging"
	local logging, err = logging:new(append)
	if logging == nil then
		return nil, err
	end
	setmetatable(nimologger, {__index = logging})
	return true
end

-- 设置默认的append function
function nimologger:setDefaultAppendFunc()
	require "logging"
	local logging = logging.new(function(self,level,message)
		print(message)
		return true
		end)
	setmetatable(nimologger, {__index = logging})
	return true
end

-- 设置append为file 
function nimologger:setFileAsAppendFunc(filename, datePattern, logPattern)
	require "logging.file"
	local logging = logging.file(filename, datePattern, logPattern)
	if logging == nil then
		return nil, err
	end
	setmetatable(nimologger, {__index = logging})
	return true
end

-- 设置append为email 
function nimologger:setEmailAsAppendFunc(params)
	require "logging.email"
	local logging = logging.email(params)
	if logging == nil then
		return nil, err
	end
	setmetatable(nimologger, {__index = logging})
	return true
end

-- 设置append为console
function nimologger:setConsoleAsAppendFunc(logPattern)
	require "logging.console"
	local logging = logging.console(logPattern)
	if logging == nil then
		return nil, err
	end
	setmetatable(nimologger, {__index = logging})
	return true
end

-- 设置append为socket
function nimologger:setSocketAsAppendFunc(address, port, logPattern)
	require "looging.socket"
	local logging = logging.socket(address, port, logPattern)
	if logging == nil then
		return nil, err
	end
	setmetatable(nimologger, {__index = logging})
	return true
end

-- 设置append为sql
function nimologger:setSqlAsAppendFunc(params)
	require "logging.sql"
	local logging = logging.sql(params)
	if logging == nil then
		return nil, err
	end
	setmetatable(nimologger, {__index = logging})
	return true
end

-- 添加tag
require "nimologtag"
local fileUtils = cc.FileUtils:getInstance()
local path = fileUtils:getWritablePath()
function nimologger:printByTag(level, tag, msg)
	-- 遍历 nimologtag表
	local status = false
	for k,v in pairs(nimologtagTable) do
		if tag == v then
			status = true
			break
		end
	end
	-- 控制台输出带tag的log
	if status then
		self:setDefaultAppendFunc()
		self:log(level, "[" .. tag .. "]" .. msg)
	end
	-- 文件记录所有log
	local res, err = nimologger:setFileAsAppendFunc(path .. "test%s.log", "%Y-%m-%d")
	if res == nil then
		return nil, err
	end
	self:log(level, "[" .. tag .. "]" .. msg)
	return true
end

return nimologger