--SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheFlag, CacheFlag.CACHE_FAMILIARS)


function this:UseItem(_, _, player, flags)
    --local p_data = player:GetData()
    local scrunkly = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, 0, player.Position, Vector.Zero, player)      
    scrunkly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    return true
end



function  this:WispUpdate(familiar)
    if familiar.SubType == CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY then    
        local player = familiar.Player
        
        SomethingWicked.EnemyHelpers:FluctuatingOrbitFunc(familiar, player)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.WispUpdate, FamiliarVariant.WISP)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BOOK_OF_INSANITY] = {
        desc = "Spawns a Nightmare familiar upon use#These nightmare familiars will block bullets and erattically orbit the player, firing homing tears at anything in a nearby radius#Nightmares will die after two hits",
        
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_LIBRARY,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns a Nightmare familiar upon book use","These nightmare familiars will block bullets and erattically orbit the player, firing homing tears at anything in a nearby radius","Nightmares will die after two hits"})
    }
}
return this