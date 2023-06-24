local this = {}

local procChance = 0.25
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, function ()
    local allPlayers = SomethingWicked:UtilGetAllPlayers() -- SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY)
    for _, player in ipairs(allPlayers) do
        local stacks = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY)
         + (player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_CELLPHONE_BATTERY)*0.8)
        if stacks > 0 then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY)
            for i = 0, 3, 1 do
                local currentItem = player:GetActiveItem(i)
                if currentItem ~= 0 and player:NeedsCharge(i)
                and c_rng:RandomFloat() < procChance*stacks then
                    local maxCharge = Isaac.GetItemConfig():GetCollectible(currentItem).MaxCharges
                    local charge = player:GetActiveCharge(i) + player:GetBatteryCharge(i)

                    local newMaxCharge = maxCharge * (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1)
                    if charge < newMaxCharge then
                        player:SetActiveCharge(math.min(newMaxCharge, charge + 1), i) 
                        --intentional balancing choice to make it not give double charges for clearing double charge rooms
                        
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position - Vector(0, 60), Vector.Zero, player)
                        SomethingWicked.game:GetHUD():FlashChargeBar(player, i)
                        SomethingWicked.sfx:Play(SoundEffect.SOUND_BEEP)
                    --elseif TaintedTreasures then
                        --not now zzz
                    end
                end
            end
        end
    end
end)

local BatteryConvertTable = {
    [BatterySubType.BATTERY_MEGA] = BombSubType.BOMB_DOUBLEPACK,
    [BatterySubType.BATTERY_NORMAL] = BombSubType.BOMB_NORMAL,
    [BatterySubType.BATTERY_GOLDEN] = BombSubType.BOMB_GOLDEN,
    [BatterySubType.BATTERY_MICRO] = BombSubType.BOMB_TROLL
}
function this:InitBattery(battery)
    if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_CELLPHONE_BATTERY) then
        local bombType = BatteryConvertTable[battery.SubType] or BombSubType.BOMB_NORMAL
        battery:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, bombType, true, true, true)
        --battery:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.InitBattery, PickupVariant.PICKUP_LIL_BATTERY)

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player, room)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player) 
end, CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY] = {
        desc = "↑ 20% chance to give bonus charge on room clear or wave clear#Spawns a battery on pickup",
        pools = { SomethingWicked.encyclopediaLootPools.POOL_SHOP, SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP}
    },
    [TrinketType.SOMETHINGWICKED_CELLPHONE_BATTERY] = {
        desc = "↑ 20% chance to gain an extra item charge on clearing a room#!!! All batteries are turned into bombs",
        isTrinket = true,
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"15% chance to gain an extra item charge on clearing a room", "All batteries will be turned into bombs of an equivalent value"})
    }
}
return this