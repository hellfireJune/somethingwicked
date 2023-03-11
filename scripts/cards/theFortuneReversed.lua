local this = {}
Card.SOMETHINGWICKEDTHOTH_FORTUNE_REVERSED = Isaac.GetCardIdByName("FortuneReversed")
--[[SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.FortuneR_Stacks = (p_data.SomethingWickedPData.FortuneR_Stacks or 0) + 3
end, Card.SOMETHINGWICKEDTHOTH_FORTUNE_REVERSED)]]

this.EIDEntries = {}
return this