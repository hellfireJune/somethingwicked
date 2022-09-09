local this = {}
CollectibleType.SOMETHINGWICKED_ELECTRIC_DICE = Isaac.GetItemIdByName("Electric Dice")
this.blacklist = { 577, 585, 622, 628, 127, 297, 347, 475, 483, 490, 515}

function this:ItemUse(id, _, player, flags)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_ELECTRIC_DICE) then
        if flags & UseFlag.USE_CARBATTERY == 0 then
            local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, id)
            if charge ~= 0
            and SomethingWicked:UtilTableHasValue(this.blacklist, id) == false then
                
                local rng = RNG()
                rng:SetSeed(Random() + 1, 1)
                for i = 1, rng:RandomInt(3), 1 do
                    player:UseActiveItem(id, flags | 1 << 5)

                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position + ((i + 0.5) * Vector(0, -50)), Vector.Zero, player)
                end
            end
        end
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