local this = {}

local ccabEnum = SomethingWicked.CustomCallbacks
this.CustomCallbacks = {
    [ccabEnum.SWCB_PICKUP_ITEM] = {
        UniversalPickupCallbacks = {},
        IDBasedPickupCallbacks = {}
    },
    [ccabEnum.SWCB_ON_ENEMY_HIT] = {},
    [ccabEnum.SWCB_ON_BOSS_ROOM_CLEARED] = {},
    [ccabEnum.SWCB_ON_LASER_FIRED] = {},
    [ccabEnum.SWCB_ON_FIRE_PURE] = {},
    [ccabEnum.SWCB_LUDO_TEAR_EVAL] = {}
}

function SomethingWicked:AddCustomCBack(type, funct, id)
    if type == ccabEnum.SWCB_PICKUP_ITEM then
        this:AddPickupFunction(funct, id)
        return
    end

    local cBackTable = this.CustomCallbacks[type]
    table.insert(cBackTable, funct)
end

--function takes a player argument and a room argument
function this:AddPickupFunction(func, id)
    id = id or -1

    if id == -1 then
        table.insert(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].UniversalPickupCallbacks, func)
        return
    end

    this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id] = this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id] or {}
    table.insert(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id], func)
end

--This is a **heavily** modified version of some of AgentCucco's code, shoutouts to her
function this:PickupMethod(player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.heldItem then
        if player:IsExtraAnimationFinished() then
            local room = SomethingWicked.game:GetRoom()
            for _, func in ipairs(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].UniversalPickupCallbacks) do
                func(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].UniversalPickupCallbacks, player, room)
            end  

            local id = p_data.SomethingWickedPData.heldItem
            if this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id] then        
                for _, func in ipairs(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id]) do
                    func(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id], player, room)
                end  
            end
            p_data.SomethingWickedPData.heldItem = nil 
        end
    else
        local targetItem = player.QueuedItem.Item
        if (not targetItem)
        or targetItem:IsCollectible() ~= true
        or player.QueuedItem.Touched == true
        then
            return
        end
        
        p_data.SomethingWickedPData.heldItem = targetItem.ID
    end
end

this.forgottenEsqueBones = {1, 2, 3, 4, 9}

function this:OnTearHit(tear, collider)
    local procCoefficient = 1
    local notSticking = true
    local t_data = tear:GetData()
    if tear.Type == EntityType.ENTITY_KNIFE then
        if SomethingWicked:UtilTableHasValue(this.forgottenEsqueBones, tear.Variant)
        and  tear:IsFlying() == false then
            return
        else
            procCoefficient = 0.1
        end
    else
        notSticking = tear.StickTarget == nil
    end

    local player = SomethingWicked:UtilGetPlayerFromTear(tear)

    if collider:IsVulnerableEnemy()
    and player and notSticking then
        this:CallOnhitCallback(tear, collider, player, procCoefficient)
    end
end

function this:CallOnhitCallback(tear, collider, player, procCoefficient)
    for _, v in pairs(this.CustomCallbacks[ccabEnum.SWCB_ON_ENEMY_HIT]) do
        v(this, tear, collider, player, procCoefficient)
    end
end

function this:OnEntityDMG(ent, amount, flags, source, dmgCooldown)
    if ent:IsVulnerableEnemy() ~= true then
        return
    end

    local player
    local entity = source.Entity
    if source.Type == EntityType.ENTITY_BOMB then
        entity = entity:ToBomb()
        player = SomethingWicked:UtilGetPlayerFromTear(entity)
    elseif (source.Type == EntityType.ENTITY_PLAYER and flags & DamageFlag.DAMAGE_LASER ~= 0) then
        entity = entity:ToPlayer()
        local mult = amount / entity.Damage
        this:CallOnhitCallback(entity, ent, entity, mult)
        return
    end

    if player then
        this:CallOnhitCallback(entity, ent, player, 1)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, this.OnTearHit)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, this.OnTearHit)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnEntityDMG)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PickupMethod)

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

function SomethingWicked:AddBoon(id)
    table.insert(SomethingWicked.BoonIDs, id)
end

SomethingWicked:AddCallback(ModCallbacks.MC_GET_CARD, this.BoonPreventCardSpawn)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.BoonOverrideHold)
SomethingWicked:AddCallback(ModCallbacks.MC_INPUT_ACTION, this.BoonCheckForHold)

this.onKillPos = nil
function this:OnKill(enemy)
        if enemy:IsBoss() then
            local room = SomethingWicked.game:GetRoom()
            local rType = room:GetType()
            if (rType == RoomType.ROOM_BOSS or rType == RoomType.ROOM_BOSSRUSH) then
                this.onKillPos = enemy.Position
        end
    end
end

function this:DelayShit()
    if this.onKillPos
    and Isaac.CountBosses() == 0 then
        local r = SomethingWicked.game:GetRoom()
        local isBossRush = r:GetType() == RoomType.ROOM_BOSSRUSH
        for _, value in pairs(this.CustomCallbacks[ccabEnum.SWCB_ON_BOSS_ROOM_CLEARED]) do
            value(this.CustomCallbacks[ccabEnum.SWCB_ON_BOSS_ROOM_CLEARED], this.onKillPos, isBossRush)
        end
        this.onKillPos = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.DelayShit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.OnKill)

function this:LaserUpdate(laser)
    if laser.FrameCount == 1 then
        if laser.Variant == SomethingWicked.LaserVariant.SHIT
        or laser.Variant == SomethingWicked.LaserVariant.TRACTOR_BEAM
        or laser.Variant == SomethingWicked.LaserVariant.DADS_RING then
            return
        end

        local player = SomethingWicked:UtilGetPlayerFromTear(laser)
        
        for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_ON_LASER_FIRED]) do
            callb(this.CustomCallbacks[ccabEnum.SWCB_ON_LASER_FIRED], laser, player)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, this.LaserUpdate)

function this:PostFirePureEval(player)
    if player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
        return
    end

    local p_data = player:GetData()
    p_data.somethingWicked_processedPureFire = p_data.somethingWicked_processedPureFire or false
    local sprite = player:GetSprite()
    if (sprite:GetOverlayFrame() == 2)
    or player.FireDelay >= player.MaxFireDelay then
        if not p_data.somethingWicked_processedPureFire
        or player.FireDelay >= player.MaxFireDelay then
            p_data.somethingWicked_processedPureFire = true

            for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_ON_FIRE_PURE]) do
                callb(this.CustomCallbacks[ccabEnum.SWCB_ON_FIRE_PURE], player, player:GetAimDirection())
            end
        end
    elseif p_data.somethingWicked_processedPureFire then
        p_data.somethingWicked_processedPureFire = false
    end
    --print(player:GetSprite():GetOverlayAnimation(), (player:GetSprite():GetOverlayFrame()))
    
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PostFirePureEval)