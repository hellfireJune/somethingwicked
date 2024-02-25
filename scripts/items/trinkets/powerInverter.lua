local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local chargeTypes = {
    [BatterySubType.BATTERY_MICRO] = 2,
    [BatterySubType.BATTERY_MEGA] = 12,
}
local dmgPer6Charges = 0.9
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function (_, pickup, player)

    player = player:ToPlayer()
    if not player or not player:HasTrinket(mod.TRINKETS.POWER_INVERTER) then
        return
    end
    if not mod:CanPickupPickupGeneric(pickup, player) then
        return
    end

    local sprite = pickup:GetSprite()
    sprite:Play("Collect")
    pickup:Die()
    sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position - Vector(0, 60), Vector.Zero, player)

    local tmult = math.min(player:GetTrinketMultiplier(mod.TRINKETS.POWER_INVERTER), 1)
    local dmgToAdd = ((chargeTypes[pickup.SubType] or 6) / 6) * dmgPer6Charges * tmult

    local p_data = player:GetData()
    p_data.WickedPData = p_data.WickedPData or {}
    if pickup.SubType == BatterySubType.BATTERY_GOLDEN then
        p_data.WickedPData.goldenBatteryRandomRoom = mod:DoGoldenBattery(player, pickup)
    end
    
    p_data.WickedPData.inverterdmgToAdd = (p_data.WickedPData.inverterdmgToAdd or 0) + dmgToAdd
    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
    player:EvaluateItems()
    return true
end, PickupVariant.PICKUP_LIL_BATTERY)

function mod:DoGoldenBattery(player, battery)
    player:TakeDamage(2, DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(battery), 1)

    local level = game:GetLevel()
    local currIdx = level:GetCurrentRoomIndex()
    
    local newIdx = currIdx
    local t_rng = player:GetTrinketRNG(mod.TRINKETS.POWER_INVERTER)
    while newIdx == currIdx do
        local seed = t_rng:RandomInt(2000000) --rt if u dont know how to seed good
        newIdx = level:GetRandomRoomIndex(false, seed) 
    end
    return newIdx
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    local allPlayers = SomethingWicked:UtilGetAllPlayers()
    for index, player in ipairs(allPlayers) do
        local p_data = player:GetData()
        local level = game:GetLevel()
        local currRoom = level:GetCurrentRoomDesc ()
        local currIdx = level:GetCurrentRoomIndex()

        if level:GetStartingRoomIndex() == currIdx
        and currRoom.VisitedCount == 1 then
            p_data.WickedPData.inverterdmgToAdd = nil
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
            
            p_data.WickedPData.goldenBatteryRandomRoom = nil
        else
            local gidx = p_data.WickedPData.goldenBatteryRandomRoom
            if gidx and gidx == currIdx then
                p_data.WickedPData.goldenBatteryRandomRoom = nil

                local room = game:GetRoom()
                local roomPos = room:FindFreePickupSpawnPosition(Isaac.GetRandomPosition())
                local battery = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_GOLDEN, roomPos, Vector.Zero, nil)
                battery:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                battery:GetSprite():Play("Idle")
            end
        end
    end
end)