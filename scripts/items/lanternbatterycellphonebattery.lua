local this = {}
CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY = Isaac.GetItemIdByName("Lantern Battery")
TrinketType.SOMETHINGWICKED_CELLPHONE_BATTERY = Isaac.GetTrinketIdByName("Cellphone Battery")

local procChance = 0.2
SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, function ()
    local allPlayers = SomethingWicked:UtilGetAllPlayers() -- SomethingWicked.ItemHelpers:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY)
    for _, player in ipairs(allPlayers) do
        local stacks = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_LANTERN_BATTERY)
         + player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_CELLPHONE_BATTERY)
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

this.EIDEntries = {}
return this