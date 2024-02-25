local this = {}
this.AmountToSpawn = 2

function this:UseCard(_, player)
    local pickups = { {player:GetNumBombs(), PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL}, 
    {player:GetNumCoins() / 3, PickupVariant.PICKUP_COIN, CoinSubType.COIN_NICKEL}, 
    { player:GetNumKeys(), PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL } }

    local room = SomethingWicked.game:GetRoom()

    local lowestPickup = {1000, -1}
    for _, value in pairs(pickups) do
        if value[1] < lowestPickup[1] then
            lowestPickup = value
        end
    end
    for i = 1, 2 do
        Isaac.Spawn(EntityType.ENTITY_PICKUP, lowestPickup[2], lowestPickup[3], room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player) 
    end
end


SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, mod.CARDS.THOTH_THE_ADJUSTMENT)
this.EIDEntries = {
    [mod.CARDS.THOTH_THE_ADJUSTMENT] = {
        desc = "Will spawn either ".. this.AmountToSpawn .. " bombs, ".. this.AmountToSpawn .. " keys, or ".. this.AmountToSpawn .. " nickels, depending on which you have least of."
    }
}
return this