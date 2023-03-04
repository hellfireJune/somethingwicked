local this = {}
--junes notes: yaaaaaaaawn im so fucking tired rn this code is probably gonna fuckin suck
Card.SOMETHINGWICKED_K0 = Isaac.GetCardIdByName("k0")

function this:UseCard(_, player)
    player:AddCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, false)
    player:RemoveCollectible(CollectibleType.COLLECTIBLE_TMTRAINER)
end


SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKED_K0)

this.EIDEntries = {
    [Card.SOMETHINGWICKED_K0] = {
        desc = "Rerolls all items in the current into glitch items"
    }
}
return this