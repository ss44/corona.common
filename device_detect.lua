--[[

Basic shortcut methods to handle device detection by running various if statements
and populating a table to verify the device that app is currently running on.


]]
local device = {
	isDevice = false,
	isSimulator = false,	
	isAndroid = false,
	isKindleFire = false,
	isKindelFireHD7 = false,
	isKindleFireHD9 = false,
	isIOS = false,
	isIPad = false,
	isIPhone = false,
	isAmazon = false,
}

if ( system.getInfo("environment") == "simulator") then
	device.isSimulator = true	
else
	device.isDevice = true
end

if ( system.getInfo("platformName") == "Android") then
	
	device.isAndroid = true

	if ( system.getInfo("model") == "Kindle Fire" )  then
		device.isAmazon = true
		device.isKindleFire = true
	end

	if ( system.getInfo("model") == "KFTT" )  then
		device.isAmazon = true
		device.isKindleFireHD7 = true
	end

	if ( system.getInfo("model") == "WFJWI" )  then
		device.isAmazon = true
		device.isKindleFireHD9 = true
	end

elseif ( system.getInfo("platformName") == "iPhone OS" ) then
	device.isIOS = true

	if ( system.getInfo("model") == "iPhone") then
		device.isIPhone = true
	end

	if ( system.getInfo("model") == "iPad") then
		device.isIPad = true
	end
end

return device