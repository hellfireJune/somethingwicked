local mod = SomethingWicked
local game = Game()

local function GetFamiliarFromPool(_, pool, room)
    local itemConfig = Isaac.GetItemConfig()
    
    local poolType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
    if poolType == -1 then poolType = ItemPoolType.POOL_TREASURE end

    for i = 1, 100, 1 do
        local newCollectible = pool:GetCollectible(poolType, false)
        local conf = itemConfig:GetCollectible(newCollectible)
        if conf.Type == ItemType.ITEM_FAMILIAR then
            return newCollectible
        end
    end

    return CollectibleType.COLLECTIBLE_BROTHER_BOBBY
end
local function UseBox(_, _, rngObj, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        return
    end
    
    local pool = game:GetItemPool()
    local room = game:GetRoom()
    local familiar = GetFamiliarFromPool(pool, room)
    pool:RemoveCollectible(familiar)

    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, familiar, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, pickup.Position, Vector.Zero, pickup)

    return {ShowAnim = true, Remove = true}
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseBox, CollectibleType.SOMETHINGWICKED_ABANDONED_BOX)