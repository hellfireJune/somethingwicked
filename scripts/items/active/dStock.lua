local mod = SomethingWicked
local game = Game()

local function ItemUse(_, _, _, player)
    local room = game:GetRoom()
    local rType = room:GetType()
    if room:GetType() == RoomType.ROOM_SHOP then
        room:ShopRestockFull()
    else
        local level = game:GetLevel()
        local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex())
        local roomData = roomDesc.Data

        local whatToDoToItem = nil
        if rType == RoomType.ROOM_DEVIL then
            whatToDoToItem = function (pickup)
                local c = room:GetSeededCollectible(Random())
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, c)
                
                pickup.Price = -1
                pickup.ShopItemId = -2
                pickup:Update()
            end
        elseif rType == RoomType.ROOM_ANGEL and roomData.Subtype == 1 then -- angel shop
            room:ShopReshuffle(true, true)
            whatToDoToItem = function (pickup, idx)
                pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, mod.CONST.DUMMYITEMS.APOLLYONS_CROWN)
                pickup.Price = 1
                pickup.AutoUpdatePrice = true
                pickup.ShopItemId = idx
                pickup:Update()

                player:UseActiveItem(CollectibleType.COLLECTIBLE_D6, false)
            end
        end

        if whatToDoToItem then
            local spawns = roomData.Spawns
            local shopIDX = 0
            for i = 0, roomData.SpawnCount, 1 do
                local spawn = spawns:Get(i)
                if spawn then
                    local entry = spawn:PickEntry(0)
                    if entry and entry.Type == EntityType.ENTITY_PICKUP 
                    and entry.Variant == PickupVariant.PICKUP_SHOPITEM then
                        local spawnPos = Vector(80+spawn.X*40, 80+(spawn.Y+2)*40)
                        local shopPickups = Isaac.FindInRadius(spawnPos, 2, EntityPartition.ENTITY_PICKUP)
                        local shopitem = nil
                        for index, value in ipairs(shopPickups) do
                            value = value:ToPickup()
                            if value.Price ~= 0 then
                                shopitem = value
                            end
                        end
                        if shopitem == nil then
                            shopitem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_SHOPITEM, 0, spawnPos, Vector.Zero, nil)
                        end

                        shopitem = shopitem:ToPickup()
                        whatToDoToItem(shopitem, shopIDX)
                        shopitem:AddEntityFlags(EntityFlag.FLAG_APPEAR)
                        shopIDX = shopIDX + 1
                    end
                end
            end
        end
    end
    return true
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, ItemUse, mod.ITEMS.D_STOCK)

function mod:DbugShop(ids,offs)
    for index, value in ipairs(Isaac.FindByType(5)) do
        value:Remove()
    end

    local vec = Vector(120, 300)
    for i = 1, ids, 1 do
        local shopitem = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 1, vec, Vector.Zero, nil):ToPickup()
        shopitem.Price = 15
        shopitem.ShopItemId = i+offs
        vec = vec + Vector(80, 0)
    end
    Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_D6)
end

function mod:DbugPos()
    for index, value in pairs(Isaac.FindByType(5)) do
        print(value.Position)
    end
end