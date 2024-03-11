local mod = SomethingWicked
local game = Game()

local function PickupCollision(chest, player)
    player = player:ToPlayer()
    if player and player:HasTrinket(mod.TRINKETS.STONE_KEY) and chest.SubType == ChestSubType.CHEST_CLOSED then
        chest:TryOpenChest()
    end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, PickupCollision, PickupVariant.PICKUP_BOMBCHEST)

local oldSecret = {}
local function Update()
    local t_mult = mod:GlobalGetTrinketNum(mod.TRINKETS.STONE_KEY)

    if t_mult < 0 then
        oldSecret = {}
        return
    end

    local t_rng = Isaac.GetPlayer():GetTrinketRNG(mod.TRINKETS.STONE_KEY)
    local room = game:GetRoom()
    local secrets = {}
    
    for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1, 1 do
        local door = room:GetDoor(i)
        if door and door:GetVariant() == DoorVariant.DOOR_HIDDEN and not door:IsOpen() then
            secrets[i] = true
        end
    end

    t_mult = (t_mult-1)*0.25+1
    if room:GetFrameCount() > 1 and oldSecret then
        for index, value in pairs(oldSecret) do
            local i = t_mult
                local door = room:GetDoor(index)
                if door:IsOpen() then                    
                    while t_rng:RandomFloat() < t_mult do
                        t_mult = t_mult - 1

                        local pos = door.Position
                        local v = door.Direction
                        v = mod:DirectionToVector(v) v = v:Rotated(t_rng:RandomFloat()*35)
                        v = v*6

                        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, pos+v, v, nil)
                    end
                end
        end
    end

    oldSecret = secrets
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Update)