local mod = SomethingWicked
local variant = Isaac.GetEntityVariantByName("[SW] Hitscan Helper")

function mod:DoHitscan(pos, vector, player, func)
    local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, variant, 0, pos, vector, nil):ToTear()
    tear.Scale = tear.Scale * 1.5
    tear.CollisionDamage = 3.5
    tear.Height = tear.Height * (player.TearRange / (40*6.5))
    local t_data = tear:GetData()
    t_data.sw_isHitScanner = true
    t_data.HitScanFunc = func
    tear:Update()
end

local function hitscanCollide(_, tear)
    
    local t_data = tear:GetData()
    if t_data.sw_isHitScanner then
        t_data.sw_stopHitscan = true
        tear:Remove()
        return true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, hitscanCollide)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, tear)
    local t_data = tear:GetData()
    if t_data.sw_isHitScanner then
        local ang = mod.EnemyHelpers:GetAngleDegreesButGood(tear.Velocity)
        local angIsDown = (ang < 120 and ang > 60) 
        local removeTearVelocity = t_data.sw_hitscanGridCollied and not angIsDown
        t_data.HitScanFunc(tear.Position + (removeTearVelocity and -tear.Velocity or tear.Velocity) + (angIsDown and -tear.PositionOffset or Vector.Zero))
    end
end, EntityType.ENTITY_TEAR)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    
    local t_data = tear:GetData()
    if t_data.sw_isHitScanner then
        local enemies = Isaac.FindInRadius(tear.Position, tear.Size/2, 8)
        if #enemies > 0 then
            return
        end
        local room = mod.game:GetRoom()
        local grid = room:GetGridEntityFromPos(tear.Position + (tear.Velocity*2))
        if grid and grid.CollisionClass > 1 then
            t_data.sw_hitscanGridCollied = true
            tear:Remove()
            return
        end
        tear:Update()
    end
end)