local this = {}
this.dummyItem = Isaac.GetItemIdByName("dummy item 001") 
CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN = Isaac.GetItemIdByName("Apollyon's Crown") 

function this:FamiliarCache(player)
    player = player:ToPlayer()
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN)
    local sourceItem = Isaac.GetItemConfig():GetCollectible(CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN)
    local boxEffect = player:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local boxStacks = 0
    if boxEffect ~= nil then
        boxStacks = boxEffect.Count
    end

    player:CheckFamiliar(FamiliarVariant.ABYSS_LOCUST, player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN) * (1 + boxStacks) * 2, rng, sourceItem, this.dummyItem)
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.FamiliarCache, CacheFlag.CACHE_FAMILIAR)


this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN] = {
        desc = "{{Collectible706}}Spawns 2 permanent abyss locusts as companions",
        
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_BABY_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 2 permanant abyss locusts as companions"}, "Their king is the angel from the bottomless pit, his name in Hebrew is Abaddon, and in Greek, Apollyon, the Destroyer.")
    }
}
return this