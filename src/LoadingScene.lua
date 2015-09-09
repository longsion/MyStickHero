-- xlchen@nimostudio.cn-20150907
require("systemConst")

local size = cc.Director:getInstance():getWinSize()
--local frameCache = cc.SpriteFrameCache:getInstance()
--local textureCache = cc.Director:getInstance():getTextureCache()

local LoadingScene = class("LoadingScene", function()
	return cc.Scene:create()
end)

function LoadingScene.create()
	local scene = LoadingScene.new()
    scene:addChild(scene.createLayer())
	return scene
end

function LoadingScene:ctor()

end

function LoadingScene:createLayer()
	local layer = cc.Layer:create()

	--背景
    local background_sprite = cc.Sprite:create("ipadhd/dl_beijing.png")
    layer:addChild(background_sprite)
	local bg_size = background_sprite:getContentSize()
    background_sprite:setPosition(ccp(size.width / 2, size.height / 2))
	background_sprite:setScale(size.width / bg_size.width, size.height / bg_size.height)
    cclog("size = %d, %d", size.width, size.height)
    cclog("bg_size = %d, %d", bg_size.width, bg_size.height)
    cclog("scale = %f, %f", size.width / bg_size.width, size.height / bg_size.height)

    --棍子英雄label
    local stick_hero_label = cc.Label:createWithTTF("Stick Hero", 'Marker Felt.ttf', 300)
    --stick_hero_label:setTextColor(cc.Color4B(255,0,0,255))
    stick_hero_label:setTextColor(ccc4(0, 0, 0, 255))
    layer:addChild(stick_hero_label, 1)
    stick_hero_label:setPosition(ccp(size.width / 2, size.height / 2 + 600))

    --开始游戏
    function startMenuCallBack(tag, sender)
    	cclog("startBtnCallBack tag = %s", tag)
    	local gamePlayScene = require("GamePlayScene")
    	local scene = gamePlayScene.create()
    	cc.Director:getInstance():replaceScene(scene)
	end

    local start_btn_normal = ccui.Scale9Sprite:create("ipadhd/dl_ksyx_cn.png")
    local start_btn_selected = ccui.Scale9Sprite:create("ipadhd/dl_ksyx_sel_cn.png")
    local start_menu_item = cc.MenuItemSprite:create(start_btn_normal, start_btn_selected)

    start_menu_item:registerScriptTapHandler(startMenuCallBack)
    local start_menu = cc.Menu:create(start_menu_item)
    
    start_menu:setPosition(size.width/2, size.height/2 - 100)
   	layer:addChild(start_menu, 1)

   	--排行榜
   	function chartsMenuCallBack(tag,sender)
   		cclog("chartsMenuCallBack tag = %s", tag)
   	end

   	local charts_btn_normal = ccui.Scale9Sprite:create("ipadhd/dl_phb_cn.png")
    local charts_btn_selected = ccui.Scale9Sprite:create("ipadhd/dl_phb_sel_cn.png")
    local charts_menu_item = cc.MenuItemSprite:create(charts_btn_normal, charts_btn_selected)

    charts_menu_item:registerScriptTapHandler(chartsMenuCallBack)
    local charts_menu = cc.Menu:create(charts_menu_item)

    charts_menu:setPosition(size.width/2, size.height/2 - 400)
    layer:addChild(charts_menu, 1)

    --左下角
    function bottomLeftCallBack(tag, sender)
    	cclog("bottomLeftCallBack tag = %s", tag)
    end
    local bottom_left_btn_normal = ccui.Scale9Sprite:create("ipadhd/tiao_icon.png")
    local bottom_left_btn_selected = ccui.Scale9Sprite:create("ipadhd/tiao_icon.png")
    local bottom_left_item = cc.MenuItemSprite:create(bottom_left_btn_normal, bottom_left_btn_selected)
    -- local bottom_left_item = cc.MenuItemSprite:create()
    -- bottom_left_item:setNormalImage(bottom_left_btn_normal)

    bottom_left_item:registerScriptTapHandler(bottomLeftCallBack)
    local bottom_left = cc.Menu:create(bottom_left_item)

    bottom_left:setPosition(ccp(150, 150))
    layer:addChild(bottom_left, 1)

    --右下角设置
    function settingsCallBack(tag, sender)
    	cclog("settingsCallBack tag = %s", tag)
    end
    local settings_btn_normal = ccui.Scale9Sprite:create("ipadhd/dl_shezhi.png")
    local settings_btn_selected = ccui.Scale9Sprite:create("ipadhd/dl_shezhi_sel.png")
    local settings_item = cc.MenuItemSprite:create(settings_btn_normal, settings_btn_selected)

    settings_item:registerScriptTapHandler(settingsCallBack)
    local settings = cc.Menu:create(settings_item)

    settings:setPosition(ccp(size.width - 150, 150))
    layer:addChild(settings, 1)

    --右上角帮助
    function helpCallBack(tag, sender)
    	cclog("helpCallBack tag = %s", tag)
    end
    local help_btn_normal = ccui.Scale9Sprite:create("ipadhd/xsyd.png")
    local help_btn_selected = ccui.Scale9Sprite:create("ipadhd/xsyd_sel.png")
    local help_item = cc.MenuItemSprite:create(help_btn_normal, help_btn_selected)

    help_item:registerScriptTapHandler(helpCallBack)
    local help = cc.Menu:create(help_item)

    help:setPosition(ccp(size.width - 150, size.height - 150))
    layer:addChild(help, 1)




	
	return layer
end

return LoadingScene