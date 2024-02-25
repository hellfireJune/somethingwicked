function this:CacheFlag(player)    
    local n_rng = player:GetTrinketRNG(mod.TRINKETS.NIGHTMARE_FUEL)
    local n_sourceItem = Isaac.GetItemConfig():GetTrinket(mod.TRINKETS.NIGHTMARE_FUEL)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, player:GetTrinketMultiplier(mod.TRINKETS.NIGHTMARE_FUEL), n_rng, n_sourceItem, SomethingWicked.NightmareSubTypes.NIGHTMARE_PERMANENT) 

    local v_rng = player:GetTrinketRNG(mod.TRINKETS.VIRTUE)
    local v_sourceItem = Isaac.GetItemConfig():GetTrinket(mod.TRINKETS.VIRTUE)
    player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_NIGHTMARE, player:GetTrinketMultiplier(mod.TRINKETS.VIRTUE), v_rng, v_sourceItem, SomethingWicked.NightmareSubTypes.NIGHTMARE_HOLY)
end

function this:NewRoom()
    for _, value in ipairs(SomethingWicked.ItemHelpers:AllPlayersWithTrinket(mod.TRINKETS.NIGHTMARE_FUEL)) do
        value:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
        value:EvaluateItems()
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheFlag, CacheFlag.CACHE_FAMILIARS)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.NewRoom)

this.EIDEntries = {
    [mod.TRINKETS.NIGHTMARE_FUEL] = {
        desc = "Spawns 1 Nightmare familiar which erattically orbits the player and attacks nearby enemies with homing tears#Familiar respawns each room if it dies",
        isTrinket = true,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 1 Nightmare familiar which erattically orbits the player and attacks nearby enemies with homing tears","Familiar respawns each room if it dies"})
    }
}
return this