local composer = require( "composer" )

local scene = composer.newScene()

local function gotoGame() 
	composer.gotoScene( "game" )
end

local function gotoHighscores()
	composer.gotoScene( "highscores" )
end

function scene:create( event )
	local sceneGroup = self.view

	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "title.png", 500, 80 )
	title.x = display.contentCenterX
	title.y = 200

	local playButton = display.newText( sceneGroup, "Play", display.contentCenterX, 700, native.systemFont, 44)
	playButton:setFillColor( 0.82, 0.86, 1 )
	playButton:addEventListener( "tap", gotoGame)

	local highScoreButton = display.newText( sceneGroup, "Higscores", display.contentCenterX, 810, native.systemFont, 44)
	highScoreButton:setFillColor( 0.75, 0.78, 1 )
	highScoreButton:addEventListener( "tap", gotoHighscores )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
	elseif ( phase == "did" ) then
	end
end

function scene:destroy( event )
	local sceneGroup = self.view
end

scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

return scene
