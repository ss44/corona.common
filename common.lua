module (..., package.seeall)
--[[
-- 
	vertical group manager lays out all items in a group vertically aligned
	@param group DisplayGroup to work with.
	@param opts Table of options to apply
		padding - vertical padding in pixels between each element.
--]]
function verticalGroupManager( group, opts )

	local padding = 5

	if ( opts ~= nil ) then
		if ( opts.padding ~= nil ) then
			padding = opts.padding
		end
	end

	
	for i = 1, group.numChildren, 1 do
		group[i].x = 0
		
		if ( group[ i - 1] ~= nil) then
			group[i].y = group[i-1].y + group[i-1].height + padding
		end
	end

end


--[[
-- 
	horizontal group manager lays out all items in a group horizontally aligned
	@param group DisplayGroup to work with.
	@param opts Table of options to apply
		padding - vertical padding in pixels between each element.
--]]
function horizontalGroupManager( group, opts )

	local padding = 5

	if ( opts ~= nil ) then
		if ( opts.padding ~= nil ) then
			padding = opts.padding
		end
	end


	for i = 1, group.numChildren, 1 do
		group[i].y = 0
		
		if ( group[ i - 1] ~= nil) then
			group[i].x = group[i-1].x + group[i-1].width + padding
		end
	end

end
