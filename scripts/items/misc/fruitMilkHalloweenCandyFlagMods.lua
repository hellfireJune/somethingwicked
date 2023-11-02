local mod = SomethingWicked

local flagsBlacklist = {
    TearFlags.TEAR_GISH,
    TearFlags.TEAR_GLITTER_BOMB,
    TearFlags.TEAR_SCATTER_BOMB,
    TearFlags.TEAR_TRACTOR_BEAM,
    TearFlags.TEAR_CROSS_BOMB,
    TearFlags.TEAR_BLOOD_BOMB,
    TearFlags.TEAR_BRIMSTONE_BOMB,
    TearFlags.TEAR_GHOST_BOMB
}
mod.quickTearFlagAdders = {
    [TrinketType.SOMETHINGWICKED_HALLOWEEN_CANDY] = {
        chance = 0.11, flags = TearFlags.TEAR_FEAR, trinket = true
    },
    [TrinketType.SOMETHINGWICKED_GODLY_TOMATO] = {
        chance = 0.135, flags = TearFlags.TEAR_GLOW, trinket = true
    },
    [TrinketType.SOMETHINGWICKED_POPPET] = {
        chance = 0.135, flags = TearFlags.TEAR_PIERCING | TearFlags.TEAR_BELIAL, trinket = true
    }
}

local flagsToGive = 5
function mod:GenerateFruitFlag(rng)
    local newFlags = TearFlags.TEAR_NORMAL
    for i = 1, flagsToGive, 1 do
        local flagToAdd = TearFlags.TEAR_NORMAL
        while flagToAdd == TearFlags.TEAR_NORMAL or (newFlags & flagToAdd) == 0
        or mod:UtilTableHasValue(flagsBlacklist, flagToAdd) do
            flagToAdd = mod:TEARFLAG(rng:RandomInt(TearFlags.TEAR_EFFECT_COUNT))
        end

        if flagToAdd == TearFlags.TEAR_BELIAL then
            newFlags = newFlags | TearFlags.TEAR_PIERCING
        end
        newFlags = newFlags | flagToAdd
    end
    return newFlags
end

function mod:GetBonusTearFlagsToAdd(player)
    local newFlags = TearFlags.TEAR_NORMAL
    for collectible, data in pairs(mod.quickTearFlagAdders) do
        --print(collectible)
        local isTrink = data.trinket
        if not isTrink and player:HasCollectible(collectible) 
        or (isTrink and player:HasTrinket(collectible)) then
           local rng = isTrink and player:GetTrinketRNG(collectible) or player:GetCollectibleRNG(collectible)

           local mult = not isTrink and 1 or player:GetTrinketMultiplier(collectible)
           if rng:RandomFloat() < data.chance*mult then
                newFlags = newFlags | data.flags
           end
        end
    end
    return newFlags
end

local function PEffectUpdate(_, player)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.FlagCheckTimer = (p_data.SomethingWickedPData.FlagCheckTimer or 6) - 1
    if p_data.SomethingWickedPData.FlagCheckTimer <= 0 then
        p_data.SomethingWickedPData.FruitMilkFlags = nil
        p_data.SomethingWickedPData.BonusVanillaFlags = mod:GetBonusTearFlagsToAdd(player)
        p_data.SomethingWickedPData.FlagCheckTimer = 20
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
        player:EvaluateItems()
    end
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_FRUIT_MILK) then
        if p_data.SomethingWickedPData.FruitMilkFlags == nil then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_FRUIT_MILK)
            local newFlags = mod:GenerateFruitFlag(c_rng)
            p_data.SomethingWickedPData.FruitMilkFlags = newFlags
            player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
            player:EvaluateItems()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PEffectUpdate)
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_FIRE_PURE, function (_, _, _, _, player)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.FlagCheckTimer = 0
end)
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, function (_, tear)
    local player = mod:UtilGetPlayerFromTear(tear)
    if player then
        local p_data = player:GetData()
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_FRUIT_MILK) then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_FRUIT_MILK)
            local newFlags = mod:GenerateFruitFlag(c_rng)
            p_data.SomethingWickedPData.FruitMilkFlags = newFlags
        end
        p_data.SomethingWickedPData.BonusVanillaFlags = mod:GetBonusTearFlagsToAdd(player)
        player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
        player:EvaluateItems()
    end
end)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function (_, trinket)
    if (trinket.SubType ~= TrinketType.SOMETHINGWICKED_HALLOWEEN_CANDY)
    or trinket.FrameCount % 5 ~= 4 then
        return
    end

    for _, ent in ipairs(Isaac.FindInRadius(trinket.Position, 60, 8)) do
        if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
            ent:AddFear(EntityRef(trinket), 25)
        end
    end
end, PickupVariant.PICKUP_TRINKET)

--[[this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_FRUIT_MILK] = {
        desc = "",
        Hide = true
    },
}]]