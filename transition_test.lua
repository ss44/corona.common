require( "pause-common.transition_pauser" )


local rect = display.newRect( 10, 10, 100, 100 )
local trans = transition.to( rect, { x = display.contentWidth, time = 10000, onComplete = function(event) print ("Done!!") end } )

local state = 1

function tooglePauseResume( event ) 

	if ( state == 1) then
		transition.pause( trans )
		state = 0
	else 
		state = 1
		trans = transition.resume( trans )
	end
end

Runtime:addEventListener( "tap", tooglePauseResume )