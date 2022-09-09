local this = {}
Card.SOMETHINGWICKED_MANTIS = Isaac.GetCardIdByName("Mantis")
Card.SOMETHINGWICKED_MANTIS_GOD = Isaac.GetCardIdByName("MantisGod")

function this:MantisEffect(_, player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_20_20)
end

function this:MantisGodEffect(_, player)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_INNER_EYE)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.MantisEffect, Card.SOMETHINGWICKED_MANTIS)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.MantisGodEffect, Card.SOMETHINGWICKED_MANTIS_GOD)

this.EIDEntries = {
    [Card.SOMETHINGWICKED_MANTIS] = {
        desc = "Gives the effect of 20/20 for the current room."
    },
    [Card.SOMETHINGWICKED_MANTIS_GOD] = {
        desc = "Gives the effect of inner eye for the current room"
    }
}
return this