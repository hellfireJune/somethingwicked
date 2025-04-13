local mod = SomethingWicked

local function ModifyVelocity(tear)
    local player = mod:UtilGetPlayerFromTear(tear)
    if not player or not player:HasCollectible(mod.ITEMS.ASTIGMATISM) then
        return
    end

    local c_rng = player:GetCollectibleRNG(mod.ITEMS.ASTIGMATISM)
    local speedMult = math.max(1, c_rng:RandomFloat() + (0.4*player:GetCollectibleNum(mod.ITEMS.ASTIGMATISM)))
    tear.Velocity = tear.Velocity * speedMult
    if tear.Type == EntityType.ENTITY_TEAR then
        tear.Height = tear.Height * (1 / speedMult)
    end
end
function mod:astigmatismTearUpdate(tear)
    if tear.FrameCount ~= 1 then
        return
    end
    ModifyVelocity(tear)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, mod.astigmatismTearUpdate )

local function FastenBombs(_, bomb)
    if not bomb.IsFetus
    or bomb.FrameCount ~= 1 then
        return
    end

    ModifyVelocity(bomb)
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, FastenBombs)

--[[this.EIDEntries = {
    [mod.ITEMS.ASTIGMATISM] = {
        desc = "+0.35 tears up#Tears will sometimes move faster",
        Hide = true,
    }
}
return this]]