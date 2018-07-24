local composer = require( "composer" )

display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() )

composer.setVariable( "finalScore", 0 )
composer.gotoScene( "menu" )
