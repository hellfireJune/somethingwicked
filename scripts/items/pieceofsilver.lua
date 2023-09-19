local this = {}
local mod = SomethingWicked

local function proc(player)
    return 1
end
mod.TFCore:AddNewTearFlag(mod.CustomTearFlags.FLAG_COINSHOT, {
    ApplyLogic = function (_, player, tear)
        if tear.Type == EntityType.ENTITY_TEAR and player:HasCollectible(CollectibleType.SOMETHINGWICKED_PIECE_OF_SILVER) then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_PIECE_OF_SILVER)
            if c_rng:RandomFloat() < proc(player) then
                return true
            end
        end
    end,
    EnemyHitEffect = function (_, tear)
        local t_data = tear:GetData()
        t_data.sw_ultracoinHit = 3
        t_data.sw_ultracoinCollides = (t_data.sw_ultracoinCollides or 0) + 1
    end,
    OverrideTearUpdate = function (_, tear)
        local t_data = tear:GetData()
        if t_data.sw_ultracoinHit == nil then
            tear.Velocity = Vector.Zero
            t_data.sw_ultracoinHit = 2
            tear:AddTearFlags(TearFlags.TEAR_PIERCING)

            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, tear.Position + tear.PositionOffset, Vector.Zero, tear):ToEffect()
            trail.MinRadius = 0.2
            trail:FollowParent(tear)
            trail.ParentOffset = tear.PositionOffset
            t_data.sw_coinTrail = trail
            
            trail:Update()
            tear:Update()
            return
        end
        t_data.sw_ultracoinCollides = t_data.sw_ultracoinCollides or 0
        if t_data.sw_ultracoinCollides >= 5 then
            t_data.sw_ultracoinCollides = -1
            t_data.sw_ultracoinHit = 0
        end
        if t_data.sw_ultracoinHit > 0 then
            if t_data.sw_ultracoinHit == 2 then
                --print(tear.FrameCount)
                local nextEnemy = mod.FamiliarHelpers:FindNearestVulnerableEnemy(tear.Position, 80000, t_data.sw_collideMap)
                if nextEnemy then
                    tear.Velocity = nextEnemy.Position - tear.Position
                else
                    t_data.sw_ultracoinHit = 0
                end
            else
                tear.Velocity = Vector.Zero
            end
        end
            if t_data.sw_ultracoinHit == 0 then
                --tear:ClearTearFlags(TearFlags.TEAR_PIERCING)
                tear.FallingSpeed = -30
                tear.FallingAcceleration = 0.9
                --tear.Velocity = Vector.Zero
                t_data.sw_ultracoinHit = -1
                tear:Update()
                return
            end
        t_data.sw_ultracoinHit = t_data.sw_ultracoinHit - 1
        t_data.sw_coinTrail.ParentOffset = tear.PositionOffset
    end
})

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_PIECE_OF_SILVER] = {
        desc = "THE ONE PIEEECE",
        Hide = true,
    }
}
return this