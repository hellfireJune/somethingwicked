--and unstable crafts
--(this comment doesnt make sense anymore but this used to be called fish milk)

local this = {}
CollectibleType.SOMETHINGWICKED_BANANA_MILK = Isaac.GetItemIdByName("Banana Milk")

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

local flagsToGive = 5
local function GenerateNewFlag(rng)
    
    local newFlags = TearFlags.TEAR_NORMAL
    for i = 1, flagsToGive, 1 do
        local flagToAdd = TearFlags.TEAR_NORMAL
        while flagToAdd == TearFlags.TEAR_NORMAL or (newFlags & flagToAdd) == 0
        or SomethingWicked:UtilTableHasValue(flagsBlacklist, flagToAdd) do
            --[[Isaac.DebugString("-")
            Isaac.DebugString(tostring(flagToAdd))
            Isaac.DebugString(tostring(newFlags))
            Isaac.DebugString(tostring((newFlags & flagToAdd) ~= 0))
            Isaac.DebugString(tostring((newFlags & flagToAdd)))]]
            flagToAdd = SomethingWicked:TEARFLAG(rng:RandomInt(TearFlags.TEAR_EFFECT_COUNT))
        end

        if flagToAdd == TearFlags.TEAR_BELIAL then
            newFlags = newFlags | TearFlags.TEAR_PIERCING
        end
        newFlags = newFlags | flagToAdd
    end
    return newFlags
end

function this:PEffectUpdate(player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_BANANA_MILK) then
        local p_data = player:GetData()
        p_data.SomethingWickedPData.FishMilkTimer = (p_data.SomethingWickedPData.FishMilkTimer or 61) - 1
        if p_data.SomethingWickedPData.FishMilkTimer <= 0 then
            p_data.SomethingWickedPData.FishMilkFlags = nil
            p_data.SomethingWickedPData.FishMilkTimer = 60
        end
        if p_data.SomethingWickedPData.FishMilkFlags == nil then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BANANA_MILK)
            local newFlags = GenerateNewFlag(c_rng)
            p_data.SomethingWickedPData.FishMilkFlags = newFlags
            player:AddCacheFlags(CacheFlag.CACHE_TEARFLAG)
            player:EvaluateItems()
        end
    end
end


local damageMult = 0.3
function this:EvaluateCache(player, flags)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_BANANA_MILK) then
        if flags == CacheFlag.CACHE_DAMAGE then
            player.Damage = SomethingWicked.StatUps:DamageUp(player, 0, 0, damageMult)
        end

        if flags == CacheFlag.CACHE_TEARFLAG then
            local p_data = player:GetData()
            if not p_data.SomethingWickedPData.FishMilkFlags  then
                local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BANANA_MILK)
                local newFlags = GenerateNewFlag(c_rng)
                p_data.SomethingWickedPData.FishMilkFlags = newFlags
            end

            --print(p_data.SomethingWickedPData.FishMilkFlags)
            player.TearFlags = player.TearFlags | p_data.SomethingWickedPData.FishMilkFlags
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.EvaluateCache)

this.EIDEntries = {}
return this