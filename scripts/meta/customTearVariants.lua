local mod = SomethingWicked

local staticArray = {
	0.3,
	0.55,
	0.675,
	0.8,
	0.925,
	1.05,
	1.175,
	1.425,
	1.675,
	1.925,
	2.175,
	2.55,
}
local animArray = {
	0.675,
	0.925,
	1.175,1.675,2.175
}

local function GetTearAnimPath(tear, animated)
	local scale = tear.Scale
	local array = animated and animArray or staticArray
	for index, scalar in ipairs(staticArray) do
		if tear.Scale <= scalar then
			return "Tear"..index, 1/tear.Scale
		end
	end
	return "Tear"..#array+1, 1/tear.Scale
end

local anims = {

}
local rotatesWithVelocity = {
	
}
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function ()
	
end)