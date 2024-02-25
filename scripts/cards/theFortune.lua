local this = {}

function this:UseCard(_, player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_D7, UseFlag.USE_NOANIM)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, mod.CARDS.THOTH_FORTUNE)

this.EIDEntries = {
    [mod.CARDS.THOTH_FORTUNE] = {
        desc = "{{Collectible437}}Invokes the D7 effect"
    }
}
return this