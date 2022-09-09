local this = {}
Card.SOMETHINGWICKEDTHOTH_THE_MAGUS_REVERSED = Isaac.GetCardIdByName("TheMagusReversed")

function this:UseCard(_, player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMEGETON)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_THE_MAGUS_REVERSED)


this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_THE_MAGUS_REVERSED] = {
        desc = "Spawns a Lemegeton item wisp"
    }
}
return this