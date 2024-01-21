local function OnKill(_, enemy)
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_SCORCHED_WOOD)
    if flag and player then
        local myRNG = RNG()
        myRNG:SetSeed(Random() + 1, 1)
        if myRNG:RandomInt(3 - math.min(3, -1 + player:GetTrinketMultiplier(TrinketType.SOMETHINGWICKED_SCORCHED_WOOD))) == 0 then
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, enemy.Position, Vector.Zero, nil)
            poof:SetColor(Color(1, 0.5, 0), 250, 1, false, false)
            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, enemy.Position, Vector.Zero, nil)
            fire.CollisionDamage = 23
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, OnKill)