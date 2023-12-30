local mod = SomethingWicked
this.BirettaPosition = Vector(520, 160)
this.ScratchTicketPosition = Vector(120, 160)

function this:OnRoomClear()
    local room = SomethingWicked.game:GetRoom()

    if room:GetType() == RoomType.ROOM_BOSS then
        local --[[flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_BIRETTA)
        if flag and player then
            this:ezSpawn(this.BirettaPosition, SomethingWicked.MachineVariant.MACHINE_CONFESSIONAL, player)
        end]]
        flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_TICKET_ROLL)
        if flag and player then
            this:ezSpawn(this.ScratchTicketPosition, SomethingWicked.MachineVariant.MACHINE_SLOT, player)
        end
    end
end

function this:ezSpawn(position, type, pl)
    local room = mod.game:GetRoom()
    position = room:FindFreePickupSpawnPosition(position)
    Isaac.Spawn(EntityType.ENTITY_SLOT, type, 0, position, Vector.Zero, pl)

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, pl)
    poof.SpriteScale = Vector(2, 2)
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, this.OnRoomClear)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function ()
    local level = SomethingWicked.game:GetLevel()
    local currRoom = level:GetCurrentRoomDesc ()
    local currIdx = level:GetCurrentRoomIndex()

    if level:GetStartingRoomIndex() == currIdx
    and currRoom.VisitedCount == 1 then
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_BIRETTA)
        if flag and player then
            this:ezSpawn(this.BirettaPosition, SomethingWicked.MachineVariant.MACHINE_CONFESSIONAL, player)
        end
    end
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BIRETTA] = {
        desc = "A confessional spawns upon entering a new floor",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_ANGEL,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Upon entering a new floor, spawns a confessional"})
    },
    [TrinketType.SOMETHINGWICKED_TICKET_ROLL] = {
        desc = "A slot machine spawns upon clearing a boss room",
        isTrinket = true,
    }
}
return this