local this = {}

function this:CardUse(_, player)
    --local tempEffects = player:GetEffects()
    --tempEffects:AddCollectibleEffect(CollectibleType.SOMETHINGWICKED_TOYBOX, true, 1)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK, 1, 0)
    local trinket = SomethingWicked.game:GetItemPool():GetTrinket()
    player:AnimateTrinket(trinket, "Pickup")
    SomethingWicked:UtilAddSmeltedTrinket(trinket, player)
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.CardUse, Card.SOMETHINGWICKED_STONE_OF_THE_PIT)
this.EIDEntries = {
    [Card.SOMETHINGWICKED_STONE_OF_THE_PIT] = {
        desc = "Smelts one random trinket onto you."
    }
}
return this