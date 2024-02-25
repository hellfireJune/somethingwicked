local baseAmount = 10 local moreAmountMax = 8
function this:EnemyDeath(entity)
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(mod.ITEMS.SAINTS_HEAD)
    if flag and player then
        local c_rng = player:GetCollectibleRNG(mod.ITEMS.SAINTS_HEAD)

        local amountToSpawn = baseAmount + c_rng:RandomInt(moreAmountMax + 1)
        for i = 1, amountToSpawn, 1 do
            local velocity = RandomVector() * SomethingWicked.EnemyHelpers:Lerp(4, 8, c_rng:RandomFloat())
            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, entity.Position+velocity, Vector.Zero, player):ToTear()
            tear.Parent = nil
            tear.CollisionDamage = player.Damage
            tear.FallingSpeed = SomethingWicked.EnemyHelpers:Lerp(-12, -30, c_rng:RandomFloat())
            tear.FallingAcceleration = 0.9
        end

        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 0, entity.Position, Vector.Zero, player):ToEffect()
        creep.Scale = creep.Scale * SomethingWicked.EnemyHelpers:Lerp(2, 4, c_rng:RandomFloat())
        creep.CollisionDamage = player.Damage / 3
        creep:SetTimeout(90)
        creep:Update()
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.EnemyDeath)

this.EIDEntries = {
    [mod.ITEMS.SAINTS_HEAD] = {
        desc = "pssh",
        Hide = true,
    }
}
return this