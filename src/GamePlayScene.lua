-- xlchen@nimostudi.cn-20150907
require("systemConst")


local scene

local size = cc.Director:getInstance():getWinSize()
local frameCache = cc.SpriteFrameCache:getInstance()
local scheduler = cc.Director:getInstance():getScheduler()

-- 平台初始长度 及平台初始间的距离
local platform1Width = 200
local platform2Width = 350

local platformMinWidth = 200
local platformMaxWidth = 400

local platform3Width

local distance = 500
local distance2

-- 平台高度 以及草丛高度
local platformHeight = 600
local bushHeight = 400

-- 物品
local background_sprite
local background_sprite2
local background_sprite3

local platform1
local platform2
local platform3

local platform1_size
local platform2_size
local platform3_size

local bush
local bush_size

local man

local stick
local stick_size

local pause_menu

local scoreLabel

local moveForward_sprite

local schedulerId = nil
local stickLen = 0
local score = 0

local canTouchFlag = true
local beganFlag = false

-- 游戏是否可以继续下去
local status 


local GamePlayScene = class("GamePlayScene", function()
	return cc.Scene:create()
end)

function GamePlayScene:create()
	scene = GamePlayScene:new()
	scene:addChild(scene:createLayer(), 1, 1)
	return scene
end

function GamePlayScene:ctor()
  --初始化参数
  platform1Width = 200
  platform2Width = 350

  platformMinWidth = 200
  platformMaxWidth = 400
  distance = 500

  platformHeight = 600
  bushHeight = 400

  schedulerId = nil
  stickLen = 0
  score = 0

  canTouchFlag = true
  beganFlag = false
end

function GamePlayScene:createLayer()
	local layer = cc.Layer:create()
  layer:setName("mainLayer")

	--背景1,2,3
	background_sprite = cc.Sprite:create("ipadhd/changbeijing.png")
  background_sprite:setAnchorPoint(ccp(0,0))
  layer:addChild(background_sprite)
	local bg_size = background_sprite:getContentSize()
  background_sprite:setPosition(ccp(0, 0))
	background_sprite:setScale(size.width / bg_size.width, size.height / bg_size.height)

  background_sprite2 = cc.Sprite:create("ipadhd/changbeijing.png")
  background_sprite2:setAnchorPoint(ccp(0,0))
  layer:addChild(background_sprite2)
  local bg_size2 = background_sprite2:getContentSize()
  background_sprite2:setPosition(ccp(size.width , 0))
	background_sprite2:setScale(size.width / bg_size2.width, size.height / bg_size2.height)

	background_sprite3 = cc.Sprite:create("ipadhd/changbeijing.png")
  background_sprite3:setAnchorPoint(ccp(0,0))
  layer:addChild(background_sprite3)
  local bg_size3 = background_sprite3:getContentSize()
  background_sprite3:setPosition(ccp(2 * size.width , 0))
	background_sprite3:setScale(size.width / bg_size3.width, size.height / bg_size3.height)

  --平台1
  platform1 = cc.Sprite:create("ipadhd/zhaugnzi2.png")

  -- platform1:setContentSize(platform1Width, platformHeight)
  platform1_size = platform1:getContentSize()
  platform1:setScale(platform1Width / platform1_size.width
    , platformHeight / platform1_size.height)

  platform1:setAnchorPoint(ccp(0,0))
  platform1:setPosition(ccp(0,0))

  layer:addChild(platform1, 1)    
  --平台2

  platform2 = cc.Sprite:create("ipadhd/zhaugnzi2.png")

  platform2_size = platform2:getContentSize()
  platform2:setScale(platform2Width / platform2_size.width
    , platformHeight / platform2_size.height)
  platform2:setAnchorPoint(ccp(0,0))
  platform2:setPosition(ccp(platform1Width + distance,0))

  layer:addChild(platform2, 1)

  --平台3

  platform3 = cc.Sprite:create("ipadhd/zhaugnzi2.png")

  platform3Width = self:widthRandomWithRange(platformMinWidth, platformMaxWidth)
  distance2 = self:distanceRandomWithRange(size.width - platform1Width - distance - platform2Width + 100,
    size.width - platform1Width  - platform3Width - 100)

  platform3_size = platform3:getContentSize()
  platform3:setScale(platform3Width / platform3_size.width
    , platformHeight / platform3_size.height)
  platform3:setAnchorPoint(ccp(0,0))

  platform3:setPosition(ccp(platform1Width + distance + platform2Width + distance2,0))

  layer:addChild(platform3, 1)

  --草丛
  bush = cc.Sprite:create("ipadhd/yezi2.png")
  bush_size = bush:getContentSize()

  bush:setScale(size.width / bush_size.width, bushHeight / bush_size.height)
  bush:setAnchorPoint(ccp(0,0))
  bush:setPosition(0,0)

  layer:add(bush, 2)

  --人物
  man = cc.Sprite:create("ipadhd/ti_0004.png")
  man:setAnchorPoint(ccp(1,0))
  man:setPosition(ccp(platform1Width, platformHeight))

  layer:addChild(man, 1)   

  --棍子
  stick = cc.Sprite:create("ipadhd/qiao.png")
  stick:setAnchorPoint(ccp(0,0))
  stick_size = stick:getContentSize()
  stick:setScale(1, 0)
  stick:setPosition(platform1Width, platformHeight)
  layer:addChild(stick, 1)

  --分数框
  local scoreBox = cc.Sprite:create("ipadhd/ty_fen.png")
  scoreBox:setPosition(ccp(size.width/2, size.height - 400))
  layer:addChild(scoreBox, 1)

  local scoreBox_size = scoreBox:getContentSize()

  --”分“label
  local fenLabel = cc.Sprite:create("ipadhd/phb_fen_cn.png")
  fenLabel:setPosition(scoreBox_size.width * 3/4, scoreBox_size.height/2)
  scoreBox:addChild(fenLabel, 1)

  --分数 Label
  scoreLabel = cc.Label:createWithTTF(score, 'Marker Felt.ttf', 128)
  scoreLabel:setPosition(scoreBox_size.width / 2,  scoreBox_size.height/2)
  scoreLabel:setTextColor(ccc4(0, 0, 0, 255))
  
  scoreBox:addChild(scoreLabel, 1)
  
  --暂停按钮
  function pauseMenuCallBack(tag, sender)
  	cclog("pauseMenuCallBack tag = %s", tag)
    self:pause()
	end

  local pause_btn_normal = ccui.Scale9Sprite:create("ipadhd/ty_zanting.png")
  local pause_btn_selected = ccui.Scale9Sprite:create("ipadhd/ty_zanting_sel.png")

  local pause_menu_item = cc.MenuItemSprite:create(pause_btn_normal, pause_btn_selected)
  pause_menu_item:registerScriptTapHandler(pauseMenuCallBack)

 	pause_menu = cc.Menu:create(pause_menu_item)
 	pause_menu:setPosition(ccp(size.width - 200, size.height - 400))

 	layer:addChild(pause_menu, 1)

  --前进按钮

  moveForward_sprite = cc.Sprite:create("ipadhd/ty_go_cn.png")
  moveForward_sprite:setPosition(ccp(size.width/2, 300))

  layer:addChild(moveForward_sprite, 3)
 	
  -- 监听 	
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(handler(self, self.touchbegin), cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(handler(self, self.touchend), cc.Handler.EVENT_TOUCH_ENDED)

  local eventDispatcher = self:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, moveForward_sprite)

	return layer
end

-- 按下前进键
function GamePlayScene:touchbegin(touch,event)
  local touchLocation = touch:getLocation()

  local nodePos = moveForward_sprite:convertToNodeSpace(touchLocation)
  local moveForward_sprite_size = moveForward_sprite:getContentSize()

  local flag = (nodePos.x > 0) and (nodePos.x < moveForward_sprite_size.width) and
    (nodePos.y > 0) and (nodePos.y < moveForward_sprite_size.height)

  if not flag then
    return
  end

  if not canTouchFlag then
    return
  end

  canTouchFlag = false
  beganFlag = true

  moveForward_sprite:setTexture("ipadhd/ty_go_sel_cn.png")
  cclog("touchbegin")
  --棍子增长
  local function addStickLen(difficulty)
    stickLen = stickLen + 10
    stick:setScaleY(stickLen / stick:getContentSize().height)

    if stickLen + platform1Width >= size.width then
      stickLen = 0
      stick:setScaleY(stickLen / stick:getContentSize().width)
    end
  end

  --人上下跳动
  self:manDanceAnimate()
  --开始调度增长程序
  schedulerId = scheduler:scheduleScriptFunc(addStickLen, 0.01, false)
  return true
end

--松开前进键
function GamePlayScene:touchend(touch, event)
  if not beganFlag then
    return
  end

  beganFlag = false
   
  moveForward_sprite:setTexture("ipadhd/ty_go_cn.png")
  cclog("touchend")
  -- 结束调度程序
  if nil ~= schedulerId then
    scheduler:unscheduleScriptEntry(schedulerId)
  end
  -- 结束运动
  man:stopAllActions()
  -- 步1
  self:man_kick_stick_down()
  self:stick_move_down()

end


-- 初始化棍子
function GamePlayScene:init_stick()
  local stick_size = stick:getContentSize()
  stick:setPosition(ccp(platform1Width, platformHeight))
  stick:setRotation(0)
  stick:setScaleY(0)
  stickLen = 0
end

--根据参数随机生成平台的宽度
function GamePlayScene:widthRandomWithRange(min, max, tag)
  math.randomseed(os.time())
  local width = min + math.random(max - min)
  return width
end

 --根据参数随机生成平台之间的距离
function GamePlayScene:distanceRandomWithRange(min, max, tag)
  math.randomseed(os.time())
  local dis = min + math.random(max - min)
  return dis
end

--人物做出跳动的动画
function GamePlayScene:manDanceAnimate()
  local animation = cc.Animation:create()
  for i = 1,2 do
    local frameName = string.format("ipadhd/daiji_000%d.png", i)
    animation:addSpriteFrameWithFile(frameName)
  end
  animation:setDelayPerUnit(0.1)
  local action = cc.Animate:create(animation)
  man:runAction(cc.RepeatForever:create(action))
end

-- 人物做出踢到棍子的动作 step 1
function GamePlayScene:man_kick_stick_down()
  local animation = cc.Animation:create()
  for i = 1,4 do
    local frameName = string.format("ipadhd/ti_000%d.png", i)
    animation:addSpriteFrameWithFile(frameName)
  end
  animation:setDelayPerUnit(0.1)
  local action = cc.Animate:create(animation)
  local actionCallBack = cc.CallFunc:create(function() self:man_move_to_stick() end)
  man:runAction(cc.Sequence:create(action, actionCallBack))
end

-- 棍子倒下的动作 step 1
function GamePlayScene:stick_move_down()
  local action = cc.RotateBy:create(0.4, 90)
  local actionCallBack = cc.CallFunc:create(function() self:background_move_left() end)
  stick:runAction(cc.Sequence:create(action, actionCallBack))
end

-- 背景向左移动 step 2
function GamePlayScene:background_move_left()
  self:judgeScore()
  
  local actionCallBack = cc.CallFunc:create(function() self:background_move_in_position() end)
  background_sprite:runAction(cc.Sequence:create(cc.MoveBy:create(stickLen / 500, ccp(-stickLen,0)),
    cc.DelayTime:create(0.2), actionCallBack))
  background_sprite2:runAction(cc.MoveBy:create(stickLen / 500, ccp(-stickLen,0)))
  background_sprite3:runAction(cc.MoveBy:create(stickLen / 500, ccp(-stickLen,0)))


end

--背景移动到位
function GamePlayScene:background_move_in_position()
    -- 如果背景 已都在左侧
  if background_sprite:getPositionX() < - size.width then
    background_sprite:setPositionX(background_sprite:getPositionX() + 3 * size.width)
  elseif background_sprite2:getPositionX() < - size.width then
    background_sprite2:setPositionX(background_sprite2:getPositionX() + 3 * size.width)
  elseif background_sprite3:getPositionX() < - size.width then
    background_sprite3:setPositionX(background_sprite3:getPositionX() + 3 * size.width)

  end
end

-- 人移动到棍子的顶点处
function GamePlayScene:man_move_to_stick()
  local action = cc.MoveBy:create((stickLen)/ 500, ccp(stickLen, 0))
  -- 做出行走的动画
  local animation = cc.Animation:create()
  for i = 1,4 do
    local frameName = string.format("ipadhd/zou_000%d.png", i)
    animation:addSpriteFrameWithFile(frameName)
  end
  animation:setDelayPerUnit(0.1)
  local action_animation = cc.Animate:create(animation)
  man:runAction(cc.RepeatForever:create(action_animation))
  local actionCallBack = cc.CallFunc:create(function() self:judgeGameOver() end)
  man:runAction(cc.Sequence:create(action, actionCallBack))

end

    
-- platform 移动
function GamePlayScene:movePlatform()
  local needToMove = - distance - platform2Width
  local actionCallBack = cc.CallFunc:create(function() self:exchangePlatform() end)
  platform1:runAction(cc.Sequence:create(cc.MoveBy:create(0.5, ccp(needToMove, 0)), 
    cc.DelayTime:create(0.2) ,actionCallBack))
  stick:runAction(cc.MoveBy:create(0.5, ccp(needToMove, 0)))
  platform2:runAction(cc.MoveBy:create(0.5,ccp(needToMove, 0)))

  platform3:runAction(cc.MoveBy:create(0.5, ccp(needToMove, 0)))
  -- 人移到相应位置
  man:runAction(cc.MoveTo:create(0.5, ccp(platform1Width, platformHeight)))

end

-- platform 交换参数 stick 初始化
function GamePlayScene:exchangePlatform()
  --交换平台
  local platformTmp = platform1
  platform1 = platform2
  platform2 = platform3
  platform3 = platformTmp
  platform2Width = platform3Width
  distance = distance2

  platform3Width = self:widthRandomWithRange(platformMinWidth, platformMaxWidth)
  distance2 = self:distanceRandomWithRange(size.width - platform1Width - distance - platform2Width + 100,
    size.width - platform1Width  - platform3Width - 100)

  platform3:setScale(platform3Width / platform3_size.width
    , platformHeight / platform3_size.height)
  platform3:setPosition(ccp(platform1Width + distance + platform2Width + distance2,0))

  --初始化棍子
  self:init_stick()
  --按键可以触发
  canTouchFlag = true
end

--游戏结束
function GamePlayScene:gameOver()
  cclog("game over")
  --人物从棍子上掉下
  man:setTexture("ipadhd/diaoluo.png")
  local actionCallBack = cc.CallFunc:create(function() self:displayGameOverScene() end)
  --先走manX/2的距离 再掉下去
  local manX = man:getContentSize().width
  man:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, ccp(manX/2, 0))
    ,cc.MoveBy:create(0.4, ccp(0, - platformHeight)), actionCallBack))

end

--结束界面显示
function GamePlayScene:displayGameOverScene()
  local layer = cc.Layer:create()
  -- 结果框
  local resultBox = cc.Sprite:create("ipadhd/yxjs_dikuang.png")
  local resultBox_size = resultBox:getContentSize()
  
  resultBox:setPosition(size.width/2, size.height/2)
  layer:addChild(resultBox, 1)

  -- 框上彩带
  local streamer = cc.Sprite:create("ipadhd/yxjs_caidai.png")
  streamer:setPosition(resultBox_size.width/2, resultBox_size.height)
  resultBox:addChild(streamer, 1)

  --彩带上文字
  local streamerLabel = cc.Sprite:create("ipadhd/yxjs_yxdf_cn.png")
  streamerLabel:setPosition(streamer:getContentSize().width / 2,
    streamer:getContentSize().height * 3 / 4 - 20)
  streamer:addChild(streamerLabel, 1)

  --”分“label
  local fenLabel = cc.Sprite:create("ipadhd/phb_fen_cn.png")
  fenLabel:setPosition(resultBox_size.width * 3/4, resultBox_size.height/2)
  resultBox:addChild(fenLabel, 1)

  --分数 Label
  local scoreLabel_t = cc.Label:createWithTTF(score, 'Marker Felt.ttf', 256)
  scoreLabel_t:setPosition(resultBox_size.width / 2,  resultBox_size.height/2)
  scoreLabel_t:setTextColor(ccc4(0, 0, 255, 255))
  resultBox:addChild(scoreLabel_t, 1)

  -- 返回按扭
  function backwardMenuCallBack(tag, sender)
    cclog("backwardMenuCallBack tag = %s", tag)
    local loadingscene = require("LoadingScene")
    local backwardscene = loadingscene:create()
    cc.Director:getInstance():replaceScene(backwardscene)
  end

  local backward_normal = ccui.Scale9Sprite:create("ipadhd/yxjs_fanhui_cn.png")
  local backward_selected = ccui.Scale9Sprite:create("ipadhd/yxjs_fanhui_sel_cn.png")

  local backward_menu_item = cc.MenuItemSprite:create(backward_normal, backward_selected)
  backward_menu_item:registerScriptTapHandler(backwardMenuCallBack)

  backward_menu= cc.Menu:create(backward_menu_item)
  backward_menu:setPosition(ccp(size.width/2 - 400, 250))

  layer:addChild(backward_menu, 1)
  -- 炫耀按钮
  function XuanYaoMenuCallBack(tag, sender)
    cclog("XuanYaoMenuCallBack tag = %s", tag)
  end

  local XuanYao_normal = ccui.Scale9Sprite:create("ipadhd/yxjs_xuanyao_cn.png")
  local XuanYao_selected = ccui.Scale9Sprite:create("ipadhd/yxjs_xuanyao_sel_cn.png")

  local XuanYao_menu_item = cc.MenuItemSprite:create(XuanYao_normal, XuanYao_selected)
  XuanYao_menu_item:registerScriptTapHandler(XuanYaoMenuCallBack)

  XuanYao_menu= cc.Menu:create(XuanYao_menu_item)
  XuanYao_menu:setPosition(ccp(size.width/2 , 250))

  layer:addChild(XuanYao_menu, 1)

  -- 重来按钮
  function reGameMenuCallBack(tag, sender)
    cclog("reGameMenuCallBack tag = %s", tag)

    local mainScene = self:create()
    cc.Director:getInstance():replaceScene(mainScene)
  end

  local reGame_normal = ccui.Scale9Sprite:create("ipadhd/yxjs_chonglai_cn.png")
  local reGame_selected = ccui.Scale9Sprite:create("ipadhd/yxjs_chonglai_sel_cn.png")

  local reGame_menu_item = cc.MenuItemSprite:create(reGame_normal, reGame_selected)
  reGame_menu_item:registerScriptTapHandler(reGameMenuCallBack)

  reGame_menu= cc.Menu:create(reGame_menu_item)
  reGame_menu:setPosition(ccp(size.width/2 + 400, 250))

  layer:addChild(reGame_menu, 1)

  -- 在中间层添加一个透明层
  local transparentLayer = cc.LayerColor:create()
  transparentLayer:setOpacity(196)
  scene:addChild(transparentLayer, 2, 3)
  -- 设置事件监听，覆盖底层监听
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
      return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
      return true
  end, cc.Handler.EVENT_TOUCH_ENDED)

  local eventDispatcher = self:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, transparentLayer)

  -- 将layer加入到场景中
  scene:addChild(layer, 3, 2)
end

-- 分数显示效果
function GamePlayScene:scoreDisplayEffect(addscore)
  math.randomseed(os.time())
  local width = size.width / 2 + math.random(800) - 400
  math.randomseed(os.time())
  local height = size.height / 2 + math.random(800) - 400
  if addscore == 100 then
    local shineSprite = cc.Sprite:create("ipadhd/shuzi_light.png")
    shineSprite:setPosition(ccp(width, height))
    shineSprite:setScale(0.5)

    local score_sprite = cc.Sprite:create("ipadhd/shuzi_100.png")
    score_sprite:setPosition(shineSprite:convertToNodeSpace(ccp(width, height)))
    shineSprite:addChild(score_sprite, 1)

    local layer = scene:getChildByTag(1)
    layer:addChild(shineSprite, 2)

    local action = cc.ScaleBy:create(0.5 ,2)
    local actionCallBack = cc.CallFunc:create(function() 
        shineSprite:removeSelf()
      end)
    shineSprite:runAction(cc.Sequence:create(action, actionCallBack))
    
  elseif addscore == 50 then
    local shineSprite = cc.Sprite:create("ipadhd/shuzi_light.png")
    shineSprite:setPosition(ccp(width, height))
    shineSprite:setScale(0.5)

    local score_sprite = cc.Sprite:create("ipadhd/shuzi_50.png")
    score_sprite:setPosition(shineSprite:convertToNodeSpace(ccp(width, height)))
    shineSprite:addChild(score_sprite, 1)

    local layer = scene:getChildByTag(1)
    layer:addChild(shineSprite, 2)
    
    local action = cc.ScaleBy:create(0.5 ,2)
    local actionCallBack = cc.CallFunc:create(function() 
        shineSprite:removeSelf()
      end)
    shineSprite:runAction(cc.Sequence:create(action, actionCallBack))
  elseif addscore == 0 then
  end
end

-- 判断分数
function GamePlayScene:judgeScore()
  local positionX = stickLen + platform1Width
  local min1 = platform1Width + distance
  local max1 = platform1Width + distance + platform2Width
  local min2 = platform1Width + distance + platform2Width/2 - 20
  local max2 = platform1Width + distance + platform2Width/2 + 20
  
  if (positionX > min1) and (positionX <= max1) then
    -- 在中点处（左右距离差 10）
    if (positionX > min2) and (positionX <= max2) then
      score = score + 100
      self:scoreDisplayEffect(100)
    else
      score = score + 50
      self:scoreDisplayEffect(50)
    end
    -- 显示分数
    scoreLabel:setString(score)
    status = true
  else 
    status = false
  end 
end

--暂停
function GamePlayScene:pause()
  local actionManage =  cc.Director:getInstance():getActionManager()
  -- 人，背景，平台，棍子
  actionManage:pauseTarget(man)
  actionManage:pauseTarget(stick)

  actionManage:pauseTarget(background_sprite)
  actionManage:pauseTarget(background_sprite2)
  actionManage:pauseTarget(background_sprite3)

  actionManage:pauseTarget(platform1)
  actionManage:pauseTarget(platform2)
  actionManage:pauseTarget(platform3)

  -- 在中间层添加一个透明层
  local transparentLayer = cc.LayerColor:create()
  transparentLayer:setOpacity(196)
  scene:addChild(transparentLayer, 2, 4)

  -- 设置事件监听，覆盖底层监听
  local listener = cc.EventListenerTouchOneByOne:create()
  listener:setSwallowTouches(true)
  listener:registerScriptHandler(function(touch, event)
      return true
  end, cc.Handler.EVENT_TOUCH_BEGAN)
  listener:registerScriptHandler(function(touch, event)
      return true
  end, cc.Handler.EVENT_TOUCH_ENDED)

  local eventDispatcher = self:getEventDispatcher()
  eventDispatcher:addEventListenerWithSceneGraphPriority(listener, transparentLayer)

  local layer = cc.Layer:create()
  scene:addChild(layer, 3, 5)

  -- 暂停框
  local resultBox = cc.Sprite:create("ipadhd/yxjs_dikuang.png")
  local resultBox_size = resultBox:getContentSize()
  
  resultBox:setPosition(size.width/2, size.height/2)
  layer:addChild(resultBox, 1)  

  -- 暂停中
  local pause_label = cc.Sprite:create("ipadhd/zt_zanting_cn.png")
  pause_label:setPosition(ccp(resultBox_size.width / 2, resultBox_size.height * 3/4))
  resultBox:addChild(pause_label, 1)

  -- 继续按钮
  function continueMenuCallBack(tag, sender)
    cclog("continueMenuCallBack tag = %s", tag)
    self:resume()
    scene:removeChildByTag(4)
    scene:removeChildByTag(5)
  end

  local continue_normal = ccui.Scale9Sprite:create("ipadhd/zt_jixu_cn.png")
  local continue_selected = ccui.Scale9Sprite:create("ipadhd/zt_jixu_sel_cn.png")

  local continue_menu_item = cc.MenuItemSprite:create(continue_normal, continue_selected)
  continue_menu_item:registerScriptTapHandler(continueMenuCallBack)

  local continue_menu = cc.Menu:create(continue_menu_item)
  continue_menu:setPosition(resultBox_size.width/2, 600)

  resultBox:addChild(continue_menu, 1)

  --重新开始按钮
  function restartMenuCallBack(tag, sender)
    cclog("restartMenuCallBack tag = %s", tag)
    local mainScene = self:create()
    cc.Director:getInstance():replaceScene(mainScene)
  end

  local restart_normal = ccui.Scale9Sprite:create("ipadhd/zt_cxks_cn.png")
  local restart_selected = ccui.Scale9Sprite:create("ipadhd/zt_cxks_sel_cn.png")

  local restart_menu_item = cc.MenuItemSprite:create(restart_normal, restart_selected)
  restart_menu_item:registerScriptTapHandler(restartMenuCallBack)

  local restart_menu = cc.Menu:create(restart_menu_item)
  restart_menu:setPosition(resultBox_size.width/2, 400)

  resultBox:addChild(restart_menu, 1)

  --主菜单按钮
  function mainMenuCallBack(tag, sender)
    cclog("mainMenuCallBack tag = %s", tag)
    local loadingscene = require("LoadingScene")
    local backwardscene = loadingscene:create()
    cc.Director:getInstance():replaceScene(backwardscene)
  end

  local main_normal = ccui.Scale9Sprite:create("ipadhd/zt_zhucaidan_cn.png")
  local main_selected = ccui.Scale9Sprite:create("ipadhd/zt_zhucaidan_sel_cn.png")

  local main_menu_item = cc.MenuItemSprite:create(main_normal, main_selected)
  main_menu_item:registerScriptTapHandler(mainMenuCallBack)

  local main_menu = cc.Menu:create(main_menu_item)
  main_menu:setPosition(resultBox_size.width/2, 200)

  resultBox:addChild(main_menu, 1)



end

--恢复
function GamePlayScene:resume()
  local actionManage =  cc.Director:getInstance():getActionManager()
  -- 人，背景，平台，棍子
  actionManage:resumeTarget(man)
  actionManage:resumeTarget(stick)

  actionManage:resumeTarget(background_sprite)
  actionManage:resumeTarget(background_sprite2)
  actionManage:resumeTarget(background_sprite3)

  actionManage:resumeTarget(platform1)
  actionManage:resumeTarget(platform2)
  actionManage:resumeTarget(platform3)
  
end

-- 判断游戏是否完成
function GamePlayScene:judgeGameOver()
  if status == true then
    man:stopAllActions()
    man:setTexture("ipadhd/ti_0004.png")
    self:movePlatform()
  else
  -- 游戏结束
    self:gameOver()
  end
end

return GamePlayScene