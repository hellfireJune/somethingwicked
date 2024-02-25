local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local function UseItem(_, _, rng, player)
    local p_data = player:GetData()
    local stacks = 1 + rng:RandomInt(2)
    p_data.WickedPData.FortuneR_Stacks = (p_data.WickedPData.FortuneR_Stacks or 0) + stacks
end

local blacklist = {
    -1,
    Card.CARD_REVERSE_WHEEL_OF_FORTUNE,
    Card.CARD_REVERSE_LOVERS,
    Card.CARD_REVERSE_FOOL, Card.CARD_REVERSE_STARS,
}
local tpCards = { Card.CARD_FOOL, Card.CARD_HERMIT, Card.CARD_EMPEROR, Card.CARD_MOON, Card.CARD_STARS, Card.CARD_REVERSE_MOON }
local function randomCard(rng)
    local itempool = game:GetItemPool()
    local card = -1

    local telechance = rng:RandomFloat()
    local room = game:GetRoom() local type = room:GetType()
    local isValid = telechance < 0.2 and type ~= RoomType.ROOM_BOSS and type ~= RoomType.ROOM_BOSSRUSH

    local conf
    while mod:UtilTableHasValue(blacklist, card) or (mod:UtilTableHasValue(tpCards, card) and not isValid)
    or (not conf or conf.CardType ~= 0) do
        card = itempool:GetCard(Random() + 1, false, false, false)
        conf = Isaac.GetItemConfig():GetCard(card)
    end
    local name = mod.CardNamesProper[card] ~= nil
    and mod.CardNamesProper[card] or conf.Name
    local desc = mod.CardDescsProper[card] ~= nil
    and mod.CardDescsProper[card] or conf.Description
    game:GetHUD():ShowItemText(name, desc)
    return card, desc
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.GOLDEN_CARD)

local debt = 5
local function procChance(player)
    local roomDebt = player:GetData().WickedPData.bBoxRoomDebt or 0
    return (0.66*player:GetCollectibleNum(mod.ITEMS.BOOSTER_BOX)) - (roomDebt*0.064)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, ent)
    local wisp = ent:ToFamiliar()
    if wisp and wisp.Variant == FamiliarVariant.WISP and wisp.SubType == mod.ITEMS.GOLDEN_CARD then
        --[[local rng = wisp:GetDropRNG()
        if rng:RandomFloat() < 0.5 then]]
            local player = wisp.Player
            local p_data = player:GetData()
            p_data.WickedPData.FortuneR_Stacks = (p_data.WickedPData.FortuneR_Stacks or 0) + 1
        --end
        return
    end

    if ent:IsEnemy() then
        for _, player in ipairs(mod:AllPlayersWithCollectible(mod.ITEMS.BOOSTER_BOX)) do
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.BOOSTER_BOX)
            --print(procChance(player))
            if c_rng:RandomFloat() < procChance(player) then
                local card = randomCard(c_rng)
                player:UseCard(card, UseFlag.USE_NOANIM)

                local p_data = player:GetData()
                p_data.WickedPData.bBoxRoomDebt = (p_data.WickedPData.bBoxRoomDebt or 0) + debt
            end
        end
    end
end)

local function PEffectUpdate(_, player)
    local p_data = player:GetData()

    if not player:IsExtraAnimationFinished() then
        return
    end
    p_data.WickedPData.FortuneR_Stacks = p_data.WickedPData.FortuneR_Stacks or 0
    if p_data.WickedPData.FortuneR_Stacks > 0
    and p_data.WickedPData.FortuneR_Card == nil then
        local rng = player:GetDropRNG()
        local card = randomCard(rng)
        player:AnimateCard(card, "UseItem")
        sfx:Play(SoundEffect.SOUND_SHELLGAME, 1, 0)
        p_data.WickedPData.FortuneR_Card = card
        p_data.WickedPData.FortuneR_Stacks = p_data.WickedPData.FortuneR_Stacks - 1
    elseif p_data.WickedPData.FortuneR_Card then
        player:UseCard(p_data.WickedPData.FortuneR_Card, UseFlag.USE_NOANIM)
        p_data.WickedPData.FortuneR_Card = nil
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PEffectUpdate)

local function OnDMG(_, ent)
    ent = ent:ToPlayer()
    if not ent or not ent:HasTrinket(mod.TRINKETS.CARD_GRAVEYARD) then
        return
    end

    local t_rng = ent:GetTrinketRNG(mod.TRINKETS.CARD_GRAVEYARD)
    if t_rng:RandomFloat() < 0.2*math.max(1, ent:GetTrinketMultiplier(mod.TRINKETS.CARD_GRAVEYARD)) then
        local p_data = ent:GetData()
        p_data.WickedPData.FortuneR_Stacks = (p_data.WickedPData.FortuneR_Stacks or 0)+1
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, OnDMG)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, function ()
    for index, player in ipairs(mod:UtilGetAllPlayers()) do
        if player:GetData().WickedPData.bBoxRoomDebt then
            player:GetData().WickedPData.bBoxRoomDebt = math.max(player:GetData().WickedPData.bBoxRoomDebt-1, 0)
        end
    end
end)