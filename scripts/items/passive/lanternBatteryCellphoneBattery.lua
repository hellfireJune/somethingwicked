local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local procChance = 0.25
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_ITEM_SHOULD_CHARGE, function ()
    local allPlayers = mod:UtilGetAllPlayers() -- SomethingWicked.ItemHelpers:AllPlayersWithCollectible(mod.ITEMS.LANTERN_BATTERY)
    for _, player in ipairs(allPlayers) do
        local stacks = player:GetCollectibleNum(mod.ITEMS.LANTERN_BATTERY)
         + (player:GetTrinketMultiplier(mod.TRINKETS.CELLPHONE_BATTERY))
         
        if stacks > 0 then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.LANTERN_BATTERY)
            mod:ChargeFirstActive(player, 1, false, true, function ()
                return c_rng:RandomFloat() < procChance*stacks
            end)
            --[[for i = 0, 3, 1 do
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
                        game:GetHUD():FlashChargeBar(player, i)
                        sfx:Play(SoundEffect.SOUND_BEEP)
                    --elseif TaintedTreasures then
                        --not now zzz
                    end
                end
            end]]
        end
    end
end)

local BatteryConvertTable = {
    [BatterySubType.BATTERY_MEGA] = BombSubType.BOMB_DOUBLEPACK,
    [BatterySubType.BATTERY_NORMAL] = BombSubType.BOMB_NORMAL,
    [BatterySubType.BATTERY_GOLDEN] = BombSubType.BOMB_GOLDEN,
    [BatterySubType.BATTERY_MICRO] = BombSubType.BOMB_TROLL
}
local function InitBattery(_, battery)
    if mod:GlobalPlayerHasTrinket(mod.TRINKETS.CELLPHONE_BATTERY) then
        local bombType = BatteryConvertTable[battery.SubType] or BombSubType.BOMB_NORMAL
        battery:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, bombType, true, true, true)
        --battery:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, InitBattery, PickupVariant.PICKUP_LIL_BATTERY)

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player, room)
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player) 
end, mod.ITEMS.LANTERN_BATTERY)