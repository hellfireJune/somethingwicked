local mod = SomethingWicked
local this = {}

local function procChance(player)
   return 0.2 + (player.Luck*0.05) 
end
mod.TFCore:AddNewTearFlag(mod.CustomTearFlags.FLAG_RAIN_HELLFIRE, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_BLOOD_HAIL)
        and ((tear.Parent and tear.Parent.Type == 1)) then
            local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_BLOOD_HAIL)
            if c_rng:RandomFloat() < procChance(player) then
                return true
            end
        end
    end,
    EnemyHitEffect = function (_, tear, pos, enemy)
        this:HitEnemy(tear, enemy, pos)
    end,
    PostApply = function (_, player, tear)
        if tear.Type == EntityType.ENTITY_TEAR then
            mod:utilForceBloodTear(tear)
        end
        
    end
})

function this:HitEnemy(tear, enemy, pos)
    local rng = tear:GetDropRNG()
    local angle = Vector.FromAngle(rng:RandomInt(360))
    angle = angle:Resized(mod:Lerp(enemy.Size - 10, enemy.Size + 45, rng:RandomFloat()))
    local posToSpawnAt = enemy.Position + enemy.Velocity + angle

    local player = mod:UtilGetPlayerFromTear(tear)
    local fallingTear = player:FireTear(posToSpawnAt, Vector.Zero, false, true, false)

    fallingTear.Parent = nil
    fallingTear.Height = -500
    fallingTear.Scale = fallingTear.Scale * 3
    fallingTear.FallingAcceleration = 3
    fallingTear.FallingSpeed = 3
    mod:utilForceBloodTear(fallingTear)
    fallingTear:Update()
end

function this:RemoveTear(tear)
    local player = mod:UtilGetPlayerFromTear(tear)
    if not player then
        return
    end

    local t_data = tear:GetData()
    if t_data.sw_bloodHailStyle then
        
        local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_RED, 0, tear.Position, Vector.Zero, player)
        creep.CollisionDamage = tear.CollisionDamage / 7
        --creep.Scale = 0.5
        creep:Update()

        if t_data.sw_bloodHailStyle == "haemo" then
            for i = 1, 8, 1 do
                local randomVelocity = RandomVector() * 10
                local bt = player:FireTear(tear.Position, randomVelocity, false, true, false, nil, 0.5)
                bt.Parent = nil
                bt.Height = bt.Height / 3
                mod:utilForceBloodTear(bt)
                bt:Update()
            end
        else

        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CallbackPriority.EARLY, this.RemoveTear, EntityType.ENTITY_TEAR)
function this:TearCollision(tear)
    local t_data = tear:GetData()
    if t_data.sw_bloodHailStyle then
        return true
    end
end

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_BLOOD_HAIL] = {
        desc = "rain ):",
        Hide = true,
    }
}
return this