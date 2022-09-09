local this = {}
this.EnemyType = 761
this.EnemyVariant = Isaac.GetEntityVariantByName("Menace Fly")
this.orbitDistance = Vector(100, 100)
this.OrbitSpeed = 4
this.moveSpeed = 12

function this:UpdateNPC(npc)
    if npc.Variant ~= this.EnemyVariant then
        return
    end
    local n_data = npc:GetData()

    if npc.Target then
        n_data.somethingwicked_orbitAngle = n_data.somethingwicked_orbitAngle or 360
        if n_data.somethingwicked_orbitAngle <= 0 then
            n_data.somethingwicked_orbitAngle = n_data.somethingwicked_orbitAngle + 360
        end
        n_data.somethingwicked_orbitAngle = n_data.somethingwicked_orbitAngle - this.OrbitSpeed

        local player = npc.Target:ToPlayer()
        local offset
        if player
        and player:GetFireDirection() ~= Direction.NO_DIRECTION then
            local aimVector = player:GetAimDirection()
            offset = (this.orbitDistance * Vector(aimVector.X, aimVector.Y))
        end
        local orbitPosition = npc.Target.Position + npc.Target.Velocity + (offset == nil and (this.orbitDistance * Vector.FromAngle(n_data.somethingwicked_orbitAngle)) or offset)
        local velocity = orbitPosition - (npc.Position + npc.Velocity)
        if velocity:Length() > this.moveSpeed then
            velocity:Resize(this.moveSpeed)
        end
        npc.Velocity = SomethingWicked.EnemyHelpers:Lerp(npc.Velocity, velocity, 0.25)
    else
        npc.Target = npc:GetPlayerTarget()
    end
end

function this:NPCDie(npc)
    if npc.Variant ~= this.EnemyVariant then
        return
    end

    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ENEMY_BRIMSTONE_SWIRL, 0, npc.Position, Vector.Zero, npc)
end

SomethingWicked:AddCallback(ModCallbacks.MC_NPC_UPDATE, this.UpdateNPC, this.EnemyType)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.NPCDie, this.EnemyType)