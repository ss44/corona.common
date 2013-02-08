--[[
	A simple helper that dispalys a notification to the user to rate an app,
	after they have run an app x number of times. T

	Requirements:
		In config.lua under application include the following with app store urls:
			
		application = {
			...
	
			-- Links to the app store url which this will redirect to.
			appStores = {
				'ios' = ,
				'google' = '',
				'amazon' = ''
			}
			
			-- Show the rating dialog after the app has been run at least x times.
			rateAfter = 10
			...
	}
]]
module (..., package.seeall)


local config = require('config')
local device = require('common.device_detect')

-- increment the number of times the app has been run
local path = system.pathForFile( "app-rate.dat", system.DocumentsDirectory )
local file = io.open(path, 'w+')

-- read the first line of the app
local contents = file:read()

-- if it's an int > 0 then increment + 1 and store counter
if ( contents >= 0 ) then
	count = contents + 1
else
	-- otherwise delete all contents of file and set to 0.
	count = 0
end

file:write( count )

-- if they are running an ios device
local appStore = nil

if ( device.isIOS ) then
	appStore = 'ios'
elseif ( device.isAmazon )
	appStore = 'amazon'
elseif ( device.Android ) then
	appStore = 'google'
end

-- if total count >= rateCount then 
if ( config.rateAfter ~= nil and count >= config.rateAfter ) then
	-- check if app store url exists
	if ( config.appStores ~= nil and config.appStores[ appStore ] ~= nil ) then
		-- open app store url
		system.openURL( config.appStores[ appStore ] )
	end
end