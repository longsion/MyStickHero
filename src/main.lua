
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

function cclog(...)
    print(string.format(...))
end


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
