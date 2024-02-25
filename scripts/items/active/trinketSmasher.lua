local mod = SomethingWicked
local sfx = SFXManager()

local minDrops = 3
local maxDrops = 4
local pickupTable = {PickupVariant.PICKUP_HEART, PickupVariant.PICKUP_COIN,
                    PickupVariant.PICKUP_BOMB, PickupVariant.PICKUP_KEY, PickupVariant.PICKUP_GRAB_BAG,
                    PickupVariant.PICKUP_PILL, PickupVariant.PICKUP_LIL_BATTERY, PickupVariant.PICKUP_TAROTCARD}

local function UseCrusher(_, _, t_rng, player, flags)
    local currTrinket = player:GetTrinket(0)
    if currTrinket ~= 0 then
        local freq = 1
        local isGold = false
        if currTrinket & TrinketType.TRINKET_GOLDEN_FLAG ~= 0 then
            isGold = true
            freq = freq + 1
        end
        if currTrinket == mod.TRINKETS.GACHAPON or currTrinket == mod.TRINKETS.GACHAPON + TrinketType.TRINKET_GOLDEN_FLAG then
            mod:GachaponDestroy(nil, player, isGold)
        end

        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
            for i = 1, (freq - 1) * 2, 1 do
                player:AddWisp(mod.ITEMS.TRINKET_SMASHER, player.Position)
            end
        end
        
        player:TryRemoveTrinket(currTrinket)
        local spawnPos = player.Position
        freq = freq * (t_rng:RandomInt(maxDrops - minDrops) + minDrops)
        for i = 1, freq, 1 do
            local pickupToCreate = mod:GetRandomElement(pickupTable, t_rng)
            Isaac.Spawn(EntityType.ENTITY_PICKUP, pickupToCreate, 0, spawnPos, mod:GetPayoutVector(t_rng), player)
        end

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, player.Position, Vector.Zero, player)

        sfx:Play(SoundEffect.SOUND_METAL_BLOCKBREAK)
        return true
    end
    return {ShowAnim = true, Discharge = false}
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseCrusher, mod.ITEMS.TRINKET_SMASHER)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player)
    if player:HasCollectible(mod.ITEMS.TRINKET_SMASHER) then
        mod:AddItemWispForEval(player, CollectibleType.COLLECTIBLE_SMELTER)
    end
end)