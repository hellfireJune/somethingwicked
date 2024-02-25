local this = {}
this.AmountToSpawn = 2

function this:UseCard(_, player)
    local room = SomethingWicked.game:GetRoom()
    for i = 1, this.AmountToSpawn do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player) 
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, mod.CARDS.THOTH_THE_MAGUS)


this.EIDEntries = {
    [mod.CARDS.THOTH_THE_MAGUS] = {
        desc = "Spawns ".. this.AmountToSpawn .. " batteries."
    }
}
return this