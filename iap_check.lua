module (..., package.seeall)

local crypto = require 'crypto'
local fullVersion = nil
local store = require("store")
local productList = {}
local checkedStoreRestore = false

local json = require 'json'

function init( productListTable )

	productList = productListTable

	-- fullVersion = true
	if ( system.getInfo('platformName') == "Android" ) then
		store.init( "google", transactionCallbackGoogle )
	elseif ( system.getInfo('platformName') == "iPhone OS" ) then
		store.init( "apple", transactionCallbackApple )
	end

end

function purchase( code )

	local purchaseName = ""

	if ( productList[code] ~= nil ) then
		if ( system.getInfo('platformName') == "iPhone OS") then
			if ( productList[code].ios ~= nil ) then
				purchaseName = productList[ code ].ios
			end
		elseif ( system.getInfo('platformName') == "Android") then
			if ( productList[code].android ~= nil ) then
				purchaseName = productList[ code ].android
			end
		elseif( system.getInfo('environment') == "simulator") then
			purchaseName = productList[ code ]
		end
	end

	if ( purchaseName ~= "") then
		-- native.showAlert('debug', "calling purchase",  {"OK"} )

		if ( system.getInfo('environment') == "simulator") then
			setFullVersion()
		else
			store.purchase( purchaseName )
		end
	end
end

function isFullVersion()
	fullVersion = false

	local file = io.open( getVersionFilePath(), 'r')

	-- check if the file exists
	if ( file ~= nil ) then
		-- does it contain the appropriate contents		
		local contents = file:read()

		if ( contents == getDeviceHash() ) then
			return true
		end
	end

	if ( checkedStoreRestore == false ) then
		fullVersion = checkStoreFullVersion()
	else
		fullVersion = false
	end
	

	return fullVersion
end

function checkStoreFullVersion()
	checkedStoreRestore = true
	store.restore()
end

function getStoreObj()
	return store
end

function transactionCallbackGoogle( event )
	local transaction = event.transaction
	
	if (transaction.state == "purchased") then
		setFullVersion()
		-- store.finishTransaction( transaction )
	elseif ( transaction.state == "restored") then
		setFullVersion()
		-- store.finishTransaction( transaction )
	end

end

function getVersionFilePath()
	return system.pathForFile( "version.dat", system.DocumentsDirectory )
end

function setFullVersion()

	local path = getVersionFilePath()
	local file = io.open(path, 'w')

	-- create a file with our device hash in it.
	file:write( getDeviceHash() )
	file:close()

	Runtime:dispatchEvent( { name = "iap", phase ="purchased"} )
end

function getDeviceHash()

	local str = system.getInfo('deviceID') .. system.getInfo('environment') .. system.getInfo('platformName') .. system.getInfo('build') .. 'rIlXkFS82pAAEHPcci4WYX1jkSA7S2HKEnhEbG07dzs='
	return crypto.digest ( crypto.md5, str )

end


function transactionCallbackApple( event )

    local transaction = event.transaction
    if transaction.state == "purchased" then
        -- If store.purchase() was successful, you should end up in here for each product you buy.
        print("Transaction succuessful!")
        print("productIdentifier", transaction.productIdentifier)
        print("receipt", transaction.receipt)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)
    elseif  transaction.state == "restored" then
        print("Transaction restored (from previous session)")

    elseif transaction.state == "cancelled" then
        print("User cancelled transaction")

    elseif transaction.state == "failed" then
        print("Transaction failed, type:", transaction.errorType, transaction.errorString)

    else
        print("unknown event")
    end

    -- Once we are done with a transaction, call this to tell the store
    -- we are done with the transaction.
    -- If you are providing downloadable content, wait to call this until
    -- after the download completes.
    store.finishTransaction( transaction )

end