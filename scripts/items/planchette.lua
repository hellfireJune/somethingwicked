local this = {}
CollectibleType.SOMETHINGWICKED_PLANCHETTE = Isaac.GetItemIdByName("Planchette")
this.AffectedCompanions = {FamiliarVariant.ITEM_WISP, FamiliarVariant.WISP, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE}

function this:BuffFamiliarHP(familiar)
    if not SomethingWicked:UtilTableHasValue(this.AffectedCompanions, familiar.Variant)
    or familiar.FrameCount ~= 5 then
        return
    end

    local player = familiar.Player
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_PLANCHETTE) then
        familiar.MaxHitPoints = familiar.MaxHitPoints * 2
        familiar:AddHealth(familiar.MaxHitPoints - familiar.HitPoints)
    end
end

function this:WispFire(tear)
    if tear.FrameCount ~= 1 then
        return
    end

    local spawner = tear.SpawnerEntity
    if spawner and spawner.Type == EntityType.ENTITY_FAMILIAR and SomethingWicked:UtilTableHasValue(this.AffectedCompanions, spawner.Variant) then
        spawner = spawner:ToFamiliar()
        if spawner.Player:HasCollectible(CollectibleType.SOMETHINGWICKED_PLANCHETTE) then
            tear.Scale = tear.Scale * 1.5
            tear.CollisionDamage = tear.CollisionDamage * 2
        end
        --print("a")
        --tear:ResetSpriteScale()
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.WispFire)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.BuffFamiliarHP)
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player, room)
    for i = 1, 4, 1 do
        player:AddWisp(CollectibleType.SOMETHINGWICKED_PLANCHETTE, player.Position)
    end
end, CollectibleType.SOMETHINGWICKED_PLANCHETTE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_PLANCHETTE] = {
        desc = "↑ All wisps and nightmares have double HP and deal double damage from tears#Spawns four unique Book of Virtues wisps on pickup#+1 black heart",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"All wisps and nightmares have double HP and deal double damage from tears","Spawns four unique Book of Virtues wisps on pickup","+1 black heart",}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_CURSE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_CURSE
        }
    }
}
return this