
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("src/logger")

require "config"
require "cocos.init"

function cclog(...)
    print(string.format(...))
end

nimologger = require("nimologger")
nimologger:printByTag("DEBUG", "control", "Debug-control")
nimologger:printByTag("ERROR", "remote", "Error-remote")
nimologger:printByTag("FATAL", "tag", "FATAL-tag")
nimologger:printByTag("INFO", "local", "INFO-local")



local function main()
    --require("app.MyApp"):create():run()
    local scene = require("LoadingScene")
    local loadingScene = scene.create()
    if cc.Director:getInstance():getRunningScene() then
    	cc.Director:getInstance():replaceScene(loadingScene)
    else
    	cc.Director:getInstance():runWithScene(loadingScene)
    end
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
