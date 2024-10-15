local mod = SomethingWicked
local game = Game()

local buffs = { "damage", "range", "speed", "firedelay", "luck", "shotspeed" }
local function BossItemSpawned(_, pickup)
    if not pickup:Exists() then
        return
    end
    local p_data = pickup:GetData()    
    if p_data.sw_pickupData.isBossRoom == nil then
        local room = game:GetRoom()
        local level = game:GetLevel()
        local desc = level:GetCurrentRoomDesc()
        if room:GetType(RoomType.ROOM_BOSS) or (room:GetType(RoomType.ROOM_CHALLENGE) and desc.Data.SubType == 1) then
            p_data.sw_pickupData.isBossRoom = true
        else
            p_data.sw_pickupData.isBossRoom = false
        end

        mod:savePickupData()
    end
    
    if pickup.SubType ~= 0 then
        p_data.sw_savedPickupSubtype = pickup.SubType
    end

    if p_data.sw_pickupData.isBossRoom and not mod.save.runData.TookDamageInBossRoom then
        if p_data.sw_pickupData.demoniumPageBuffs == nil and PlayerManager.AnyoneHasCollectible(mod.ITEMS.DEMONIUM_PAGE) then
            local t_rng = Isaac.GetPlayer(0):GetCollectibleRNG(mod.ITEMS.DEMONIUM_PAGE)
            local buffsAdd = {}
            for i = 1, 5, 1 do
                table.insert(buffsAdd, mod:GetRandomElement(buffs, t_rng))
            end
            p_data.sw_pickupData.demoniumPageBuffs = buffsAdd
            mod:savePickupData()
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, BossItemSpawned, PickupVariant.PICKUP_COLLECTIBLE)

local function demoniumCheck(player, itemID)
    local p_data = player:GetData()
    if not p_data.sw_checkedForDemonium and not p_data.WickedPData.queuedDemoniumBuffs then
        local eatenPickups = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0)
        for index, value in ipairs(eatenPickups) do
            local e_data = value:GetData()
            if e_data.sw_savedPickupSubtype == itemID and e_data.sw_pickupData.demoniumPageBuffs then
                p_data.WickedPData.queuedDemoniumBuffs = e_data.sw_pickupData.demoniumPageBuffs
                e_data.sw_pickupData.demoniumPageBuffs = nil
                mod:savePickupData()
            end
        end
    end
end
local function PlayerUpdate(_, player)
    if player.QueuedItem.Item and player.QueuedItem.Item.Type ~= ItemType.ITEM_TRINKET then
        demoniumCheck(player, player.QueuedItem.Item.ID)
    end
end
local function postAddItem(_, type, _, _, _, _, player)
    demoniumCheck(player, type)

    local p_data = player:GetData()
    if p_data.WickedPData.queuedDemoniumBuffs then
        for index, value in ipairs(p_data.WickedPData.queuedDemoniumBuffs) do
            p_data.WickedPData.candyLocketEsqueBuffs[value] = p_data.WickedPData.candyLocketEsqueBuffs[value] + 2
        end
        player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
        --handled in main.lua
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem) 