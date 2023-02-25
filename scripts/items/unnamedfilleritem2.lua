local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_UNNAMED_TEARS_UP = Isaac.GetItemIdByName("another filler item")

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player, flags)
    if flags == CacheFlag.CACHE_FIREDELAY then
        player.MaxFireDelay = mod.StatUps:TearsUp(player, 0.4)
    end
end)

local function ModifyVelocity(tear)
    local player = mod:UtilGetPlayerFromTear(tear)
    if not player or not player:HasCollectible(CollectibleType.SOMETHINGWICKED_UNNAMED_TEARS_UP) then
        return
    end

    local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_UNNAMED_TEARS_UP)
    local speedMult = math.min(1, c_rng:RandomFloat() + 0.4)
    tear.Velocity = tear.Velocity * speedMult
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
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
    [CollectibleType.SOMETHINGWICKED_UNNAMED_TEARS_UP] = {
        desc = "tears up#makes you queer"
    }
}
return this