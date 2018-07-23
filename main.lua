local physics = require("physics")
physics.start()
physics.setGravity(0, 0)

math.randomseed(os.time())

local sheetOptions = {
  frames = {
    {   -- 1) asteroid 1
        x = 0,
        y = 0,
        width = 102,
        height = 85
    },
    {   -- 2) asteroid 2
        x = 0,
        y = 85,
        width = 90,
        height = 83
    },
    {   -- 3) asteroid 3
        x = 0,
        y = 168,
        width = 100,
        height = 97
    },
    {   -- 4) ship
        x = 0,
        y = 265,
        width = 98,
        height = 79
    },
    {   -- 5) laser
        x = 98,
        y = 265,
        width = 14,
        height = 40
    },
  },
}

local sheetObject = graphics.newImageSheet("gameObjects.png", sheetOptions)

local startLives = 3
local lives = startLives
local score = 0
local nextBonusScore = 100
local died = false

local asteroidsTable = {}

local ship
local gameLoopTimer
local livesText
local scoreText

local backGroup = display.newGroup()
local mainGroup = display.newGroup()
local uiGroup = display.newGroup()

local background = display.newImageRect(backGroup, "background.png", 800, 1400)
background.x = display.contentCenterX
background.y = display.contentCenterY

ship = display.newImageRect(mainGroup, sheetObject, 4, 98, 79)

local function restoreShip()
  ship.isBodyActive = false
  ship.x = display.contentCenterX
  ship.y = display.contentHeight - 100

  transition.to(ship, {
    alpha=1,
    time=1000,
    onComplete = function()
      ship.isBodyActive = true
      died = false
    end,
  })
end

ship.alpha = 0
restoreShip()
physics.addBody(ship, {radius=30, isSensor=true})
ship.myName = "ship"

display.setStatusBar(display.HiddenStatusBar)

function updateText()
  livesText.text = "Lives: " .. lives
  scoreText.text = "Score: " .. score
end

livesText = display.newText(uiGroup, "", 200, 80, native.systemFont, 36)
scoreText = display.newText(uiGroup, "", 400, 80, native.systemFont, 36)

updateText()

local function createAsteroid()
  local newAsteroid = display.newImageRect(mainGroup, sheetObject, 1, 102, 85)
  table.insert(asteroidsTable, newAsteroid)
  physics.addBody(newAsteroid, "dynamic", {radius=40, bounce=0.8})
  newAsteroid.myName = "asteroid"

  local whereFrom = math.random(3)
  if (whereFrom == 1) then
    newAsteroid.x = -60
    newAsteroid.y = math.random(500)
    newAsteroid:setLinearVelocity(math.random(40, 120), math.random(40, 60))
  elseif (whereFrom == 2) then
    newAsteroid.x = math.random(display.contentWidth)
    newAsteroid.y = -60
    newAsteroid:setLinearVelocity(math.random(-40, 40), math.random(40, 120))
  elseif (whereFrom == 3) then
    newAsteroid.x = display.contentWidth + 60
    newAsteroid.y = math.random(500)
    newAsteroid:setLinearVelocity(math.random(-120, -40), math.random(40, 60))
  end

  newAsteroid:applyTorque(math.random(-6, 6))
end

local function fireLaser()
  if (died) then
    return
  end

  local newLaser = display.newImageRect( mainGroup, sheetObject, 5, 14, 40 )
  physics.addBody(newLaser, "dynamic", { isSensor=true })
  newLaser.isBullet = true
  newLaser.myName = "laser"

  newLaser.x = ship.x
  newLaser.y = ship.y
  newLaser:toBack()

  transition.to(newLaser, {y=-40, time=500, onComplete = function() display.remove(newLaser) end})
end

Runtime:addEventListener("tap", fireLaser)

local function dragShip(event)
  if (died) then
    return
  end
  local phase = event.phase
  if ("began" == phase) then
    display.currentStage:setFocus(ship)
    ship.touchOffset = event.x - ship.x
  elseif ("moved" == phase) then
    if (ship.touchOffset == nil) then
      ship.touchOffset = 0
    end
    ship.x = event.x - ship.touchOffset
  elseif ("ended" == phase or "cancelled" == phase) then
    display.currentStage:setFocus(nil)
  end
  return true
end

Runtime:addEventListener("touch", dragShip)

local function gameLoop()
  createAsteroid()
  for i = #asteroidsTable, 1, -1 do
    local thisAsteroid = asteroidsTable[i]
    if (
      thisAsteroid.x < -100 or
      thisAsteroid.x > display.contentWidth + 100 or
      thisAsteroid.y < -100 or
      thisAsteroid.y > display.contentHeight + 100
    ) then
      display.remove(thisAsteroid)
      table.remove(asteroidsTable, i)
    end
  end
end

local function onCollision(event)
  local o1 = event.object1
  local o2 = event.object2

  if ("began" == event.phase) then
    if (
      ("laser" == o1.myName and "asteroid" == o2.myName) or
      ("asteroid" == o1.myName and "laser" == o2.myName)
    ) then
      display.remove(o1)
      display.remove(o2)
      for i = #asteroidsTable, 1, -1 do
        if (asteroidsTable[i] == o1 or asteroidsTable[i] == o2) then
          table.remove(asteroidsTable, i)
        end
      end
      score = score + 10
      if (score >= nextBonusScore) then
        lives = lives + 1
        nextBonusScore = nextBonusScore * 2
      end
      updateText()
    end

    if (
      ("ship" == o1.myName or "ship" == o2.myName) and
      ("asteroid" == o2.myName or "asteroid" == o2.myName) and
      died == false
    ) then
      died = true
      ship:setLinearVelocity(0, 0)
      lives = lives - 1
      ship.alpha = 0

      if (lives > 0) then
        ship.alpha = 0
        timer.performWithDelay(1000, restoreShip)
      else
        lives = startLives
        score = 0
        for i = #asteroidsTable, 1, -1 do
          display.remove(asteroidsTable[i])
        end
        asteroidsTable = {}
        updateText()
        restoreShip()
      end

      updateText()
    end
  end
  return true
end

Runtime:addEventListener("collision", onCollision)

local function keyListener (event)
  if (died) then
    return
  end

  if ("space" == event.keyName) then
    fireLaser()
  elseif ("right" == event.keyName) then
    if ("down" == event.phase) then
      ship:setLinearVelocity(100, 0)
    elseif ("up" == event.phase) then
      ship:setLinearVelocity(0, 0)
    end
  elseif ("left" == event.keyName) then
    if ("down" == event.phase) then
      ship:setLinearVelocity(-100, 0)
    elseif ("up" == event.phase) then
      ship:setLinearVelocity(0, 0)
    end
  end
end

Runtime:addEventListener("key", keyListener)

gameLoopTimer = timer.performWithDelay(500, gameLoop, 0)
