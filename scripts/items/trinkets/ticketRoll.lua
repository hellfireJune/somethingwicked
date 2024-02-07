local mod = SomethingWicked
local game = Game()
local ScratchTicketPosition = Vector(120, 160)

function mod:SpawnMachineQuick(position, type, pl)
    local room = game:GetRoom()
    position = room:FindFreePickupSpawnPosition(position)
    Isaac.Spawn(EntityType.ENTITY_SLOT, type, 0, position, Vector.Zero, pl)

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, pl)
    poof.SpriteScale = Vector(2, 2)
end

local function OnRoomClear()
    local room = game:GetRoom()

    if room:GetType() == RoomType.ROOM_BOSS then
        local --[[flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_BIRETTA)
        if flag and player then
            this:ezSpawn(this.BirettaPosition, SomethingWicked.MachineVariant.MACHINE_CONFESSIONAL, player)
        end]]
        flag, player = mod:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_TICKET_ROLL)
        if flag and player then
            mod:SpawnMachineQuick(ScratchTicketPosition, mod.MachineVariant.MACHINE_SLOT, player)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnRoomClear)