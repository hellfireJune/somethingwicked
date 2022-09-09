local this = {}
CollectibleType.SOMETHINGWICKED_LANTERN = Isaac.GetItemIdByName("Lantern")

function this:damageUp(player)
    player.Damage = SomethingWicked.StatUps:DamageUp(player, 0.7 * player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_LANTERN))
end

function this:OnKill(enemy)
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        local a = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_LANTERN)
        if a > 0 then
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil)
            poof:SetColor(Color(1, 0.5, 0), 250, 1, false, false)
            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, enemy.Position, Vector.Zero, nil)
            fire.SpriteScale = Vector(0.75, 0.75)
            fire.CollisionDamage = 16 * a
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.OnKill)
--SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.damageUp, CacheFlag.CACHE_DAMAGE)

this.EIDEntries = {
    [1] = {
        id = CollectibleType.SOMETHINGWICKED_LANTERN,
        desc = "radio"
    }
}
return this