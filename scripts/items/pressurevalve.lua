local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_PRESSURE_VALVE = Isaac.GetItemIdByName("Pressure Valve")

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    if flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = mod.StatUps:TearsUp(player, player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_PRESSURE_VALVE)* 0.4)
    end
end)

local function ModifyVelocity(tear)
    local player = mod:UtilGetPlayerFromTear(tear)
    if not player or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_PRESSURE_VALVE) then
        return
    end

    local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_PRESSURE_VALVE)
    local speedMult = math.max(1, c_rng:RandomFloat() + (0.4*player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_PRESSURE_VALVE)))
    tear.Velocity = tear.Velocity * speedMult
    if tear.Type == EntityType.ENTITY_TEAR then
        tear.Height = tear.Height * (1 / speedMult)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    if tear.FrameCount ~= 1 then
        return
    end
    ModifyVelocity(tear)
end)

local function FastenBombs(_, bomb)
    if not bomb.IsFetus
    or bomb.FrameCount ~= 1 then
        return
    end

    ModifyVelocity(bomb)
end
mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, FastenBombs)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_PRESSURE_VALVE] = {
        desc = "+0.4 tears up#Tears will sometimes move faster",
        Hide = true,
    }
}
return this