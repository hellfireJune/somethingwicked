SomethingWicked.FamiliarHelpers = {}

function SomethingWicked.FamiliarHelpers:KillableFamiliarFunction(familiar, blockProj, projectilesPierce, collideWithEnemies)

    if blockProj then
        --Oh deliverance, i am forever thankful
        for _, value in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, -1, -1, true)) do
            if value.Position:Distance(familiar.Position) < value.Size + familiar.Size then
                familiar:TakeDamage(value.CollisionDamage, 0, EntityRef(value), 4)
                --[[if familiar.HitPoints <= 0 then
                    
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, familiar.Position, Vector.Zero, familiar)
                    poof.Color = Color(0.1, 0.1, 0.1)
                    SomethingWicked.sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
                    
                    local p_data = player:GetData()
                    familiar:Die()
    
                end]]
                if not projectilesPierce then
                    value:Die()
                end
            end
        end
    end

    if collideWithEnemies then
        for _, value in ipairs(Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.ENEMY)) do
            if value.CollisionDamage > 0 then
                familiar:TakeDamage(1, 0, EntityRef(value), 4)
                break
            end
        end
    end
    --thanke deliverance team
end