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
    [ccabEnum.SWCB_KNIFE_EFFECT_EVAL] = {}
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
    collider = collider:ToNPC()
    if not collider
    or not collider:IsVulnerableEnemy() then
        return
    end

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

function this:CallKnifeEvalCallback(tear, collider, player)
    local flag = true
    for _, v in pairs(this.CustomCallbacks[ccabEnum.SWCB_KNIFE_EFFECT_EVAL]) do
        local nflag = v(this, tear, collider, player)
        if nflag ~= nil then
            flag = flag and nflag
        end
    end

    return flag
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
    if source.Type == EntityType.ENTITY_KNIFE then
        return this:CallKnifeEvalCallback(entity, ent, player)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, this.OnTearHit)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, this.OnTearHit)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.OnEntityDMG)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PickupMethod)
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

local function knifeDebugFunc(knife)
    print(knife:GetData().isFunnyKnife, knife.Index, GetPtrHash(knife.Parent), knife.Parent.Type, GetPtrHash(knife.SpawnerEntity), knife.MaxHitPoints)
    print(knife.TargetPosition, knife.CollisionDamage, knife:Exists(), knife.Target, knife.Velocity, knife.Position, knife:GetEntityFlags(), knife.Child)
    print(knife:IsFlying(), knife.MaxDistance, knife.PathOffset, knife.PathFollowSpeed, knife:IsVisible())

    local sprite = knife:GetSprite()
    print(sprite:GetFrame(), sprite:GetAnimation())
end
    
local hasSpawnedClub = false
function this:PostFirePureEval(player)
    if player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) then
        return
    end
    if not hasSpawnedClub then
        hasSpawnedClub = true
        local knife = Isaac.Spawn(8, 0, 0, player.Position, Vector.Zero, player)
        knife.Parent = player
    end

    local p_data = player:GetData()
    p_data.somethingWicked_processedPureFire = p_data.somethingWicked_processedPureFire or false
    local sprite = player:GetSprite()
    local animflag = (sprite:GetOverlayFrame() == 2)
    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_LILITH then
        for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.INCUBUS)) do
            value = value:ToFamiliar()
            if value and GetPtrHash(value.Player) == GetPtrHash(player) then
                sprite = value:GetSprite()
                animflag = string.match(sprite:GetAnimation(), "Shoot")
            end
        end
    end
    --print(player.FireDelay)
    if animflag
    or player.FireDelay >= player.MaxFireDelay then
        if not p_data.somethingWicked_processedPureFire
        or player.FireDelay >= player.MaxFireDelay then
            p_data.somethingWicked_processedPureFire = true

            local boneClub = Isaac.Spawn(8, 1, 2, player.Position, Vector.Zero, player)
            boneClub.Parent = player
            local clubSprite = boneClub:GetSprite()
            clubSprite:Play("Swing", true)
            local repulsevector = Vector.Zero
            local repulseangle = repulsevector:GetAngleDegrees()
            local knife = player:FireKnife(boneClub, repulseangle, false, 4, 1)
            --knife:Shoot(0, 100)
            knife.Parent = player
            --knife:Shoot(50, 100)
            knife.Position = knife.Position + Vector(30, 0)
            --knife.Velocity = Vector(10, 0)
            knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
            knife.Mass = 30
            knife.MaxDistance = 100
            knife.Size = 32
            --cane.TearFlags = TearFlags.TEAR_KNOCKBACK | TearFlags.TEAR_PUNCH
            --knife:Update()
            knife.CollisionDamage = 5.25
            local canesprite = knife:GetSprite()
            canesprite:Play("Swing",true)
            knife.Rotation = repulseangle- 90
            knife.SpriteRotation = repulseangle- 90
            knife:Update()
            
            this:CallPureFireCallback(player, player:GetAimDirection(), 1)

            for index, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
                familiar = familiar:ToFamiliar()
                if familiar and GetPtrHash(familiar.Player) == GetPtrHash(player) then
                    if SomethingWicked.FamiliarHelpers:DoesFamiliarShootPlayerTears(familiar)
                    and not (familiar.Variant == FamiliarVariant.INCUBUS and playerType == PlayerType.PLAYER_LILITH) then
                        local scalar = this:GetFamiliarPureFireScalar(familiar, playerType)
                        this:CallPureFireCallback(familiar, familiar.ShootDirection, scalar)
                    end
                end
            end
        end

        

    elseif p_data.somethingWicked_processedPureFire then
        p_data.somethingWicked_processedPureFire = false
    end
    --print(player:GetSprite():GetOverlayAnimation(), (player:GetSprite():GetOverlayFrame()))
    
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_KNIFE_INIT, function (_, knife)
    knife.TargetPosition = Vector(4, 0)
    print("Initing Slash")
end, 4)

function this:GetFamiliarPureFireScalar(familiar, playertype)
    local variant = familiar.Variant
    if variant == FamiliarVariant.INCUBUS
    or variant == FamiliarVariant.UMBILICAL_BABY then
        return (playertype == PlayerType.PLAYER_LILITH or playertype == PlayerType.PLAYER_LILITH_B) and 1 or 0.75
    elseif familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION
    or familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION_B then
        return 0.175
    elseif familiar.Variant == FamiliarVariant.SPRINKLER then
        return 1
    end
    return 0.35
end

function this:CallPureFireCallback(player, direction, scalar)
    for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_ON_FIRE_PURE]) do
        callb(this.CustomCallbacks[ccabEnum.SWCB_ON_FIRE_PURE], player, direction, scalar)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function (_, knife)
    --knife.Position = knife.Position + Vector(40, 40)
    if knife.FrameCount == 1 then
        knifeDebugFunc(knife)
    end
end, 4)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, function (_, knife)
    local sprite = knife:GetSprite()
    --print(knife.SubType, knife.Variant)
        if (knife.SubType == 4 and knife.Variant == 1) then
            --print(knife.Parent.Type, knife.SpawnerEntity.Type, knife.CollisionDamage)
        elseif knife.Variant == 1 then
        end
    --sprite:RenderLayer(1, Isaac.WorldToScreen(knife.Position + Vector(40, 40)))
    if sprite:GetFrame() == 5 then
        --print(knife.Position)
    end
end) 


SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PostFirePureEval)