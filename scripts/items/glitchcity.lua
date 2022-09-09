local this = {}
CollectibleType.SOMETHINGWICKED_GLITCHCITY = Isaac.GetItemIdByName("GLITCHCITY")
EffectVariant.SOMETHINGWICKED_GLITCHED_TILE = Isaac.GetEntityVariantByName("Glitchcity Glitched Tile")

function this:GetItem()
    if SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_GLITCHCITY) then
        return CollectibleType.SOMETHINGWICKED_GLITCHCITY
    end
end

this.chancePerItem = 0.005
function this:PlayerUpdate(player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_GLITCHCITY) then
        local stacks = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_GLITCHCITY)
        local mult = stacks * this.chancePerItem

        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_GLITCHCITY)
        local fLoat = rng:RandomFloat()
        if mult > fLoat then
            local room = SomethingWicked.game:GetRoom()
            local width = room:GetGridWidth() * 40
            local height = room:GetGridHeight() * 40
            local randomPos = Isaac.GetFreeNearPosition(Vector(rng:RandomInt(width), rng:RandomInt(height)) + Vector(0, 40), 1)
            randomPos = room:GetClampedGridIndex(randomPos)
            randomPos = room:GetGridPosition(randomPos)

            local glitchedTile = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_GLITCHED_TILE, 0, randomPos, Vector.Zero, player):ToEffect()
            glitchedTile:SetTimeout(100)
        end

    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, this.GetItem)

this.damage = 8
function this:EffectUpdate(effect)
    local nearbyEnemies = Isaac.FindInRadius(effect.Position, 30, EntityPartition.ENEMY)
    for index, value in ipairs(nearbyEnemies) do
        value:TakeDamage(this.damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(effect), 1)
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.EffectUpdate, EffectVariant.SOMETHINGWICKED_GLITCHED_TILE)

this.EIDEntries = {}
return this