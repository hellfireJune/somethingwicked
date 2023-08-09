local mod = SomethingWicked
local game = Game()

function mod:OldUrnPickup(player, room, id)
    if id ~= CollectibleType.SOMETHINGWICKED_OLD_URN then
        return
    end

    local iconfig = Isaac.GetItemConfig()
    for i = 1, 3, 1 do
        local soul = nil
        local crashPreventer = 0

        while soul == nil or iconfig:GetCard(soul) == nil 
        or (((string.find((iconfig:GetCard(soul).Name):lower(), "soul")) == nil) and (crashPreventer < 100))
        do
            soul = game:GetItemPool():GetCard(Random() + 1, true, true, true)
            crashPreventer = crashPreventer + 1
            --while loops scare me
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, soul, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
    end
end