local json = require( "json" )
local composer = require( "composer" )

local scoresTable = {}

local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local function loadScores()
	local file = io.open( filePath, "r" )
	if ( file ) then
		local content = file:read( "*a" )
		io.close( file )
		scoresTable = json.decode( content )
	end

	if ( nil == scoresTable or 0 == #scoresTable ) then
		scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
end

local function saveScores() 
	for i = #scoresTable, 11, -1 do
		table.remove( scoresTable, i )
	end

	local file = io.open( filePath, "w" )
	if ( file ) then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end

local scene = composer.newScene()

local function gotoMenu()
	composer.gotoScene( "menu", { time=800, effect="crossFade" } )
end

function scene:create( event )
	local sceneGroup = self.view
	loadScores()
	local score = composer.getVariable( "finalScore" )
	if ( score > 0 ) then
		table.insert( scoresTable, score )
	end
	composer.setVariable( "finalScore", 0 )
	local function compare( a, b )
		if ( nil == b ) then
			return false
		elseif ( nil == a ) then
			return false
		end
		return a > b
	end
	table.sort( scoresTable, compare )
	saveScores()

	local background = display.newImageRect( sceneGroup, "background.png", 800, 1400)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local highScoresHeader = display.newText( sceneGroup, "High Scores", display.contentCenterX, 100, native.systemFont, 44 )
	for i = 1, #scoresTable do
		if ( scoresTable[i] ) then
			local yPos = 150 + ( i * 56 )
			local rankNum = display.newText( sceneGroup, i .. ") ", display.contentCenterX, yPos, native.systemFont, 36 )
			rankNum:setFillColor( 0.8 )
			rankNum.anchorX = 1
			local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX, yPos, native.systemFont, 36 )
			thisScore.anchorX = 0
		end
	end
	local menuButton = display.newText( sceneGroup, "Menu", display.contentCenterX, display.contentHeight - 100, native.systemFont, 44 )
	menuButton:setFillColor( 0.75, 0.78, 1 )
	menuButton:addEventListener( "tap", gotoMenu )
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
		composer.removeScene( "highscores" )
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
