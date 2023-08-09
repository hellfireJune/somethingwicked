local this = {}

function this:UseCard(_, player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_FORTUNE)

this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_FORTUNE] = {
        desc = "{{Collectible437}}Invokes the D7 effect"
    }
}
return this