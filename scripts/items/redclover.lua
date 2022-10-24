local this = {}
TrinketType.SOMETHINGWICKED_BLACK_AMULET = Isaac.GetTrinketIdByName("Demonium Page")
this.crashPreventer = 0

function this:BossPoolEdit(collectible, itempooltype, decrease, seed)
    if itempooltype ~= ItemPoolType.POOL_BOSS
    --or SomethingWicked.game:GetFrameCount() == 0 
    then
        return
    end

    if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_BLACK_AMULET) then
            while this.crashPreventer < 100 do
                local config = Isaac.GetItemConfig()
                local itempool = SomethingWicked.game:GetItemPool()
                local iConf = config:GetCollectible(collectible)
                this.crashPreventer = this.crashPreventer + 1
                if iConf.CacheFlags & CacheFlag.CACHE_DAMAGE ~= 0 then
                    this.crashPreventer = -1
                    return collectible
                end
                collectible = itempool:GetCollectible(ItemPoolType.POOL_BOSS)
            end
        end
    end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, this.BossPoolEdit)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_BLACK_AMULET] = {
        desc = "!!! While held, the only Boss Room items that can appear are ones that modify damage",
        isTrinket = true,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"While held, the only Boss Room pool items that can appear are ones that modify damage"})
    }
}
return this