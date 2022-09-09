local this = {}
this.BirettaPosition = Vector(520, 200)
this.ChipPosition = Vector(120, 200)
CollectibleType.SOMETHINGWICKED_BIRETTA = Isaac.GetItemIdByName("Biretta")

function this:OnRoomClear()
    local room = SomethingWicked.game:GetRoom()

    if room:GetType() == RoomType.ROOM_BOSS then
        for _, pl in ipairs(SomethingWicked:UtilGetAllPlayers()) do
            if pl:HasCollectible(CollectibleType.SOMETHINGWICKED_BIRETTA) then
                this:ezSpawn(this.BirettaPosition, SomethingWicked.enums.MachineVariant.MACHINE_CONFESSIONAL, pl)
                break
            end
        end
    end
end

function this:ezSpawn(position, type, pl)
    Isaac.Spawn(EntityType.ENTITY_SLOT, type, 0, position, Vector.Zero, pl)

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, pl)
    poof.SpriteScale = Vector(2, 2)
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, this.OnRoomClear)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BIRETTA] = {
        desc = "A confessional spawns upon clearing a boss room",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_ANGEL,
            SomethingWicked.encyclopediaLootPools.POOL_ULTRA_SECRET
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Upon clearing a boss room, spawns a confessional"})
    }
}
return this