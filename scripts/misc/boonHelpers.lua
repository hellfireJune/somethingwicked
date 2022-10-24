local this = {}

-- Boons
SomethingWicked.BoonIDs = {}
function this:BoonCheckForHold(entity, input, action)
    if action == ButtonAction.ACTION_DROP and entity and entity:ToPlayer() then
        local player = entity:ToPlayer()
        local p_data = player:GetData()
        p_data.somethingWicked_DropButtonHoldcount = (p_data.somethingWicked_DropButtonHoldcount or 0)

        for _, value in ipairs(SomethingWicked.BoonIDs) do
            if (player:GetCard(0) == value or player:GetCard(1) == value) and  
            p_data.somethingWicked_DropButtonHoldcount >= 60 then
                local roomPos = function ()
                    return SomethingWicked.game:GetRoom():FindFreePickupSpawnPosition(player.Position);
                end

                for i = 1, 2, 1 do
                    if (player:GetCard(i) and not SomethingWicked:UtilTableHasValue(SomethingWicked.BoonIDs, player:GetCard(i))) or player:GetPill(i) then
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

function this:BoonOverrideHold(player)
    local p_data = player:GetData()

    if Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex) then
        p_data.somethingWicked_DropButtonHoldcount = (p_data.somethingWicked_DropButtonHoldcount or 0) + 1
    else 
        p_data.somethingWicked_DropButtonHoldcount = 0
    end
end


function this:BoonPreventCardSpawn(rng, card, getPlayingCards, getRunes, onlyRunes)
    if SomethingWicked:UtilTableHasValue(SomethingWicked.BoonIDs, card) then
        local crashPreventer = 0
        local nextCard = card
        while (SomethingWicked:UtilTableHasValue(SomethingWicked.BoonIDs, card) and (crashPreventer < 100)) do
            crashPreventer = crashPreventer + 1
            nextCard = SomethingWicked.game:GetItemPool():GetCard(Random() + 1, getPlayingCards, getRunes, onlyRunes)
        end

        return nextCard
    end
end

function this:PreventCardPickup(_, collider)
    collider = collider:ToPlayer()
    if collider and SomethingWicked:UtilTableHasValue(SomethingWicked.BoonIDs, collider:GetCard(0)) then
        return false
    end
end

function this:PreventCardDropping(card)
    if SomethingWicked:UtilTableHasValue(SomethingWicked.BoonIDs, card.SubType)
    and card.SpawnerType == EntityType.ENTITY_PLAYER
    and card.SpawnerEntity ~= nil and card.SpawnerEntity:ToPlayer() ~= nil
    and card.FrameCount == 1 then
        local player = card.SpawnerEntity:ToPlayer()
        player:AddCard(card.SubType)
        card:Remove()
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, this.PreventCardDropping, PickupVariant.PICKUP_TAROTCARD)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PreventCardPickup, PickupVariant.PICKUP_TAROTCARD)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PreventCardPickup, PickupVariant.PICKUP_PILL)
SomethingWicked:AddCallback(ModCallbacks.MC_GET_CARD, this.BoonPreventCardSpawn)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.BoonOverrideHold)
SomethingWicked:AddCallback(ModCallbacks.MC_INPUT_ACTION, this.BoonCheckForHold)

function SomethingWicked:AddBoon(id)
    table.insert(SomethingWicked.BoonIDs, id)
end

SomethingWicked.BoonHelpers = {}
function  SomethingWicked.BoonHelpers:UseBoonCard(startID, targetID, player, useflags)
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