local this = {}
this.EnemyType = 67
this.EnemyVariant = Isaac.GetEntityVariantByName("Duke of the Abyss")

function this:UpdateNPC(npc)
    if npc.Variant ~= this.EnemyVariant then
        return
    end
    local n_data = npc:GetData()
    local n_sprite = npc:GetSprite()
end

function this:NPCDie(npc)
    if npc.Variant ~= this.EnemyVariant then
        return
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_BRIMSTONE_SWIRL, 0, npc.Position, Vector.Zero, npc)
end

function this:InitSpawnedFlies(npc)
    --print(npc.Type, npc.SpawnerType, npc.SpawnerVariant)
    if npc.SpawnerType == this.EnemyType
    and npc.SpawnerVariant == this.EnemyVariant
    and (npc.Type == 13 or npc.Type == 18) then
        npc:Morph(61, 2, 0, -1)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_INIT, this.InitSpawnedFlies)
SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.UpdateNPC, this.EnemyType)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.NPCDie, this.EnemyType)