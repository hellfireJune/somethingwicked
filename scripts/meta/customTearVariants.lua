local mod = SomethingWicked
local sfx = SFXManager()

local backSprite = Sprite()
backSprite:Load("gfx/effect_wickedtearbacks.anm2", true)

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

--priority key:
-- 0 - default
-- 1 - chance based effect
-- 2 - special effect, usually spawned uniquely so multiple things wont be run against it yk
local tPriority = {
	[TearVariant.ICE] = 0.1,
	[TearVariant.ROCK] = 0.1,
	[TearVariant.EGG] = 1,
	[TearVariant.FIST] = 1,
	[TearVariant.MULTIDIMENSIONAL] = 2,
	[TearVariant.CHAOS_CARD] = 2,
	[TearVariant.BOBS_HEAD] = 2,
	[TearVariant.TOOTH] = 1,
	[TearVariant.BOOGER] = 1,
	[TearVariant.EYE] = 1.5,
	[TearVariant.EYE_BLOOD] = 1.5,
	[TearVariant.GRIDENT] = 2,
	[TearVariant.KEY] = 2,
	[TearVariant.KEY_BLOOD] = 2,
	[TearVariant.ERASER] = 2,
	[TearVariant.SPORE] = 1,
	[TearVariant.NEEDLE] = 1,
	[TearVariant.EXPLOSIVO] = 1,
	[TearVariant.STONE] = 2,
	[TearVariant.BLACK_TOOTH] = 1,

	--wicked
	[TearVariant.SOMETHINGWICKED_GANYSPARK] = 2,
	[TearVariant.SOMETHINGWICKED_LIGHT_SHARD] = 0.9,
}
function SomethingWicked:ChangeTearVariant(tear, variant)
	local priority = tPriority[variant] or 0
	local oldV = tear.Variant
	local oldP = tPriority[oldV] or 0
	if oldP <= priority then
		tear:ChangeVariant(variant)
	end
end

function mod:GetTearAnimPath(tear, animated)
	local scale = type(tear) == "number" and tear or tear.Scale
	local array = animated and animArray or staticArray
	for index, scalar in ipairs(array) do
		if scale <= scalar then
			return "Tear"..index, scalar, index
		end
	end
	return "Tear"..#array+1, array[#array], #array
end

local wickedTears = {
	TearVariant.SOMETHINGWICKED_GANYSPARK,
	TearVariant.SOMETHINGWICKED_LIGHT_SHARD
}
local anims = {
	TearVariant.SOMETHINGWICKED_GANYSPARK
}
local rotatesWithVelocity = {
	TearVariant.SOMETHINGWICKED_LIGHT_SHARD
	--TearVariant.SOMETHINGWICKED_GANYSPARK
}
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
	local var = tear.Variant
	if not mod:UtilTableHasValue(wickedTears, var) then
		return
	end
	local animated, rotates = mod:UtilTableHasValue(anims, var), mod:UtilTableHasValue(rotatesWithVelocity, var)
	
	local animPath = mod:GetTearAnimPath(tear, animated)

	local sprite = tear:GetSprite()
	local anim = sprite:GetAnimation()

	if anim ~= animPath then
		if not sprite:IsPlaying() then
			sprite:Play(animPath)
		else
			sprite:SetAnimation(animPath, true)
		end
	end
	
	--my scaling was fucked and i wouldve never figured this out if i hadnt checked retribution, thank you so much xalum
	tear.SpriteScale = Vector(1,1)/tear.Scale

	if rotates then
		local vel = tear.Velocity + Vector(0, tear.FallingSpeed)
		tear.SpriteRotation = mod:GetAngleDegreesButGood(vel) + 90
	end
	local t_data = tear:GetData()
	t_data.sw_savedScale = tear.Scale

	if tear.Variant == TearVariant.SOMETHINGWICKED_LIGHT_SHARD or tear.Variant == TearVariant.SOMETHINGWICKED_GANYSPARK then
		t_data.sw_tearBackScale = tear.Scale * 0.4 * Vector.One
		t_data.sw_tearBackColor = tear.Color*Color(1,1,1,1,-0.2,-0.2,-0.2)
		if tear.Variant == TearVariant.SOMETHINGWICKED_GANYSPARK then
			t_data.sw_tearBackColor =t_data.sw_tearBackColor* Color(1,1,1,0.25 	)
		end
		t_data.sw_tearBackAnim = "ShardBack"
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, tear)
	if tear.Variant == TearVariant.SOMETHINGWICKED_GANYSPARK then
        local explode = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_WISP_EXPLODE, 0, tear.Position + tear.PositionOffset, Vector.Zero, tear)
		explode.SpriteScale = Vector.One*(tear:GetData().sw_savedScale or 1) *1.2

		sfx:Play(SoundEffect.SOUND_FREEZE_SHATTER)
	end

	if tear.Variant == TearVariant.SOMETHINGWICKED_LIGHT_SHARD then
        local explode = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, tear.Position + tear.PositionOffset, Vector.Zero, tear)
		explode.SpriteScale = Vector.One*(tear:GetData().sw_savedScale or 1)*0.8
		explode.Color = tear.Color

		--[[local light = tear:GetData().sw_tearLight
		if light then
			light:Remove()
		end]]
		--sfx:Play(SoundEffect.SOUND_SCYTHE_BREAK)
	end
end, EntityType.ENTITY_TEAR)

mod:AddPriorityCallback(ModCallbacks.MC_PRE_TEAR_RENDER, CallbackPriority.LATE, function (_, tear, oset)
	local t_data = tear:GetData()
	if t_data.sw_tearBackAnim then
		backSprite:Play(t_data.sw_tearBackAnim)
		backSprite.Color = t_data.sw_tearBackColor
		backSprite.Scale = t_data.sw_tearBackScale
		backSprite:Render( Isaac.WorldToRenderPosition(tear.Position+tear.PositionOffset)+oset)
	end
end)