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
}
local tpCards = { Card.CARD_FOOL, Card.CARD_HERMIT, Card.CARD_EMPEROR, Card.CARD_MOON, Card.CARD_STARS, Card.CARD_REVERSE_MOON }
local function randomCard(rng)
    local itempool = mod.game:GetItemPool()
    local card = -1

    local telechance = rng:RandomFloat()
    local room = mod.game:GetRoom() local type = room:GetType()
    local isValid = telechance < 0.2 and type ~= RoomType.ROOM_BOSS and type ~= RoomType.ROOM_BOSSRUSH

    local conf
    while mod:UtilTableHasValue(blacklist, card) or (mod:UtilTableHasValue(tpCards, card) and not isValid)
    or (not conf or conf.CardType ~= 0) do
        card = itempool:GetCard(Random() + 1, false, false, false)
        conf = Isaac.GetItemConfig():GetCard(card)
    end
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
    return (0.66*player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_BOOSTER_BOX)) - (roomDebt*0.064)
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
                local card = randomCard(c_rng)
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
        local rng = player:GetDropRNG()
        local card = randomCard(rng)
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

local string = "Cannot use The Fool? The Lovers?, The Stars? or Wheel of Fortune?#Teleport cards will only be rarely used, and cannot be drawn during boss fights"
this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_GOLDEN_CARD] = {
        desc = "Uses 1-2 random tarot cards#"..string,
        encycloDesc = mod:UtilGenerateWikiDesc({"Uses 1-2 random tarot cards", 
        string}),
        pools = { mod.encyclopediaLootPools.POOL_SHOP, mod.encyclopediaLootPools.POOL_SECRET, 
        mod.encyclopediaLootPools.POOL_GREED_SHOP}
    },
    [CollectibleType.SOMETHINGWICKED_BOOSTER_BOX] = {
        desc = "Killing an enemy has a chance to use a random tarot cards effect#Reduces the chance to use a card for the next 5 rooms on activation#"..string
    }
}
return this