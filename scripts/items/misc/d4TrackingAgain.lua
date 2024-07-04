--item rerolling is a fickle thing, and it's going to break a lot of things across mods, but a lot of mods just use the d4 to reroll stuff, so this is good for me
--remind me to make my own custom individual item rerolls fix this (yes, bad solution, idc)

local mod = SomethingWicked

function mod:PreUseD4(_, _, player)
    local p_data = player:GetData()
    if p_data.WickedPData.trackedItems ~= nil then
        local quickTab = p_data.WickedPData.trackedItems

        local history = player:GetHistory():GetCollectiblesHistory()
        for index, id in ipairs(history) do
            
            for key, data in pairs(quickTab) do
                if not id:IsTrinket() and data.id == id:GetItemID() then
                    quickTab[key] = nil
                    p_data.WickedPData.trackedItems.tempTrackerID = index
                    goto nextUp
                end
            end
            ::nextUp::
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_USE_ITEM, mod.PreUseD4, CollectibleType.COLLECTIBLE_D4)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, function (_, _, _, player)
    local p_data = player:GetData()
    if p_data.WickedPData.trackedItems ~= nil then
        local history = player:GetHistory():GetCollectiblesHistory()
        for key, value in pairs(p_data.WickedPData.trackedItems) do
            value.id = history[value.tempTrackerID]:GetItemID()
        end
    end
end, CollectibleType.COLLECTIBLE_D4)


function SomethingWicked:AddItemToTrack(player, id, index)
    local p_data = player:GetData()
    p_data.WickedPData.trackedItems = p_data.WickedPData.trackedItems or {}
    p_data.WickedPData.trackedItems[index] = { id = id}
end

function SomethingWicked:GetItemFromTrack(player, index, remove)
    remove = remove or false
    
    local p_data = player:GetData()
    p_data.WickedPData.trackedItems = p_data.WickedPData.trackedItems or {}
    if p_data.WickedPData.trackedItems[index] == nil then
        return nil
    end
    local id = p_data.WickedPData.trackedItems[index].id
    if remove then
        p_data.WickedPData.trackedItems[index] = nil
    end
    return id
end