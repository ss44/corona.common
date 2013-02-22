--[[
	A simple helper that dispalys a notification to the user to rate an app,
	after they have run an app x number of times. T

	Requirements:
		In config.lua under application include the following with app store urls:
			
		application = {
			...
	
			-- Links to the app store url which this will redirect to.
			appStores = {
				ios = '',
				google = '',
				amazon = ''
			}
			
			-- Show the rating dialog after the app has been run at least:
			 	- runs: x times
				- time: after used for at least xyz seconds
				- days: installed for days
			rateAfter = {
				runs = 10,
				time = 100,
				days = 10
			}
			...
	}
]]
module (..., package.seeall)


local config = require('config')
local device = require('pause-common.device_detect')
local json = require('json')
-- increment the number of times the app has been run
local path = system.pathForFile( "apprate.dat", system.DocumentsDirectory )

local dataModel = {
	timeCount = 0,
	runCount = 0,
	hasAsked = false,
	askLater = false,
	hasRated = false,
	timeFirstRun = nil,
	v = 1
}

local function getData()
	local contents = nil
	local file, err = io.open(path, "r")

	-- read the first line of the app
	if ( err ~= nil ) then
		contents = nil
	else
		contents = file:read('*a')
		io.close( file )
	end

	local data = nil
	if ( contents ~= nil ) then
		data = json.decode( contents )
	end	

	if ( data == nil or data == null or data.v < dataModel.v ) then
		print('new data model')
		data = dataModel
	end

	return data
end

local function writeData( data )
	local file = io.open(path, 'w')
	file:write( json.encode( data ) )
	file:close()
	print( data.timeCount )
end

local data = getData()

-- if it's an int > 0 then increment + 1 and store counter
if ( data.runCount ~= nil and data.runCount >= 0 ) then
	data.runCount = data.runCount + 1
else
	-- otherwise delete all contents of file and set to 0.
	data.runCount = 1
end

if ( data.runCount == 1 or data.timeFirstRun == nil ) then
	data.timeFirstRun = os.time()
end

writeData( data )

-- if they are exiting the app record how many seconds the app ran for.
local function onApplicationExit( event )
	if ( event.type == "applicationExit" or event.type == "applicationSuspend") then
		data = getData()
		data.timeCount = data.timeCount + ( system.getTimer() / 100 )
		print( data.timeCount )
		writeData( data )
	end
end

Runtime:addEventListener("system", onApplicationExit)

-- if they are running an ios device
local appStore = nil

if ( device.isIOS ) then
	appStore = 'ios'
elseif ( device.isAmazon ) then
	appStore = 'amazon'
elseif ( device.isAndroid ) then
	appStore = 'google'
else
	appStore = "no valid app store"
end
-- native.showAlert("debug", appStore, {"OK"} )
-- native.showAlert("debug", data.count, {"Ok"} )
-- native.showAlert("debug", application.rateAfter, {"OK"} )


-- based on what we know lets determine if we should proceed based on:
-- if we've asked before and they've rated then nothing to do.
if (data.hasAsked and data.hasRated ) then
	return;

-- if they've been asked but said they'll rate it later do a 1 / 5 chance that we'll ask
elseif ( data.hasAsked and data.askLater and math.random(1, 5) ~= 1 ) then
	return;

-- if they've been asked but said no then exit.
elseif ( data.hasAsked and data.askLater == false ) then
	return;
end
-- native.showAlert('debug', application.rateAfter, {"OK"} )

local testRatingRuns = false
local testRatingDays = false
local testRatingTime = false

-- do the tests based on what's set in the config
if ( application.rateAfter ~= nil ) then
	if ( application.rateAfter.runs ~= nil ) then
		testRatingRuns = application.rateAfter.runs ~= nil and data.runCount >= application.rateAfter.runs	
	end

	if ( application.rateAfter.days ~= nil ) then
		local testRatingDays = application.rateAfter.days ~= nil and ( ( os.time() - data.timeFirstRun ) / 360 / 24 )  >= application.rateAfter.days
	end

	if ( application.rateAfter.time ~= nil ) then
		local testRatingTime = application.rateAfter.time ~= nil and data.timeCount >= application.rateAfter.time
	end
end




if ( testRatingRuns or testRatingDays or testRatingTime ) then
	-- check if app store url exists

	if ( application.appStores ~= nil and application.appStores[ appStore ] ~= nil or device.isSimulator) then
		
		local onClick = function( event ) 
			data.hasAsked = true
				
			-- if they've cancelled take that as an ask me later
			if ( event.action == "cancelled" ) then
				event.index = 2
			end

			if ( event.index == 1 ) then
				data.hasRated = 1

				if ( device.isSimulator ) then
					print ( 'opening browser')
					system.openURL( 'http://www.google.com' )
				else
					system.openURL( application.appStores[ appStore ] )
				end
			elseif  ( event.index == 2 ) then
				data.hasRated = false
				data.askLater = true
			elseif ( event.index == 3) then
				data.hasRated = false
				data.askLater = false
			end

			writeData( data )
		end

		response = native.showAlert('Rate our app!', "Having fun?\n\nHelp spread the word by rating our app and sharing your comments",  {"Rate Now", 'Maybe Later', 'Never'}, onClick )

		-- open app store url
		-- system.openURL( application.appStores[ appStore ] )
	end
end


