local this = {}
CollectibleType.SOMETHINGWICKED_GOLDEN_CARD = Isaac.GetItemIdByName("Golden Card")

function this:UseItem(_, rng, player)
    local p_data = player:GetData()
    local stacks = 1 + rng:RandomInt(2)
    p_data.SomethingWickedPData.FortuneR_Stacks = (p_data.SomethingWickedPData.FortuneR_Stacks or 0) + stacks
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_GOLDEN_CARD)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_GOLDEN_CARD] = {
        desc = "Uses 1-2 random tarot cards"
    }
}
return this