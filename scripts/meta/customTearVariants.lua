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
	1.175,
	1.675,
	2.175
}

local function GetTearAnimPath(tear, animated)
	local scale = tear.Scale
	local array = animated and animArray or staticArray
	for index, scalar in ipairs(array) do
		if scale <= scalar then
			return "Tear"..index, scale
		end
	end
	return "Tear"..#array+1, scale
end

local wickedTears = {
	TearVariant.SOMETHINGWICKED_REALLY_GOOD_PLACEHOLDER
}
local anims = {
	TearVariant.SOMETHINGWICKED_REALLY_GOOD_PLACEHOLDER
}
local rotatesWithVelocity = {
	--TearVariant.SOMETHINGWICKED_REALLY_GOOD_PLACEHOLDER
}
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
	local var = tear.Variant
	if not mod:UtilTableHasValue(wickedTears, var) then
		return
	end
	local animated, rotates = mod:UtilTableHasValue(anims, var), mod:UtilTableHasValue(rotatesWithVelocity, var)
	
	local animPath, scalar = GetTearAnimPath(tear, animated)

	local sprite = tear:GetSprite()
	local anim = sprite:GetAnimation()

	if anim ~= animPath then
		if not sprite:IsPlaying() then
			sprite:Play(animPath)
		else
			sprite:SetAnimation(animPath, true)
		end
	end
	tear.SpriteScale = Vector(1,1)*(tear.Scale/scalar)

	if rotates then
		local vel = tear.Velocity + Vector(0, tear.FallingSpeed)
		tear.SpriteRotation = mod:GetAngleDegreesButGood(vel)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function ()
	
end, EntityType.ENTITY_TEAR)