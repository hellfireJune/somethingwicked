local this = {}
TrinketType.SOMETHINGWICKED_POWER_INVERTER = Isaac.GetTrinketIdByName("Power Inverter")

SomethingWicked:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, function (_, pickup, player)
    if not SomethingWicked.ItemHelpers:CanPickupPickupGeneric(pickup) then
        return
    end

    player = player:ToPlayer()
    if not player or not player:HasTrinket(TrinketType.SOMETHINGWICKED_POWER_INVERTER) then
        return
    end

    local p_data = player:GetData()
    p_data.SomethingWickedPData.inverterCharges = {}
    local table = {}
    for i = 0, 3, 1 do
        local currentItem = player:GetActiveItem(i)
        if currentItem ~= 0 then
            local charge = player:GetActiveCharge(i) + player:GetBatteryCharge(i)
            table[i] = charge
        end
    end
    p_data.SomethingWickedPData.inverterCharges = table
    p_data.SomethingWickedPData.inverterBattery = pickup
end, PickupVariant.PICKUP_LIL_BATTERY)
local chargeTypes = {
    [BatterySubType.BATTERY_MICRO] = 2,
    [BatterySubType.BATTERY_MEGA] = 12,
}
local dmgPer6Charges = 0.9

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.inverterCharges
    and p_data.SomethingWickedPData.inverterBattery then
        local bterry = p_data.SomethingWickedPData.inverterBattery
        if this:IsPickingUpBtery(bterry) then
            local iconfig = Isaac.GetItemConfig()
            local tmult = math.min(player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_POWER_INVERTER), 1)
            local dmgToAdd = ((chargeTypes[bterry.SubType] or 6) / 6) * dmgPer6Charges * tmult
            for key, value in pairs(p_data.SomethingWickedPData.inverterBattery) do
                local coll = iconfig:GetCollectible()
                if coll.ChargeType ~= ItemConfig.CHARGE_SPECIAL then
                    player:SetActiveCharge(value, key)
                end
            end

            p_data.SomethingWickedPData.inverterdmgToAdd = (p_data.SomethingWickedPData.inverterdmgToAdd or 0) + dmgToAdd
        end

        p_data.SomethingWickedPData.inverterCharges = nil
        p_data.SomethingWickedPData.inverterBattery = nil
    end
end)

function this:IsPickingUpBtery(bterry)
    return not bterry:Exists() or bterry:GetSprite():IsPlaying("Collect")
end

SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function (_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.inverterdmgToAdd then
        player.Damage = SomethingWicked.StatUps:DamageUp(player, 0, p_data.SomethingWickedPData.inverterdmgToAdd)
    end
end)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function ()
    local allPlayers = SomethingWicked:UtilGetAllPlayers()
    for index, player in ipairs(allPlayers) do
        local p_data = player:GetData()
        p_data.SomethingWickedPData.inverterdmgToAdd = nil
        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_POWER_INVERTER] = {
        isTrinket = true,
        desc = "wah wah"
    }
}
return this