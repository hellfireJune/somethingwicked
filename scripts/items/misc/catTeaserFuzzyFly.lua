local mod = SomethingWicked
local function TearWobble(tear, angle)
    local t_data = tear:GetData()
    t_data.sw_wobbleLastVector = t_data.sw_wobbleLastVector or Vector.Zero
    t_data.sw_wobbleLastOffset = t_data.sw_wobbleLastOffset or 0

    tear.Velocity = tear.Velocity - t_data.sw_wobbleLastVector
    local v = tear.Velocity:Rotated(90):Normalized()
    v = v*(angle-t_data.sw_wobbleLastOffset)
    tear.Velocity = tear.Velocity + v
    t_data.sw_wobbleLastVector = v
    t_data.sw_wobbleLastOffset = angle
end

--Fluke Worm
local maxWibbleWobble = 30
local wibWobSpeed = 0.4
function mod:WibbleWobbleTearUpdate(tear, isSnake)
    local t_data = tear:GetData()
    t_data.sw_ctDisTravelled = (t_data.sw_ctDisTravelled or 0) + tear.Velocity:Length()
    t_data.sw_catTeaserEstRange = t_data.sw_catTeaserEstRange or 80
    local speed = wibWobSpeed

    local mult = math.max((t_data.sw_ctDisTravelled - t_data.sw_catTeaserEstRange)/40, 0)
    if isSnake then
        mult = 1
    end
    if mult > 0 then
        if not isSnake then
            mult = mult*maxWibbleWobble
        else
            mult = mult*maxWibbleWobble/1.5
            speed = speed/1.4
        end
        t_data.sw_catTick = (t_data.sw_catTick or 0)+1

        local angle = math.sin(t_data.sw_catTick*speed)*mult
        TearWobble(tear, angle)
        return angle/maxWibbleWobble
    end
end

mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_CAT_TEASER, {
    ApplyLogic = function (_, player, tear)
        if player:HasTrinket(mod.TRINKETS.FLUKE_WORM) then
            local t_data = tear:GetData()
            if not t_data.snakeTearData then
                return true
            end
        end
    end,
    PostApply = function (_, player, tear)
        tear:GetData().sw_catTeaserEstRange = player.TearRange/2
    end,
    OverrideTearUpdate = function (_, tear)
        mod:WibbleWobbleTearUpdate(tear)
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