local this = {}
this.blacklist = { 577, 585, 622, 628, 127, 297, 347, 475, 483, 490, 515}

function this:ItemUse(id, _, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 or flags & UseFlag.USE_OWNED == 0 then
        return
    end
    local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, id)
    if charge == 0
    or SomethingWicked:UtilTableHasValue(this.blacklist, id) then
        return
    end

    local timesToUseBonus = 0
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_ELECTRIC_DICE) then
        timesToUseBonus = timesToUseBonus + player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_ELECTRIC_DICE):RandomInt(3)
    end
    if player:HasTrinket(TrinketType.SOMETHINGWICKED_BUSTED_BATTERY) then
        local t_rng = player:GetTrinketRNG(TrinketType.SOMETHINGWICKED_BUSTED_BATTERY)
        if t_rng:RandomFloat() < 0.33 * player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_BUSTED_BATTERY) then
            timesToUseBonus = timesToUseBonus + 1
        end
    end
                
    for i = 1, timesToUseBonus, 1 do
        player:UseActiveItem(id, flags | 1 << 5)

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position + ((i + 0.5) * Vector(0, -50)), Vector.Zero, player)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.ItemUse)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_ELECTRIC_DICE] = {
        desc = "↑ Has a chance to use an active item 1-2 more times on use",
        
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Using an active item has a chance to use said item 1-2 more times. Does not work on items with 0 charge, or consumable actives"})
    }
}
return this