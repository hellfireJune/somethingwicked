local this = {}
local mod = SomethingWicked
--this.color = Color()

mod.TFCore:AddNewTearFlag(mod.CustomTearFlags.FLAG_SHOTGRUB, {
    ApplyLogic = function (_, player, tear)
        if tear.Parent == nil
        or tear.Parent.Type ~= 1 then
            return false
        end
        if player:HasCollectible(mod.ITEMS.SHOTGRUB) then
            tear:AddTearFlags(TearFlags.TEAR_WIGGLE)
            return true
        end
    end,
    EndHitEffect = function (_, tear, pos)
        this:HitEnemy(tear, pos)
    end,
    TearColor = Color(0.4, 1, 0.4, 1)
})
local splittedColor = Color(0.8, 1, 0.8, 1)

this.angle = 75
this.damageMult = 0.3
local function poisonProc(player)
    return 0.2 + (player.Luck*0.05)
end
function this:HitEnemy(tear, pos)
    tear = tear:ToTear()
    if tear and tear.Height > -5 then
        return
    end

    local p = mod:UtilGetPlayerFromTear(tear)
    if p then
        for i = -this.angle, this.angle, this.angle do
            local newAngle = tear.Velocity:Rotated(i) * -1
            local new = p:FireTear(pos - tear.Velocity, newAngle:Resized(p.ShotSpeed * 10), false, false, false, nil, this.damageMult * (tear.CollisionDamage / p.Damage))
            --print(new.Parent.Type, "type")
            new.Parent = nil
            new.Height = tear.Height / 1.5

            new.Color = new.Color * splittedColor

            local c_rng = p:GetCollectibleRNG(mod.ITEMS.SHOTGRUB)
            if c_rng:RandomFloat() < poisonProc(p) then
                new:AddTearFlags(TearFlags.TEAR_MYSTERIOUS_LIQUID_CREEP)
            end
            new:Update()
        end
    end
end

this.EIDEntries = {
    [mod.ITEMS.SHOTGRUB] = {
        desc = "Oogly Boogly",
        Hide = true,
    }
}
return this