local this = {}
Card.SOMETHINGWICKEDTHOTH_ART = Isaac.GetCardIdByName("TheArt")
this.AmountToSpawn = 3

function this:UseCard(_, player)
    local room = SomethingWicked.game:GetRoom()
    for i = 1, this.AmountToSpawn do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player) 
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_ART)

this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_ART] = {
        desc = "Spawns ".. this.AmountToSpawn .. " random hearts."
    }
}
return this