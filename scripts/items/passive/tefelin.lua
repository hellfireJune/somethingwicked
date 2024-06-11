local mod = SomethingWicked
local game = Game()

mod.tef_removeNextFloor = false
local function DoorSpawn(_, door)
    if door:IsRoomType(RoomType.ROOM_ANGEL) then
        mod.tef_removeNextFloor = true
    end
end

function mod:tefilinNewFloorPlayer(player)
    local p_data = player:GetData()
    if mod.tef_removeNextFloor then
        p_data.WickedPData.tefilinUp = nil
    elseif p_data.WickedPData.tefilinUp then
        local level = game:GetLevel()
        level:AddAngelRoomChance(276)
    end
end

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_POST_DEAL_DOOR_INIT, DoorSpawn)
mod:AddCallback(ModCallbacks.MC_PRE_DEVIL_APPLY_SPECIAL_ITEMS, function ()
    for index, value in ipairs(mod:UtilGetAllPlayers()) do
        local p_data = value:GetData()
        if p_data.WickedPData.tefilinUp then
            return 1
        end
    end
end)