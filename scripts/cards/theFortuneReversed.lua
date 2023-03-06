local this = {}
Card.SOMETHINGWICKEDTHOTH_FORTUNE_REVERSED = Isaac.GetCardIdByName("FortuneReversed")
--[[SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, function (_, _, player)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.FortuneR_Stacks = (p_data.SomethingWickedPData.FortuneR_Stacks or 0) + 3
end, Card.SOMETHINGWICKEDTHOTH_FORTUNE_REVERSED)]]
local blacklist = {
    -1,
    Card.CARD_REVERSE_WHEEL_OF_FORTUNE,
    Card.CARD_REVERSE_LOVERS,
    Card.CARD_REVERSE_FOOL, Card.CARD_REVERSE_STARS,

    Card.CARD_FOOL, Card.CARD_HERMIT, Card.CARD_EMPEROR, Card.CARD_MOON, Card.CARD_STARS
}

function this:PEffectUpdate(player)
    local p_data = player:GetData()

    if not player:IsExtraAnimationFinished() then
        return
    end
    p_data.SomethingWickedPData.FortuneR_Stacks = p_data.SomethingWickedPData.FortuneR_Stacks or 0
    if p_data.SomethingWickedPData.FortuneR_Stacks > 0
    and p_data.SomethingWickedPData.FortuneR_Card == nil then
        local itempool = SomethingWicked.game:GetItemPool()
        local card = -1
        while SomethingWicked:UtilTableHasValue(blacklist, card) do
            card = itempool:GetCard(Random() + 1, false, false, false)
        end
        player:AnimateCard(card, "UseItem")
        SomethingWicked.sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)

        local conf = Isaac.GetItemConfig():GetCard(card)
        local name = SomethingWicked.ItemHelpers.CardNamesProper[card] ~= nil
        and SomethingWicked.ItemHelpers.CardNamesProper[card] or conf.Name
        local desc = SomethingWicked.ItemHelpers.CardDescsProper[card] ~= nil
        and SomethingWicked.ItemHelpers.CardDescsProper[card] or conf.Description
        SomethingWicked.game:GetHUD():ShowItemText(name, desc)

        p_data.SomethingWickedPData.FortuneR_Card = card
        p_data.SomethingWickedPData.FortuneR_Stacks = p_data.SomethingWickedPData.FortuneR_Stacks - 1
    elseif p_data.SomethingWickedPData.FortuneR_Card then
        player:UseCard(p_data.SomethingWickedPData.FortuneR_Card, UseFlag.USE_NOANIM)
        p_data.SomethingWickedPData.FortuneR_Card = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)
this.EIDEntries = {}
return this