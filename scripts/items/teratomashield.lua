local this = {}
CollectibleType.SOMETHINGWICKED_TERATOMA_CHUNK = Isaac.GetItemIdByName("Teratoma Chunk")
FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL = Isaac.GetEntityVariantByName("Teratoma Orbital")
this.MovementSpeedCap = 14

this.spriteArray = {
    "teratoma_sheet_001",
    "teratoma_sheet_002",
    "teratoma_sheet_003",
}

function this:FamiliarInit(familiar)
    local sprite = familiar:GetSprite()

    familiar:AddToOrbit(20)
    familiar.OrbitDistance = Vector(20, 20)
	familiar.OrbitSpeed = 0.02

    local rng = familiar:GetDropRNG()
    sprite:ReplaceSpritesheet(0, "gfx/familiars/"..SomethingWicked:GetRandomElement(this.spriteArray, rng)..".png")
    sprite:LoadGraphics()
end

this.minDistanceToDie = 70
function this:UpdateFamiliar(orbital)
    local player = orbital.Player
    orbital.OrbitDistance = Vector(20, 20) 
	orbital.OrbitSpeed = 0.02

    local position = (orbital:GetOrbitPosition(player.Position + player.Velocity))
    local velocity = (position) - orbital.Position
    if velocity:Length() > this.MovementSpeedCap then
        velocity:Resize(this.MovementSpeedCap)
    end
    orbital.Velocity = SomethingWicked.EnemyHelpers:Lerp(orbital.Velocity, velocity, 0.25)
    if orbital.RoomClearCount >= 1 then
        orbital.RoomClearCount = 0

        player:ThrowBlueSpider(orbital.Position, orbital.Position + (RandomVector() * 20))
    end

    if orbital.Position:Distance(player.Position) < this.minDistanceToDie then
        SomethingWicked.FamiliarHelpers:KillableFamiliarFunction(orbital, true, true, true)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL)

function this:TeratomaChunkPickup(player, room)
    local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_TERATOMA_CHUNK)
    for i = 1, 8 + rng:RandomInt(6), 1 do
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL, 0, player.Position, Vector.Zero, player)
    end
end

SomethingWicked:AddPickupFunction(this.TeratomaChunkPickup, CollectibleType.SOMETHINGWICKED_TERATOMA_CHUNK)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_TERATOMA_CHUNK] = {
        desc = "↑ +1 empty heart container# Spawns 8-13 teratoma orbitals on use#Teratoma orbitals will die upon taking any damage, projectiles will pierce through them, but they will spawn spiders on room clear",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+1 empty heart container","Spawns 8-13 teratoma orbitals on use","Teratoma orbitals will die upon taking any damage, projectiles will pierce through them, but they will spawn spiders on room clear"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_KEY_MASTER,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_BOSS
        }
    }
}
return this