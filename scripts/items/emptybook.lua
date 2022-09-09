local this = {}
TrinketType.SOMETHINGWICKED_EMPTY_BOOK = Isaac.GetTrinketIdByName("Blank Book")
this.dummyItem = Isaac.GetItemIdByName("dummy item 002")

function this:PlayerUpdate(player)
    local hasTrinket = player:HasTrinket(TrinketType.SOMETHINGWICKED_EMPTY_BOOK)
    local hasItem = player:HasCollectible(this.dummyItem)

    if hasItem ~= hasTrinket then
        if not hasTrinket then
            player:RemoveCollectible(this.dummyItem)
        else
            player:AddCollectible(this.dummyItem)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_EMPTY_BOOK] = {
        desc = "{{Bookworm}} While held, counts as 1 item towards the Bookworm transformation",
        isTrinket = true,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"While held, counts as 1 item towards the Bookworm transformation"})
    }
}
return this