local mod = SomethingWicked
local game = Game()

local cType = mod.CustomCardTypes
mod.addedCards = {
    [cType.CARDTYPE_THOTH] = {
        [mod.CARDS.THOTH_ART] = 1,
        [mod.CARDS.THOTH_FORTUNE] = 1,
        [mod.CARDS.THOTH_LUST] = 1,
        [mod.CARDS.THOTH_THE_ADJUSTMENT] = 1,
        [mod.CARDS.THOTH_THE_AEON] = 1,
        [mod.CARDS.THOTH_THE_MAGUS] = 1,
    },
    [cType.CARDTYPE_THOTH_REVERSED] = {

    },
    [cType.CARDTYPE_FRENCH_PLAYING] = {
        [mod.CARDS.KNIGHT_OF_CLUBS] = 1,
        [mod.CARDS.KNIGHT_OF_HEARTS] = 1,
        [mod.CARDS.KNIGHT_OF_SPADES] = 1,
        [mod.CARDS.KNIGHT_OF_DIAMONDS] = 1,
    },
    [cType.CARDTYPE_RUNE_WICKEDMISC] = {
        [mod.CARDS.STONE_OF_THE_PIT] = 1
    }
}
local cardSpawnRules = {
    [cType.CARDTYPE_THOTH] = 0--[[.4]],
    [cType.CARDTYPE_THOTH_REVERSED] = 0.6,
    [cType.CARDTYPE_FRENCH_PLAYING] = 0.6,
    [cType.CARDTYPE_RUNE_WICKEDMISC] = 1,
}

local function getCardType(id)
    for key, value in pairs(mod.addedCards) do
        if value[id] then
            return key
        end
    end
end
local function isWickedCard(id, types)
    local skipW = false
    if types == nil then
        skipW = true
    end
    for key, value in pairs(mod.addedCards) do
        if value[id]
        and (skipW or mod:UtilTableHasValue(types, key)) then
            return true
        end
    end
    return false
end
function mod:DebugGetCardOdds(maxRuns)
    local c = {}
    for i = 1, maxRuns, 1 do
        local card = game:GetItemPool():GetCard(Random() + 1, true, true, false)
        if isWickedCard(card) then
            c[card] = (c[card] or 0) + 1
        end
    end
    for key, value in pairs(c) do
        print(key..": "..(value/(maxRuns/100)).."% chance of appearance")
    end
end
function mod:DebugGetSpecificCardOdds(id, maxRuns)
    local c = {}
    for i = 1, maxRuns, 1 do
        local card = game:GetItemPool():GetCard(Random() + 1, true, true, false)
        if id == card then
            c[card] = (c[card] or 0) + 1
        end
    end
    for key, value in pairs(c) do
        print(key..": "..(value/(maxRuns/100)).."% chance of appearance")
    end
end




local crashPreventer = 0
function mod:AlterCardSpawnRates(rng, card, getPlayingCards, getRunes, onlyRunes)
    crashPreventer = crashPreventer + 1
    if crashPreventer > 500 then
        crashPreventer = 0
        return
    end
    --[[if mod:UtilTableHasValue(mod.BoonIDs, card) then
        local nextCard = card
        nextCard = game:GetItemPool():GetCard(Random() + 1, getPlayingCards, getRunes, onlyRunes)

        return nextCard
    end]]

    local type = getCardType(card)
    if type then
        local weight = cardSpawnRules[type] * (mod.addedCards[type][card] or 1)
        local flaot = rng:RandomFloat()
        if flaot > weight then
            return game:GetItemPool():GetCard(Random() + 1, getPlayingCards, getRunes, onlyRunes)
        end
    end

    crashPreventer = 0
end
mod:AddCallback(ModCallbacks.MC_GET_CARD, mod.AlterCardSpawnRates)

-- Boons
mod.BoonIDs = {}
local function BoonCheckForHold(_, entity, input, action)
    if action == ButtonAction.ACTION_DROP and entity and entity:ToPlayer() then
        local player = entity:ToPlayer()
        local p_data = player:GetData()
        p_data.somethingWicked_DropButtonHoldcount = (p_data.somethingWicked_DropButtonHoldcount or 0)

        for _, value in ipairs(mod.BoonIDs) do
            if (player:GetCard(0) == value or player:GetCard(1) == value) and  
            p_data.somethingWicked_DropButtonHoldcount >= 60 then
                local roomPos = function ()
                    return game:GetRoom():FindFreePickupSpawnPosition(player.Position)
                end

                for i = 1, 2, 1 do
                    if (player:GetCard(i) and not mod:UtilTableHasValue(mod.BoonIDs, player:GetCard(i))) or player:GetPill(i) then
                        player:DropPocketItem(i, roomPos())
                    end
                end

                player:DropTrinket(roomPos(), false)
                if input == InputHook.IS_ACTION_PRESSED then
                    return false
                elseif input == InputHook.IS_ACTION_TRIGGERED then
                    return true
                elseif input == InputHook.GET_ACTION_VALUE then
                    return 0
                end
            end
        end
    end
end

local function BoonOverrideHold(_, player)
    local p_data = player:GetData()

    if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
        p_data.somethingWicked_DropButtonHoldcount = (p_data.somethingWicked_DropButtonHoldcount or 0) + 1
    else 
        p_data.somethingWicked_DropButtonHoldcount = 0
    end
end

local function PreventCardPickup(_, _, collider)
    collider = collider:ToPlayer()
    if collider and mod:UtilTableHasValue(mod.BoonIDs, collider:GetCard(0)) then
        return false
    end
end

local function PreventCardDropping(_, card)
    if mod:UtilTableHasValue(mod.BoonIDs, card.SubType)
    and card.SpawnerType == EntityType.ENTITY_PLAYER
    and card.SpawnerEntity ~= nil and card.SpawnerEntity:ToPlayer() ~= nil
    and card.FrameCount == 1 then
        local player = card.SpawnerEntity:ToPlayer()
        player:AddCard(card.SubType)
        card:Remove()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, PreventCardDropping, PickupVariant.PICKUP_TAROTCARD)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PreventCardPickup, PickupVariant.PICKUP_TAROTCARD)
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PreventCardPickup, PickupVariant.PICKUP_PILL)
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BoonOverrideHold)
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, BoonCheckForHold)

function mod:UseBoonCard(startID, targetID, player, useflags)
    if useflags & (UseFlag.USE_CARBATTERY | UseFlag.USE_MIMIC) ~= 0 then
        return
    end
    local slot = -1
    for i = 0, 1, 1 do
        if player:GetCard(i) == startID then
            slot = i
        end
    end

    if slot ~= -1 then
        player:SetCard(slot, targetID)
    end
end