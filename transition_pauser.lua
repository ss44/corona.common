--[[

A basic and quick implementation to add the pausing ability to transitions.
Where many of the other implementations seem to try to and re-write transition all together,
this method simply follows the logic of saving the time between when a transition was started, and when a transition
was supposed to complete to continue on a transition.


]]


-- Make an alias to the original transition methods
local oTo = transition.to 
local oCancel = transition.cancel

-- Need to track all our transition indexes 
local _tManager = {}

local function copyParams( oParams )
	-- track the default params
	local params = {
		time = 500,
	}

	for x,y in pairs( oParams ) do
		params[x] = y
	end

	return params
end

transition.to = function ( obj, params )
	
	-- deal with copying over the default params 
	newParams = copyParams( params )

	local transValue = oTo( obj, params )

	transValue._originalParams = newParams
	table.insert(_tManager, transValue )

	return transValue
end

transition.cancel = function( trans )
	print('entering cancel')
	for x in ipairs( _tManager ) do
		print('looop entering cancel')
		if ( _tManager[x] == trans ) then
			table.remove( _tManager, x )
			return oCancel( trans )
		end
	end



end

transition.pause = function( trans )
	
	if ( trans._timeStop == nil ) then
		trans._timeStop = system.getTimer()
		oCancel( trans )
	end
end


transition.resume = function ( trans )

	for x in ipairs( _tManager ) do
		if ( _tManager[x] == trans ) then
			-- new duration is
			local newDuration = trans._duration
			print('transition resume')
			if ( trans._timeStop ~= nil ) then
				newDuration = trans._duration - (trans._timeStop - trans._timeStart)
			end

			trans._originalParams.time = newDuration
			local newTrans = oTo( trans._target, trans._originalParams )
			
			newTrans._originalParams = trans._originalParams

			-- set the old transition to nil
			oCancel( trans )
			trans = nil
			table.remove( _tManager, x )

			table.insert( _tManager, newTrans )
			return newTrans
		end
	end
end