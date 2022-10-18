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

function SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, collectible)
    local rng = player:GetCollectibleRNG(collectible)
    local sourceItem = Isaac.GetItemConfig():GetCollectible(collectible)
    local boxEffect = player:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local boxStacks = 0
    if boxEffect ~= nil then
        boxStacks = boxEffect.Count
    end
    local itemStacks = player:GetCollectibleNum(collectible)
    return itemStacks * (1 + boxStacks), rng, sourceItem
end

function SomethingWicked.FamiliarHelpers:AddLocusts(player, amount, rng, position)
    position = position or player.Position
    for i = 1, amount, 1 do
        local subtype = rng:RandomInt(5) + 1
        local amountToSpawn = 1
        if subtype == LocustSubtypes.LOCUST_OF_CONQUEST then
            amountToSpawn = amountToSpawn + rng:RandomInt(3)
        end
        for _ = 1, amountToSpawn, 1 do
            local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subtype, position, Vector.Zero, player):ToFamiliar()
            locust.Parent = player
            locust.Player = player
        end
    end
end