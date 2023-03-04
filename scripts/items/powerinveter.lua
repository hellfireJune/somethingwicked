local this = {}
TrinketType.SOMETHINGWICKED_POWER_INVERTER = Isaac.GetTrinketIdByName("Power Inverter")

local chargeTypes = {
    [BatterySubType.BATTERY_MICRO] = 2,
    [BatterySubType.BATTERY_MEGA] = 12,
}
local dmgPer6Charges = 0.9
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function (_, pickup, player)
    if not SomethingWicked.ItemHelpers:CanPickupPickupGeneric(pickup, player) then
        return
    end

    player = player:ToPlayer()
    if not player or not player:HasTrinket(TrinketType.SOMETHINGWICKED_POWER_INVERTER) then
        return
    end

    local sprite = pickup:GetSprite()
    sprite:Play("Collect")
    pickup:Die()

    local tmult = math.min(player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_POWER_INVERTER), 1)
    local dmgToAdd = ((chargeTypes[pickup.SubType] or 6) / 6) * dmgPer6Charges * tmult

    local p_data = player:GetData()
    p_data.SomethingWickedPData = p_data.SomethingWickedPData or {}
    if pickup.SubType == BatterySubType.BATTERY_GOLDEN then
        p_data.SomethingWickedPData.goldenBatteryRandomRoom = this:DoGoldenBattery(player, pickup)
    end
    
    p_data.SomethingWickedPData.inverterdmgToAdd = (p_data.SomethingWickedPData.inverterdmgToAdd or 0) + dmgToAdd
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
    return true
end, PickupVariant.PICKUP_LIL_BATTERY)

function this:DoGoldenBattery(player, battery)
    player:TakeDamage(2, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(battery), 1)

    local level = SomethingWicked.game:GetLevel()
    local currIdx = level:GetCurrentRoomIndex()
    
    local newIdx = currIdx
    local t_rng = player:GetTrinketRNG(TrinketType.SOMETHINGWICKED_POWER_INVERTER)
    while newIdx == currIdx do
        local seed = t_rng:RandomInt(2000000) --rt if u dont know how to seed good
        newIdx = level:GetRandomRoomIndex(false, seed) 
    end
    return newIdx
end

--[[SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.inverterCharges
    and p_data.SomethingWickedPData.inverterBattery then
        local bterry = p_data.SomethingWickedPData.inverterBattery
        if this:IsPickingUpBtery(bterry) then
            local iconfig = Isaac.GetItemConfig()
            local tmult = math.min(player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_POWER_INVERTER), 1)
            local dmgToAdd = ((chargeTypes[bterry.SubType] or 6) / 6) * dmgPer6Charges * tmult
            p_data.SomethingWickedPData.chargeDiffs = {}
            for key, value in pairs(p_data.SomethingWickedPData.inverterCharges) do
                local item = player:GetActiveItem(key)
                local coll = iconfig:GetCollectible(item)
                if coll.ChargeType ~= ItemConfig.CHARGE_SPECIAL then
                    player:SetActiveCharge(key, value)
                    SomethingWicked.game:GetHUD():FlashChargeBar(player, key)
                end
            end
            p_data.SomethingWickedPData.dischargeWait = 8

            p_data.SomethingWickedPData.inverterdmgToAdd = (p_data.SomethingWickedPData.inverterdmgToAdd or 0) + dmgToAdd
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end

        p_data.SomethingWickedPData.inverterCharges = nil
        p_data.SomethingWickedPData.inverterBattery = nil
    end
end)

function this:IsPickingUpBtery(bterry)
    return not bterry:Exists() or bterry:GetSprite():IsPlaying("Collect")
end]]

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.inverterdmgToAdd then
        player.Damage = SomethingWicked.StatUps:DamageUp(player, 0, p_data.SomethingWickedPData.inverterdmgToAdd)
    end
end)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    local allPlayers = SomethingWicked:UtilGetAllPlayers()
    for index, player in ipairs(allPlayers) do
        local p_data = player:GetData()
        local level = SomethingWicked.game:GetLevel()
        local currRoom = level:GetCurrentRoomDesc ()
        local currIdx = level:GetCurrentRoomIndex()

        if level:GetStartingRoomIndex() == currIdx
        and currRoom.VisitedCount == 0 then
            p_data.SomethingWickedPData.inverterdmgToAdd = nil
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        else
            local gidx = p_data.SomethingWickedPData.goldenBatteryRandomRoom
            if gidx and gidx == currIdx then
                p_data.SomethingWickedPData.goldenBatteryRandomRoom = nil

                local roomPos = SomethingWicked.game:GetRoom():FindFreePickupSpawnPosition(Isaac.GetRandomPosition())
                local battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN, roomPos, Vector.Zero, nil)
                battery:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                battery:GetSprite():Play("Idle")
            end
        end
    end
end)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function ()
end)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_POWER_INVERTER] = {
        isTrinket = true,
        desc = "wah wah",
        Hide = true,
    }
}
return this