local mod = SomethingWicked

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_PICKUP_ITEM, function (_, player, room, id)
    local p_data = player:GetData()
    if id > 1 then
        p_data.SomethingWickedPData.trackedItems = p_data.SomethingWickedPData.trackedItems or {}
        p_data.SomethingWickedPData.trackedItems[id] = p_data.SomethingWickedPData.trackedItems[id] or {}

        local insertData = {

        }
    end
end)

local isUsingD4 = nil
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, function (_, _, _, player)
    print("using d4")
    isUsingD4 = player
    local p_data = player:GetData()
    p_data.SomethingWickedPData.trackedItems = p_data.SomethingWickedPData.trackedItems or {}

    local allItemsHeld = {}
    local iconf = Isaac.GetItemConfig()
    for i = 1, iconf:GetCollectibles().Size-1, 1 do
        if iconf:GetCollectible(i) then
            for j = 1, player:GetCollectibleNum(i), 1 do
                allItemsHeld[i] = (allItemsHeld[i] or 0) + 1
            end
        end
    end

    p_data.sw_currentItemsHeld = allItemsHeld
end, CollectibleType.COLLECTIBLE_D4)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, _, _, player)
    isUsingD4 = nil
end, CollectibleType.COLLECTIBLE_D4)

mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, function (_, item, pool)
    if isUsingD4 ~= nil then
        local itemGetingRemoved = nil

        local p = isUsingD4
        local p_data = p:GetData()
        for index, value in pairs(p_data.sw_currentItemsHeld) do
            local num = p:GetCollectibleNum(index)
            print("value", num, "item", index)

            if num < value then
                itemGetingRemoved = index
                p_data.sw_currentItemsHeld[index] = p_data.sw_currentItemsHeld[index] - 1
                if p_data.sw_currentItemsHeld[index] < 1 then
                    p_data.sw_currentItemsHeld[index] = nil
                end
                break
            end
        end

        print("item", itemGetingRemoved)
    end
end)