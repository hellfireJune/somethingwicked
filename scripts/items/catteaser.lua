local this = {}
local mod = SomethingWicked
local function TearWobble(tear, angle)
    local t_data = tear:GetData()
    t_data.sw_wobbleLastAngle = t_data.sw_wobbleLastAngle or 0

    tear.Velocity = tear.Velocity:Rotated(angle - t_data.sw_wobbleLastAngle)
    t_data.sw_wobbleLastAngle = angle
end

--Cat Teaser
local maxWibbleWobble = 45
local wibWobSpeed = 0.1
local function TearUpdate(tear)
    local t_data = tear:GetData()
    t_data.sw_ctDisTravelled = (t_data.sw_ctDisTravelled or 0) + tear.Velocity:Length()
    t_data.sw_catTeaserEstRange = t_data.sw_catTeaserEstRange or 80

    local mult = math.max((t_data.sw_ctDisTravelled - t_data.sw_catTeaserEstRange)/40, 0)
    if mult > 0 then
        mult = mult/t_data.sw_catTeaserEstRange*maxWibbleWobble
        t_data.sw_catTick = t_data.sw_catTick or 0

        local angle = math.sin(t_data.sw_catTick*wibWobSpeed)*mult
        TearWobble(tear, angle)
    end
end

mod.TFCore:AddNewFlagData(mod.CustomTearFlags.FLAG_CAT_TEASER, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_CAT_TEASER) then
            return true
        end
    end,
    PostApply = function (_, player, tear)
        tear:GetData().sw_catTeaserEstRange = player.TearRange/2
    end,
    OverrideTearUpdate = function (_, tear)
        TearUpdate(tear)
    end
})

--Fuzzy Fly
local fuzzRadius = 200
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    familiar:MoveDiagonally(1)

    local nearbyProjectiles = Isaac.FindInRadius(familiar.Position, fuzzRadius, EntityPartition.BULLET)
    for index, bullet in ipairs(nearbyProjectiles) do
        local b_data = bullet:GetData()
        b_data.somethingWicked_shouldFuzzyThisFrame = true
    end
end, FamiliarVariant.SOMETHINGWICKED_FUZZY_FLY)

local maxFuzzFrames = 14
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function (_, proj)
    local b_data = proj:GetData()
    if not b_data.sw_fuzzMult then
        if b_data.somethingWicked_shouldFuzzyThisFrame then
            b_data.sw_fuzzMult = 0
        else
            return
        end
    end
    if b_data.somethingWicked_shouldFuzzyThisFrame then
        b_data.sw_fuzzMult = math.min(maxFuzzFrames, b_data.sw_fuzzMult + 1)
        b_data.somethingWicked_shouldFuzzyThisFrame = false
    else
        b_data.sw_fuzzMult = math.max(b_data.sw_fuzzMult - 1, 0)
        if b_data.sw_fuzzMult == 0 then
            b_data.sw_fuzzMult = nil
            return
        end
    end
    b_data.sw_fuzzTick = (b_data.sw_fuzzTick or 0) + (b_data.sw_fuzzMult/maxFuzzFrames)
    local mult = math.min(b_data.sw_fuzzTick/maxFuzzFrames, 1)
    
    local angle = math.sin(b_data.sw_fuzzTick*wibWobSpeed)*mult
    TearWobble(proj, angle)
end)


this.EIDEntries = {[CollectibleType.SOMETHINGWICKED_CAT_TEASER] = {
    desc = "mew mew mew",
    Hide = true,
}}
return this