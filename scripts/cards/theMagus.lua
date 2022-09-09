local this = {}
Card.SOMETHINGWICKEDTHOTH_THE_MAGUS = Isaac.GetCardIdByName("TheMagus")
this.AmountToSpawn = 2

function this:UseCard(_, player)
    local room = SomethingWicked.game:GetRoom()
    for i = 1, this.AmountToSpawn do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_LIL_BATTERY, BatterySubType.BATTERY_NORMAL, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player) 
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_THE_MAGUS)


this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_THE_MAGUS] = {
        desc = "Spawns ".. this.AmountToSpawn .. " batteries."
    }
}
return this