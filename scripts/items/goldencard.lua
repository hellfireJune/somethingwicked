local this = {}
CollectibleType.SOMETHINGWICKED_GOLDEN_CARD = Isaac.GetItemIdByName("Golden Card")

function this:UseItem(_, rng, player)
    local p_data = player:GetData()
    local stacks = 1 + rng:RandomInt(2)
    p_data.SomethingWickedPData.FortuneR_Stacks = (p_data.SomethingWickedPData.FortuneR_Stacks or 0) + stacks
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_GOLDEN_CARD)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, wisp)
    wisp = wisp:ToFamiliar()
    if wisp and wisp.Variant == FamiliarVariant.WISP and wisp.SubType == CollectibleType.SOMETHINGWICKED_GOLDEN_CARD then
        --[[local rng = wisp:GetDropRNG()
        if rng:RandomFloat() < 0.5 then]]
            local player = wisp.Player
            local p_data = player:GetData()
            p_data.SomethingWickedPData.FortuneR_Stacks = (p_data.SomethingWickedPData.FortuneR_Stacks or 0) + 1
        --end
    end
end, EntityType.ENTITY_FAMILIAR)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_GOLDEN_CARD] = {
        desc = "Uses 1-2 random tarot cards#Cannot use teleport cards (except The Moon?), The Fool? The Lovers?, The Stars? or Wheel of Fortune?",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Uses 1-2 random tarot cards", 
        "Cannot use teleport cards (except The Moon?), The Fool? The Lovers?, The Stars? or Wheel of Fortune?"}),
        pools = { SomethingWicked.encyclopediaLootPools.POOL_SHOP, SomethingWicked.encyclopediaLootPools.POOL_SECRET, 
        SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP}
    }
}
return this