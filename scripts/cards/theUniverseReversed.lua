local this = {}
Card.SOMETHINGWICKEDTHOTH_THE_UNIVERSE = Isaac.GetCardIdByName("TheUniverseReversed")
Card.SOMETHINGWICKEDTHOTH_THE_UNIVERSE_BOON = Isaac.GetCardIdByName("TheUniverseBoon")

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, function (_, player, useFlags)
    SomethingWicked.BoonHelpers:UseBoonCard(Card.SOMETHINGWICKEDTHOTH_THE_UNIVERSE, Card.SOMETHINGWICKEDTHOTH_THE_UNIVERSE_BOON, player, useFlags)
end, Card.SOMETHINGWICKEDTHOTH_THE_UNIVERSE)
SomethingWicked:AddBoon(Card.SOMETHINGWICKEDTHOTH_THE_UNIVERSE_BOON)