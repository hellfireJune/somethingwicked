local this = {}

SomethingWicked.TFCore:AddNewFlagData(SomethingWicked.CustomTearFlags.FLAG_PROVIDENCE, {
    EnemyHitEffect = function (_, tear, pos, enemy)
        this:HitEnemy(tear, pos, enemy)
    end,
    OverrideTearUpdate = function (_, tear)
        this:TearUpdate(tear)
    end,
    ApplyLogic = function (_, player)
        return player:HasCollectible(CollectibleType.SOMETHINGWICKED_EYE_OF_PROVIDENCE)
    end
})

function this:HitEnemy(tear, pos, enemy)
    local t_data = tear:GetData()
    if t_data.somethingWicked_providenceTarget == nil then
        t_data.somethingWicked_providenceTarget = enemy

        tear.CollisionDamage = tear.CollisionDamage * 2
    end
end

local orbitSpeed = 10
local distanceMut = 5
function this:TearUpdate(tear)
    
    local t_data = tear:GetData()
    local target = t_data.somethingWicked_providenceTarget
    if target and target:Exists() then
        local distance = Vector(0.5, 0.5) * (target.Size * distanceMut)
        local orbit = (tear.FrameCount * orbitSpeed) % 360
        
        local newPos = (target.Position + (distance * Vector.FromAngle(orbit)))
        local angle = SomethingWicked.EnemyHelpers:GetAngleDifference(newPos - tear.Position, tear.Velocity)
        tear.Velocity = tear.Velocity:Rotated(angle):Resized(math.min(tear.Position:Distance(newPos), orbitSpeed))
    end
end

function this:CacheEval(player, flags)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_EYE_OF_PROVIDENCE) then
        player.TearFlags = player.TearFlags | TearFlags.TEAR_PIERCING
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.CacheEval, CacheFlag.CACHE_TEARFLAG)

this.EIDEntries = {}
return this