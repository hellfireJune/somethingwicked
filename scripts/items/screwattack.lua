local mod = SomethingWicked

local baseChance = 0.11
local function ProcChance(player, tear)
    local luck = player.Luck + (player:GetTrinketMultiplier(TrinketType.TRINKET_TEARDROP_CHARM) * 3) - (tear.Type == EntityType.ENTITY_TEAR and 0 or 3)
    return baseChance + (luck*0.04)
end
mod.TFCore:AddNewTearFlag(mod.CustomTearFlags.FLAG_SCREW_ATTACK, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.SCREW_ATTACK) then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.SCREW_ATTACK)
            if c_rng:RandomFloat() < ProcChance(player, tear) then
                if tear.Type ~= EntityType.ENTITY_TEAR then
                    local s = player:FireTear(tear.Position, mod:UtilGetFireVector(player), false, true, false, nil, 0.5)
                    mod.TFCore:AddTearFlag(s, mod.CustomTearFlags.FLAG_SCREW_ATTACK)
                else
                    return true
                end
            end
        end
    end,
    OverrideTearUpdate = function (_, tear)
        local t_data = tear:GetData()
        if not t_data.sw_screwTick then
            t_data.sw_screwTick = -1
            tear.Velocity = tear.Velocity * 2
        end
        t_data.sw_screwTick = t_data.sw_screwTick + 1

        tear.Velocity = mod.EnemyHelpers:Lerp(tear.Velocity, Vector.Zero, 0.125 + (t_data.sw_screwTick/100))
    end,
    OverrideTearCollision = function (_, tear, collider)
        return this:PreCollide(tear, collider)
    end
})
function this:PreCollide(tear, collider)
    if tear.FrameCount % 3 == 0 then
        if collider:TakeDamage(tear.CollisionDamage, 0, EntityRef(tear), 0) then
        end
    end
    return true
end

this.EIDEntries = {
    [mod.ITEMS.SCREW_ATTACK] = {
        desc = "screwed in",
        Hide = true,
    }
}
return this