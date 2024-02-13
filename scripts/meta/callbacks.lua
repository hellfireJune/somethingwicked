local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local ccabEnum = mod.CustomCallbacks
mod.__callbacks = {
    [ccabEnum.SWCB_ON_ENEMY_HIT] = {},
    [ccabEnum.SWCB_ON_BOSS_ROOM_CLEARED] = {},
    [ccabEnum.SWCB_ON_LASER_FIRED] = {},
    [ccabEnum.SWCB_PRE_PURCHASE_PICKUP] = {},
    [ccabEnum.SWCB_NEW_WAVE_SPAWNED] = {},
    [ccabEnum.SWCB_ON_ITEM_SHOULD_CHARGE] = {},
    [ccabEnum.SWCB_EVALUATE_TEMP_WISPS] = {},
    [ccabEnum.SWCB_ON_NPC_EFFECT_TICK] = {},
    [ccabEnum.SWCB_ON_FIRE_PURE] = {},
}

function mod:AddCustomCBack(type, funct, id)
    if type == ccabEnum.SWCB_PICKUP_ITEM or type == ccabEnum.SWCB_POST_PURCHASE_PICKUP then
        print("Something is trying to add a callback obsolete with repentogon. Callback Type:", type)
        return
    end

    --[[if type == ccabEnum.SWCB_PICKUP_ITEM then
        id = id or -1
    
        mod.__callbacks[ccabEnum.SWCB_PICKUP_ITEM][id] = mod.__callbacks[ccabEnum.SWCB_PICKUP_ITEM][id] or {}
        table.insert(mod.__callbacks[ccabEnum.SWCB_PICKUP_ITEM][id], funct)
        return
    end]]

    local cBackTable = mod.__callbacks[type]
    table.insert(cBackTable, funct)
end

function mod:CallCustomCback(t, arg1, arg2, arg3, arg4, subtype)
    local callbacks = mod.__callbacks[t]
    if t == ccabEnum.SWCB_PICKUP_ITEM then
        subtype = subtype or -1
        callbacks = callbacks[subtype]
        if subtype ~= -1 then
            mod:CallCustomCback(ccabEnum.SWCB_PICKUP_ITEM, arg1, arg2, arg3, arg4, -1)
        end
    end
    if callbacks == nil then
        return
    end
    local returnValue = nil
    for _, v in pairs(callbacks) do
        local val = v(callbacks, arg1, arg2, arg3, arg4)
        if returnValue == nil then
            returnValue = val
        else
            if type(val) == "boolean" then
                returnValue = val or returnValue
            end
        end
    end
    return returnValue
end


--This is a **heavily** modified version of some of AgentCucco's code, shoutouts to her
local function CheckForPickup(_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.heldItem then
        if player:IsExtraAnimationFinished() then
            local id = p_data.SomethingWickedPData.heldItem
            if player:HasCollectible(id) then
                local room = game:GetRoom()
                mod:CallCustomCback(ccabEnum.SWCB_PICKUP_ITEM, player, room, id, nil, id)
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
--mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CheckForPickup)

local forgottenEsqueBones = {1, 2, 3, 4, 9}

local function OnTearHit(_, tear, collider)
    collider = collider:ToNPC()
    if not collider
    or not collider:IsVulnerableEnemy() then
        return
    end

    local procCoefficient = 1
    if tear.Type == EntityType.ENTITY_KNIFE then
        if SomethingWicked:UtilTableHasValue(forgottenEsqueBones, tear.Variant)
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

        SomethingWicked:__callStatusEffects(collider, tear)
        --[[local result = SomethingWicked:__callStatusEffects(collider, tear)
        if result ~= nil then
            return result
        end]]
    end

    local player = mod:UtilGetPlayerFromTear(tear)

    if collider:IsVulnerableEnemy() and player then
        mod:CallCustomCback(ccabEnum.SWCB_ON_ENEMY_HIT, tear, collider, player, procCoefficient)
    end
end

local function OnEntityDMG(_, ent, amount, flags, source, dmgCooldown)
    if ent:IsVulnerableEnemy() ~= true then
        return
    end

    local player
    local entity = source.Entity
    if source.Type == EntityType.ENTITY_BOMB then
        player = mod:UtilGetPlayerFromTear(entity)
    elseif (source.Type == EntityType.ENTITY_PLAYER and flags & DamageFlag.DAMAGE_LASER ~= 0) then
        entity = entity:ToPlayer()
        local mult = amount / entity.Damage
        mod:CallCustomCback(ccabEnum.SWCB_ON_ENEMY_HIT, entity, ent, entity, mult)
        return
    end

    if player then
        mod:CallCustomCback(ccabEnum.SWCB_ON_ENEMY_HIT, entity, ent, player, 1)
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, OnTearHit)
mod:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, OnTearHit)
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.LATE, OnEntityDMG)
local function CheckForBossDeath(_, enemy)
    local room = game:GetRoom()
    local rType = room:GetType()
    if enemy:IsBoss() and (rType == RoomType.ROOM_BOSS or rType == RoomType.ROOM_BOSSRUSH
     or rType == RoomType.ROOM_MINIBOSS) then
        local onKillPos = enemy.Position
        mod:UtilScheduleForUpdate(function ()
            if Isaac.CountBosses() > 0 then
                return
            end

            mod:CallCustomCback(ccabEnum.SWCB_ON_BOSS_ROOM_CLEARED, onKillPos, rType)
        end, 0, ModCallbacks.MC_POST_UPDATE)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, CheckForBossDeath)

local brim = {
    LaserVariant.THICK_RED, LaserVariant.BRIM_TECH, LaserVariant.THICKER_RED, LaserVariant.THICKER_BRIM_TECH, }
local function LaserUpdate(_, laser)
    if not mod:UtilTableHasValue(brim) then
        return
    end
    if laser.FrameCount % 4 == 1 then
        local player = mod:UtilGetPlayerFromTear(laser)
        
        mod:CallCustomCback(ccabEnum.SWCB_ON_LASER_FIRED, laser, player, laser.FrameCount <= 2)
    end
end

local function laserInit(_, laser)
    if laser.Variant == LaserVariant.THIN_RED then
        local foes = Isaac.FindInRadius(laser.Position, 01, EntityPartition.ENTITY_FAMILIAR)
        for key, value in pairs(foes) do
            if value.Type == 3 and value.Variant == FamiliarVariant.FINGER then
                return
            end
        end
        
        local player = mod:UtilGetPlayerFromTear(laser)
        mod:CallCustomCback(ccabEnum.SWCB_ON_LASER_FIRED, laser, player, true)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, LaserUpdate)
mod:AddCallback(ModCallbacks.MC_POST_LASER_INIT, laserInit)
    


mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, function (_, vector, amount, owner)
    local p = owner:ToPlayer()
    local scalar = 1
    if p == nil then
        local f = owner:ToFamiliar()
        if f and f.Player then
            p = f.Player
        end

        if p then
            scalar = mod:GetFamiliarPureFireScalar(f, p:GetPlayerType())
        end
    end

    mod:CallCustomCback(ccabEnum.SWCB_ON_FIRE_PURE, owner, vector, scalar, p)
end)
--my favourite part of repentogon is having to comment out a hard day's of work plus more because its now obsolete :haha:
--[[local function PostFirePureEval(_, player)
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
                    p_data.somethingWicked_lastAimedDirection = mod:DirectionToVector(value.ShootDirection)
                end
                break
            end
        end
    else
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
            
        end
        if player:GetFireDirection() ~= Direction.NO_DIRECTION then
            p_data.somethingWicked_lastAimedDirection = mod:DirectionToVector(player:GetFireDirection())
        end
    end
    if player.FireDelay < 0 then
        p_data.sw_lastNegativeFireDelay = player.FireDelay
    end

    local fireDelayFlag = math.ceil(player.FireDelay - p_data.sw_lastNegativeFireDelay) >= (player.MaxFireDelay) and not p_data.sw_processFireDelay
    if animflag or fireDelayFlag then
        if not p_data.somethingWicked_processedPureFire or fireDelayFlag then
            print("abywgere:()")
            p_data.somethingWicked_processedPureFire = true
            mod:CallCustomCback(ccabEnum., player, p_data.somethingWicked_lastAimedDirection, 1, player)
            p_data.sw_lastNegativeFireDelay = 0

            for index, familiar in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
                familiar = familiar:ToFamiliar()
                if familiar and GetPtrHash(familiar.Player) == GetPtrHash(player) then
                    if mod:DoesFamiliarShootPlayerTears(familiar)
                    and not (familiar.Variant == FamiliarVariant.INCUBUS and playerType == PlayerType.PLAYER_LILITH) then
                        local scalar = mod:GetFamiliarPureFireScalar(familiar, playerType)
                        mod:CallCustomCback(ccabEnum., familiar, p_data.somethingWicked_lastAimedDirection, scalar, player)
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

function mod:DebugPostPureFireCallback()
    local player = Isaac.GetPlayer(1)
    local p_data = player:GetData()
    mod:CallCustomCback(ccabEnum., player, p_data.somethingWicked_lastAimedDirection, 1, player)
end]]

function mod:GetFamiliarPureFireScalar(familiar, playertype)
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

--[[SomethingWicked:AddPriorityCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CallbackPriority.IMPORTANT, PostFirePureEval)]]

--new wave/on item charge
local queueNewWaveCheck = false
local function CheckTheChecker(_, familiar)
    familiar.Velocity = Vector(-400, -400)
    if familiar.RoomClearCount > 0 then
        queueNewWaveCheck = true
        mod:CallCustomCback(ccabEnum.SWCB_ON_ITEM_SHOULD_CHARGE, familiar.RoomClearCount)
        familiar.RoomClearCount = 0
    end
end

function mod:NewWaveOnChargeGameUpdate()
    if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_THE_CHECKER) == 0 then
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_THE_CHECKER, 0, Vector(0, 0), Vector(0, 0), nil)
    end

    local r = game:GetRoom()
    if queueNewWaveCheck and
     ((Isaac.CountEnemies() > 0 and r:GetType() ~= RoomType.ROOM_BOSSRUSH) or Isaac.CountBosses() > 0)
    then
        queueNewWaveCheck = false
        mod:CallCustomCback(ccabEnum.SWCB_NEW_WAVE_SPAWNED)
    end
end

function mod:UtilGetFireVector(vector, player)
    return (vector * (player.ShotSpeed * 10) + player.Velocity):Resized(player.ShotSpeed * 10) 
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    queueNewWaveCheck = false
end)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.NewWaveOnChargeGameUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, CheckTheChecker, FamiliarVariant.SOMETHINGWICKED_THE_CHECKER)

function SomethingWicked:AddItemWispForEval(player, collectible, num)
    num = num or 1

    local p_data = player:GetData()
    p_data.sw_itemWisps[collectible] = (p_data.sw_itemWisps[collectible] or 0) + num
end
--Devil deal chance
function mod:EvalutePWisps(player)
    local p_data = player:GetData()
    p_data.sw_ddChance = 0 p_data.sw_itemWisps = {}
    mod:CallCustomCback(ccabEnum.SWCB_EVALUATE_TEMP_WISPS, player, p_data)
	local ddAmount = p_data.sw_ddChance

	mod:SetItemWisps(player, ddAmount, -1)

    for key, value in pairs(p_data.sw_itemWisps) do
        mod:SetItemWisps(player, value, key)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.EvalutePWisps)


-- the below code is some rewritten TT stuff (except its not actually TT stuff and its fiendfolio stuff, thanks connor fiendfolio)

-- okay so i probably shouldnt include this but idk, its good for attaching wisp to player
function mod:GetWispData(player)
	local data = player:GetData()
    data.SomethingWickedPData.itemWisps = data.SomethingWickedPData.itemWisps or {}
	return data.SomethingWickedPData.itemWisps
end
function mod:GetWispRefs()
	if not SomethingWicked.save.runData.itemWisps then
		SomethingWicked.save.runData.itemWisps = {}
	end
	return SomethingWicked.save.runData.itemWisps
end

function mod:InitializeDevilWisp(wisp)
	wisp:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
	wisp.Visible = false
	wisp:RemoveFromOrbit()
	wisp:GetData().sw_itemWisp = true
end

local function RemoveDevilWisp(player, amount, type)
	amount = amount or 1
	local wispRefs = mod:GetWispRefs()
    local data = mod:GetWispData(player)
	
	for i, wisp in pairs(data) do
        if type ~= wisp then
            goto continue
        end
        data[i] = nil
        wispRefs[i] = nil
		amount = amount - 1
		if amount <= 0 then
            return
		end
	    ::continue::
	end
end
function mod:SetItemWisps(player, amount, type)
    
	amount = amount or 1
	local wispRefs = mod:GetWispRefs()
    local data = mod:GetWispData(player)
    
    local currWisps = 0
    for i, t in pairs(data) do
        if wispRefs[i] and t == type then
            currWisps = currWisps + 1
        end
    end
    amount = amount - currWisps
	
    --print(amount, amount+currWisps, currWisps, type)
	if amount < 0 then
		RemoveDevilWisp(player, -amount, type)
	else
		-- Add the hidden item wisp.
		for i = 1, amount do
			local wisp 
            if type == -1 then
                wisp = player:AddWisp(CollectibleType.COLLECTIBLE_SATANIC_BIBLE, player.Position)
            else
                wisp = player:AddItemWisp(type, player.Position)
            end
			mod:InitializeDevilWisp(wisp)
			wispRefs[""..wisp.InitSeed] = true
			mod:__devilWispUpdate(wisp)
			data[""..wisp.InitSeed] = type
		end
	end
end

local suppressWispDeathEffects = false
local function discEffectInit(_, eff)
	if suppressWispDeathEffects then
		eff:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, discEffectInit, EffectVariant.TEAR_POOF_A)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, discEffectInit, EffectVariant.POOF01)

local function discItemWispInit(_, wisp)
	if not wisp:GetData().sw_itemWisp and (mod:GetWispRefs()[""..wisp.InitSeed]) then
		-- This wisp isn't marked as a disc wisp, but there's supposed to be a disc wisp with this InitSeed.
		-- Most likely, we've quit and continued a run. Re-initialize this as a disc wisp and hide it.
		mod:InitializeDevilWisp(wisp)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, discItemWispInit)

local function isWispNeeded(wisp, player)
    return player:GetData().sw_itemWisps[wisp.SubType] ~= nil
end
function mod:__devilWispUpdate(wisp)
	local data = wisp:GetData()
	
	if not data.sw_itemWisp then return end
	wisp.Position = Vector(-100, -50)
	wisp.Velocity = Vector.Zero
	if not mod:GetWispRefs()[""..wisp.InitSeed] or not isWispNeeded(wisp, wisp.Player) then
		-- This disc wisp should no longer exist.
		suppressWispDeathEffects = true
		wisp:Kill()
		suppressWispDeathEffects = false
		sfx:Stop(SoundEffect.SOUND_STEAM_HALFSEC)
	end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.__devilWispUpdate)

local function discItemWispCollision(_, wisp)
	if wisp:GetData().sw_itemWisp then
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, discItemWispCollision, FamiliarVariant.WISP)

local function discItemWispDamage(_, entity, _, _, damageSourceRef)
	if entity and entity:GetData().sw_itemWisp then
		return false
	end
	
	if damageSourceRef.Entity and damageSourceRef.Entity:GetData().sw_itemWisp then
		return false
	end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, discItemWispDamage)

local function discItemWispTears(_, tear)
    local spawner = tear.SpawnerEntity
	if spawner and spawner:GetData().sw_itemWisp then
		tear:Remove()
	end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, discItemWispTears)


--sac altar fix made by deadinfinity, for fiendfolio
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function()
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, -1, false, false)) do
        if wisp:GetData().sw_itemWisp then
            local fam = wisp:ToFamiliar()
            wisp:GetData().sw_itemWispPlayer = fam.Player
            fam.Player = nil
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function()
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, -1, false, false)) do
        if wisp:GetData().sw_itemWisp then
            local player = wisp:GetData().sw_itemWispPlayer
            if player then
                wisp:ToFamiliar().Player = player
            end

            wisp:GetData().sw_itemWispPlayer = nil
        end
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)

--tick update

function mod:Updately()
    local npcs = Isaac.GetRoomEntities()
    
    for i = 1, #npcs, 1 do
      local npc = npcs[i]
      npcs[i] = npc:ToNPC()
    end
  
    for _, npc in pairs(npcs) do
        mod:CallCustomCback(ccabEnum.SWCB_ON_NPC_EFFECT_TICK, npc)
    end

    mod:StatusTickMaster()
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.Updately)

--purchase item

--0 is free, 1 is red hearts, 2 is soul hearts
local couldBuyItemTable = {
    [PickupPrice.PRICE_ONE_HEART] = 1,
    [PickupPrice.PRICE_TWO_HEARTS] = 1,
    [PickupPrice.PRICE_THREE_SOULHEARTS] = 2,
    [PickupPrice.PRICE_ONE_HEART_AND_TWO_SOULHEARTS] = 1,
    [PickupPrice.PRICE_SPIKES] = 0,
    [PickupPrice.PRICE_SOUL] = function (player)
        return player:HasTrinket(TrinketType.TRINKET_YOUR_SOUL)
    end,
    [PickupPrice.PRICE_ONE_SOUL_HEART] = 2,
    [PickupPrice.PRICE_TWO_SOUL_HEARTS] = 2,
    [PickupPrice.PRICE_ONE_HEART_AND_ONE_SOUL_HEART] = 1,
    [PickupPrice.PRICE_FREE] = 0,
}

local idToBuy = {
    [0] = function ()
        return true
    end,
    [1] = function (player)
        return player:GetEffectiveMaxHearts() >= 1
    end,
    [2] = function (player)
        return player:GetSoulHearts() >= 1
    end
}

local PickupCollisionChecks = {
    [PickupVariant.PICKUP_HEART] = {
        [HeartSubType.HEART_HALF] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_FULL] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_SCARED] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_DOUBLEPACK] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_SOUL] = function(player) return player:CanPickSoulHearts() end,
        [HeartSubType.HEART_HALF_SOUL] = function(player) return player:CanPickSoulHearts() end,
        [HeartSubType.HEART_BLACK] = function(player) return player:CanPickBlackHearts() end,
        [HeartSubType.HEART_GOLDEN] = function(player) return player:CanPickGoldenHearts() end,
        [HeartSubType.HEART_BLENDED] = function(player) if not player:CanPickRedHearts() then return player:CanPickSoulHearts() end return true end,
        [HeartSubType.HEART_BONE] = function(player) return player:CanPickBoneHearts() end,
        [HeartSubType.HEART_ROTTEN] = function(player) return player:CanPickRottenHearts() end,
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = function (player)
        return player:NeedsCharge()
    end 
}

local function PurchaseItem(_, pickup, player)
    player = player:ToPlayer()
    if not player or not player:CanPickupItem() or not player:IsExtraAnimationFinished() then
        return
    end
    local price = pickup.Price
    if price == 0 then
        return
    end
    local pickupFunction = PickupCollisionChecks[pickup.Variant]
    local flag
    if pickupFunction ~= nil then
        flag = ((type(pickupFunction) == "function" and pickupFunction(player) or pickupFunction[pickup.SubType](player)))
    else flag = true end
    if not flag then
        return
    end
    
    local canBuy, isDevil = function ()
        return player:GetNumCoins() >= pickup.Price
    end, false
    if mod:UtilTableHasValue(couldBuyItemTable, pickup.Price) then
        if price ~= PickupPrice.PRICE_FREE then
            isDevil = true
        end
        
        canBuy = couldBuyItemTable[pickup.Price]
        if type(canBuy) == "number" then
            canBuy = idToBuy[canBuy]
        end
    end

    if canBuy(player) then
        local skip = mod:CallCustomCback(ccabEnum.SWCB_PRE_PURCHASE_PICKUP, player, pickup, isDevil)
        if skip ~= nil then
            return skip
        end
        mod:CallCustomCback(ccabEnum.SWCB_POST_PURCHASE_PICKUP, player, pickup, isDevil)
    end
end 
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PurchaseItem)