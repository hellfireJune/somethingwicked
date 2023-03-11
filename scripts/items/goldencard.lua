local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_GOLDEN_CARD = Isaac.GetItemIdByName("Golden Card")
CollectibleType.SOMETHINGWICKED_BOOSTER_BOX = Isaac.GetItemIdByName("Booster Box")

function this:UseItem(_, rng, player)
    local p_data = player:GetData()
    local stacks = 1 + rng:RandomInt(2)
    p_data.SomethingWickedPData.FortuneR_Stacks = (p_data.SomethingWickedPData.FortuneR_Stacks or 0) + stacks
end

local blacklist = {
    -1,
    Card.CARD_REVERSE_WHEEL_OF_FORTUNE,
    Card.CARD_REVERSE_LOVERS,
    Card.CARD_REVERSE_FOOL, Card.CARD_REVERSE_STARS,

    Card.CARD_FOOL, Card.CARD_HERMIT, Card.CARD_EMPEROR, Card.CARD_MOON, Card.CARD_STARS
}
local function randomCard()
    local itempool = mod.game:GetItemPool()
    local card = -1
    while mod:UtilTableHasValue(blacklist, card) do
        card = itempool:GetCard(Random() + 1, false, false, false)
    end
    local conf = Isaac.GetItemConfig():GetCard(card)
    local name = mod.ItemHelpers.CardNamesProper[card] ~= nil
    and mod.ItemHelpers.CardNamesProper[card] or conf.Name
    local desc = mod.ItemHelpers.CardDescsProper[card] ~= nil
    and mod.ItemHelpers.CardDescsProper[card] or conf.Description
    mod.game:GetHUD():ShowItemText(name, desc)
    return card, desc
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_GOLDEN_CARD)

local debt = 5
local function procChance(player)
    local roomDebt = player:GetData().SomethingWickedPData.bBoxRoomDebt or 0
    --print(roomDebt)
    roomDebt = roomDebt/debt
    return 0.66 - (math.ceil(roomDebt)*0.3225)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, ent)
    local wisp = ent:ToFamiliar()
    if wisp and wisp.Variant == FamiliarVariant.WISP and wisp.SubType == CollectibleType.SOMETHINGWICKED_GOLDEN_CARD then
        --[[local rng = wisp:GetDropRNG()
        if rng:RandomFloat() < 0.5 then]]
            local player = wisp.Player
            local p_data = player:GetData()
            p_data.SomethingWickedPData.FortuneR_Stacks = (p_data.SomethingWickedPData.FortuneR_Stacks or 0) + 1
        --end
        return
    end

    if ent:IsEnemy() then
        for _, player in ipairs(mod.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_BOOSTER_BOX)) do
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BOOSTER_BOX)
            --print(procChance(player))
            if c_rng:RandomFloat() < procChance(player) then
                local card = randomCard()
                player:UseCard(card, UseFlag.USE_NOANIM)

                local p_data = player:GetData()
                p_data.SomethingWickedPData.bBoxRoomDebt = (p_data.SomethingWickedPData.bBoxRoomDebt or 0) + debt
            end
        end
    end
end)

function this:PEffectUpdate(player)
    local p_data = player:GetData()

    if not player:IsExtraAnimationFinished() then
        return
    end
    p_data.SomethingWickedPData.FortuneR_Stacks = p_data.SomethingWickedPData.FortuneR_Stacks or 0
    if p_data.SomethingWickedPData.FortuneR_Stacks > 0
    and p_data.SomethingWickedPData.FortuneR_Card == nil then
        local card = randomCard()
        player:AnimateCard(card, "UseItem")
        mod.sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)
        p_data.SomethingWickedPData.FortuneR_Card = card
        p_data.SomethingWickedPData.FortuneR_Stacks = p_data.SomethingWickedPData.FortuneR_Stacks - 1
    elseif p_data.SomethingWickedPData.FortuneR_Card then
        player:UseCard(p_data.SomethingWickedPData.FortuneR_Card, UseFlag.USE_NOANIM)
        p_data.SomethingWickedPData.FortuneR_Card = nil
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, function ()
    for index, player in ipairs(mod:UtilGetAllPlayers()) do
        if player:GetData().SomethingWickedPData.bBoxRoomDebt then
            player:GetData().SomethingWickedPData.bBoxRoomDebt = math.max(player:GetData().SomethingWickedPData.bBoxRoomDebt-1, 0)
        end
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_GOLDEN_CARD] = {
        desc = "Uses 1-2 random tarot cards#Cannot use teleport cards (except The Moon?), The Fool? The Lovers?, The Stars? or Wheel of Fortune?",
        encycloDesc = mod:UtilGenerateWikiDesc({"Uses 1-2 random tarot cards", 
        "Cannot use teleport cards (except The Moon?), The Fool? The Lovers?, The Stars? or Wheel of Fortune?"}),
        pools = { mod.encyclopediaLootPools.POOL_SHOP, mod.encyclopediaLootPools.POOL_SECRET, 
        mod.encyclopediaLootPools.POOL_GREED_SHOP}
    }
}
return this