local this = {}
local mod = SomethingWicked

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
    [ccabEnum.SWCB_KNIFE_EFFECT_EVAL] = {},
    [ccabEnum.SWCB_ON_MINIBOSS_ROOM_CLEARED] = {},
    [ccabEnum.SWCB_NEW_WAVE_SPAWNED] = {},
    [ccabEnum.SWCB_ON_ITEM_SHOULD_CHARGE] = {},
    [ccabEnum.SWCB_EVALUATE_DEVIL_CHANCE] = {},
}
FamiliarVariant.SOMETHINGWICKED_THE_CHECKER = Isaac.GetEntityVariantByName("[SW] room clear checker")

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
            local id = p_data.SomethingWickedPData.heldItem
            if player:HasCollectible(id) then
                local room = SomethingWicked.game:GetRoom()
                for _, func in ipairs(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].UniversalPickupCallbacks) do
                    func(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].UniversalPickupCallbacks, player, room, id)
                end  

                if this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id] then        
                    for _, func in ipairs(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id]) do
                        func(this.CustomCallbacks[ccabEnum.SWCB_PICKUP_ITEM].IDBasedPickupCallbacks[id], player, room, id)
                    end  
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
    if tear.Type == EntityType.ENTITY_KNIFE then
        if SomethingWicked:UtilTableHasValue(this.forgottenEsqueBones, tear.Variant)
        and  tear:IsFlying() == false then
            return
        else
            procCoefficient = 0.1
        end
    else
        local t_data = tear:GetData()
        t_data.sw_collideMap = t_data.sw_collideMap or {}
        if t_data.sw_collideMap[""..collider.InitSeed] then
            return
        end
        t_data.sw_collideMap[""..collider.InitSeed] = true

        local result = SomethingWicked:__callStatusEffects(collider, tear)
        if result ~= nil then
            return nil
        end
    end

    local player = SomethingWicked:UtilGetPlayerFromTear(tear)

    if collider:IsVulnerableEnemy() and player then
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
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, this.OnEntityDMG)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PickupMethod)
this.onKillPos = nil
function this:OnKill(enemy)
    local room = SomethingWicked.game:GetRoom()
    local rType = room:GetType()
    if enemy:IsBoss() and (rType == RoomType.ROOM_BOSS or rType == RoomType.ROOM_BOSSRUSH
     or rType == RoomType.ROOM_MINIBOSS) then
        this.onKillPos = enemy.Position
    end
end

function this:DelayShit()
    if this.onKillPos
    and Isaac.CountBosses() == 0 then
        local r = SomethingWicked.game:GetRoom()
        if r:GetType() == RoomType.ROOM_MINIBOSS then
            for _, value in pairs(this.CustomCallbacks[ccabEnum.SWCB_ON_MINIBOSS_ROOM_CLEARED]) do
                value(this.CustomCallbacks[ccabEnum.SWCB_ON_MINIBOSS_ROOM_CLEARED], this.onKillPos)
            end
        else
            local isBossRush = r:GetType() == RoomType.ROOM_BOSSRUSH
            for _, value in pairs(this.CustomCallbacks[ccabEnum.SWCB_ON_BOSS_ROOM_CLEARED]) do
                value(this.CustomCallbacks[ccabEnum.SWCB_ON_BOSS_ROOM_CLEARED], this.onKillPos, isBossRush)
            end
        end
        this.onKillPos = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.DelayShit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.OnKill)

local brim = {
    LaserVariant.THICK_RED, LaserVariant.BRIM_TECH, LaserVariant.THICKER_RED, LaserVariant.THICKER_BRIM_TECH, }
function this:LaserUpdate(laser)
    if (not mod:UtilTableHasValue(brim) and laser.FrameCount == 1) or
    laser.FrameCount % 4 == 2 then
        if laser.Variant == LaserVariant.THICK_BROWN
        or laser.Variant == LaserVariant.TRACTOR_BEAM
        or laser.Variant == LaserVariant.LIGHT_RING then
            return
        end

        local player = SomethingWicked:UtilGetPlayerFromTear(laser)
        
        for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_ON_LASER_FIRED]) do
            callb(this.CustomCallbacks[ccabEnum.SWCB_ON_LASER_FIRED], laser, player, laser.FrameCount <= 2)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, this.LaserUpdate)
    
function this:PostFirePureEval(player)
    local p_data = player:GetData()
    p_data.somethingWicked_processedPureFire = p_data.somethingWicked_processedPureFire or false
    p_data.sw_processFireDelay = p_data.sw_processFireDelay or false
    local sprite = player:GetSprite()
    local animflag = (sprite:GetOverlayFrame() == 2)
    local playerType = player:GetPlayerType()
    if playerType == PlayerType.PLAYER_LILITH then
        for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.INCUBUS)) do
            value = value:ToFamiliar()
            if value and GetPtrHash(value.Player) == GetPtrHash(player) then
                sprite = value:GetSprite()
                animflag = string.match(sprite:GetAnimation(), "Shoot")
                if value.ShootDirection ~= Direction.NO_DIRECTION then
                    p_data.somethingWicked_lastAimedDirection = SomethingWicked.HoldItemHelpers:AimToVector(value.ShootDirection)
                end
                break
            end
        end
    else
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            
        end
        if player:GetFireDirection() ~= Direction.NO_DIRECTION then
            p_data.somethingWicked_lastAimedDirection = SomethingWicked.HoldItemHelpers:AimToVector(player:GetFireDirection())
        end
    end
    --print(player.FireDelay)
    if player.FireDelay < 0 then
        p_data.sw_lastNegativeFireDelay = player.FireDelay
    end

    local fireDelayFlag = math.ceil(player.FireDelay - p_data.sw_lastNegativeFireDelay) >= (player.MaxFireDelay) and not p_data.sw_processFireDelay
    if animflag or fireDelayFlag then
        if not p_data.somethingWicked_processedPureFire or fireDelayFlag then
            p_data.somethingWicked_processedPureFire = true
            this:CallPureFireCallback(player, p_data.somethingWicked_lastAimedDirection, 1, player)
            p_data.sw_lastNegativeFireDelay = 0

            for index, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
                familiar = familiar:ToFamiliar()
                if familiar and GetPtrHash(familiar.Player) == GetPtrHash(player) then
                    if SomethingWicked.FamiliarHelpers:DoesFamiliarShootPlayerTears(familiar)
                    and not (familiar.Variant == FamiliarVariant.INCUBUS and playerType == PlayerType.PLAYER_LILITH) then
                        local scalar = this:GetFamiliarPureFireScalar(familiar, playerType)
                        this:CallPureFireCallback(familiar, p_data.somethingWicked_lastAimedDirection, scalar, player)
                    end
                end
            end
        end
        if fireDelayFlag then
            p_data.sw_processFireDelay = true
        end
    elseif p_data.somethingWicked_processedPureFire then
        p_data.somethingWicked_processedPureFire = false
    end

    if player.FireDelay < player.MaxFireDelay or player.MaxFireDelay - 1 < 0 then
        p_data.sw_processFireDelay = false
    end
    --print(player:GetSprite():GetOverlayAnimation(), (player:GetSprite():GetOverlayFrame()))
    
end

function SomethingWicked:DebugPostPureFireCallback()
    local player = Isaac.GetPlayer(1)
    local p_data = player:GetData()
    this:CallPureFireCallback(player, p_data.somethingWicked_lastAimedDirection, 1, player)
end

function this:GetFamiliarPureFireScalar(familiar, playertype)
    local variant = familiar.Variant
    if variant == FamiliarVariant.INCUBUS
    or variant == FamiliarVariant.UMBILICAL_BABY then
        return (playertype == PlayerType.PLAYER_LILITH or playertype == PlayerType.PLAYER_LILITH_B) and 1 or 0.75
    elseif familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION
    or familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION_B then
        return 0.175
    end
    return 0.35
end

function this:CallPureFireCallback(shooter, direction, scalar, player)
    for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_ON_FIRE_PURE]) do
        callb(this.CustomCallbacks[ccabEnum.SWCB_ON_FIRE_PURE], shooter, direction, scalar, player)
    end
end


SomethingWicked:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.IMPORTANT, this.PostFirePureEval)

--new wave/on item charge
local queueNewWaveCheck = false
function this:CheckTheChecker(familiar)
    familiar.Velocity = Vector(-400, -400)
    if familiar.RoomClearCount > 0 then
        queueNewWaveCheck = true
        for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_ON_ITEM_SHOULD_CHARGE]) do
            callb(this.CustomCallbacks[ccabEnum.SWCB_ON_ITEM_SHOULD_CHARGE], familiar.RoomClearCount)
        end
        familiar.RoomClearCount = 0
    end
end

function this:NewWaveOnChargeGameUpdate()
    if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_THE_CHECKER) == 0 then
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_THE_CHECKER, 0, Vector(0, 0), Vector(0, 0), nil)
    end

    local r = SomethingWicked.game:GetRoom()
    if queueNewWaveCheck and
     ((Isaac.CountEnemies() > 0 and r:GetType() ~= RoomType.ROOM_BOSSRUSH) or Isaac.CountBosses() > 0)
    then
        queueNewWaveCheck = false
        for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_NEW_WAVE_SPAWNED]) do
            callb(this.CustomCallbacks[ccabEnum.SWCB_NEW_WAVE_SPAWNED])
        end
    end
end

function SomethingWicked:UtilGetFireVector(vector, player)
    return (vector * (player.ShotSpeed * 10) + player.Velocity):Resized(player.ShotSpeed * 10) 
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    queueNewWaveCheck = false
end)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.NewWaveOnChargeGameUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.CheckTheChecker, FamiliarVariant.SOMETHINGWICKED_THE_CHECKER)


--Devil deal chance
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
    local p_data = player:GetData()
    p_data.sw_ddChance = 0    
    for _, callb in ipairs(this.CustomCallbacks[ccabEnum.SWCB_EVALUATE_DEVIL_CHANCE]) do
        callb(_, player, p_data)
    end
	local amount = p_data.sw_ddChance

    local data = this:GetDevilData(player)
    local wispRefs = this:GetDevilWispRefs()
    local currWisps = 0
    for i, _ in pairs(data) do
        if wispRefs[i] then
            currWisps = currWisps + 1
        end
    end
    if amount ~= currWisps then
    end

	this:SetDevilWisps(player, amount - currWisps)
end)

-- the below code is some rewritten TT stuff (except its not actually TT stuff and its fiendfolio stuff, thanks connor fiendfolio)

-- okay so i probably shouldnt include this but idk, its good for attaching wisp to player
function this:GetDevilData(player)
	local data = player:GetData()
    data.SomethingWickedPData.devilWisps = data.SomethingWickedPData.devilWisps or {}
	return data.SomethingWickedPData.devilWisps
end
function this:GetDevilWispRefs()
	if not SomethingWicked.save.runData.devilWisps then
		SomethingWicked.save.runData.devilWisps = {}
	end
	return SomethingWicked.save.runData.devilWisps
end

function this:InitializeDevilWisp(wisp)
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	wisp.Visible = false
	wisp:RemoveFromOrbit()
	wisp:GetData().sw_devilDealWisp = true
end
function this:SetDevilWisps(player, amount)
	amount = amount or 1
	local wispRefs = this:GetDevilWispRefs()
    local data = this:GetDevilData(player)
	
	if amount < 0 then
		this:RemoveDevilWisp(player, -amount)
	else
		-- Add the hidden item wisp.
		for i = 1, amount do
			local wisp = player:AddWisp(CollectibleType.COLLECTIBLE_SATANIC_BIBLE, player.Position)
			this:InitializeDevilWisp(wisp)
			wispRefs[""..wisp.InitSeed] = true
			this:devilWispUpdate(wisp)
			data[""..wisp.InitSeed] = true
		end
	end
end

function this:RemoveDevilWisp(player, amount)
	amount = amount or 1
	local wispRefs = this:GetDevilWispRefs()
    local data = this:GetDevilData(player)
	
	for i, wisp in pairs(data) do
        data[i] = nil
        wispRefs[i] = nil
		amount = amount - 1
		if amount <= 0 then
            return
		end
	end
end

local suppressWispDeathEffects = false
function this:discEffectInit(eff)
	if suppressWispDeathEffects then
		eff:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, this.discEffectInit, EffectVariant.TEAR_POOF_A)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, this.discEffectInit, EffectVariant.POOF01)

function this:discItemWispInit(wisp)
	if not wisp:GetData().sw_devilDealWisp and (this:GetDevilWispRefs()[""..wisp.InitSeed]) then
		-- This wisp isn't marked as a disc wisp, but there's supposed to be a disc wisp with this InitSeed.
		-- Most likely, we've quit and continued a run. Re-initialize this as a disc wisp and hide it.
		mod:InitializeDevilWisp(wisp)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.discItemWispInit, FamiliarVariant.WISP)

function this:devilWispUpdate(wisp)
	local data = wisp:GetData()
	
	if not data.sw_devilDealWisp then return end
	wisp.Position = Vector(-100, -50)
	wisp.Velocity = Vector.Zero
	if not this:GetDevilWispRefs()[""..wisp.InitSeed] then
		-- This disc wisp should no longer exist.
		suppressWispDeathEffects = true
		wisp:Kill()
		suppressWispDeathEffects = false
		mod.sfx:Stop(SoundEffect.SOUND_STEAM_HALFSEC)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.devilWispUpdate, FamiliarVariant.WISP)

function this:discItemWispCollision(wisp)
	if wisp:GetData().sw_devilDealWisp then
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, this.discItemWispCollision, FamiliarVariant.WISP)

function this:discItemWispDamage(entity, _, _, damageSourceRef)
	if entity and entity:GetData().sw_devilDealWisp then
		return false
	end
	
	if damageSourceRef.Entity and damageSourceRef.Entity:GetData().sw_devilDealWisp then
		return false
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, this.discItemWispDamage)

function this:discItemWispTears(tear)
    local spawner = tear.SpawnerEntity
	if spawner and spawner:GetData().sw_devilDealWisp then
		tear:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.discItemWispTears)


--sac altar fix made by deadinfinity, for fiendfolio
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, -1, false, false)) do
        if wisp:GetData().sw_devilDealWisp then
            local fam = wisp:ToFamiliar()
            wisp:GetData().sw_devilDealWispPlayer = fam.Player
            fam.Player = nil
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, -1, false, false)) do
        if wisp:GetData().sw_devilDealWisp then
            local player = wisp:GetData().sw_devilDealWispPlayer
            if player then
                wisp:ToFamiliar().Player = player
            end

            wisp:GetData().sw_devilDealWispPlayer = nil
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)