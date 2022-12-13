local this = {}
CollectibleType.SOMETHINGWICKED_MOSAIC_SHARD = Isaac.GetItemIdByName("Prismatic Shard")

local function procChance(player, rng)
    return 1
end
function this:OnEnemyDMGd(tear, theDMGer, player, proccer)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_MOSAIC_SHARD) then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_MOSAIC_SHARD)
        if c_rng:RandomFloat() > procChance(player, c_rng) * proccer then
            return
        end

        local angle = (theDMGer.Position - player.Position):Normalized()
        angle = angle:Rotated(-135 + c_rng:RandomInt(270))
        angle = angle:Resized(SomethingWicked.EnemyHelpers:Lerp(10, 50, c_rng:RandomFloat()))
        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_SPIDER_EGG, 0, theDMGer.Position + angle, Vector.Zero, player)
    end
end

SomethingWicked:AddCustomCBack(SomethingWicked.CustomCallbacks.SWCB_ON_ENEMY_HIT, this.OnEnemyDMGd)
this.EIDEntries = {}
return this