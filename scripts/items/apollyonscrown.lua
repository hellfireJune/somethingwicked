local this = {}
this.dummyItem = Isaac.GetItemIdByName("dummy item 001") 

function this:FamiliarCache(player)
    local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_APOLLYONS_CROWN)
    player:CheckFamiliar(FamiliarVariant.ABYSS_LOCUST, stacks*2, rng, sourceItem, this.dummyItem)
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.FamiliarCache, CacheFlag.CACHE_FAMILIARS)


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