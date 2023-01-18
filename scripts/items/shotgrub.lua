local this = {}
CollectibleType.SOMETHINGWICKED_SHOTGRUB = Isaac.GetItemIdByName("Superbug")
--this.color = Color()

function this:FireGrubbyTear(tear)
    if tear.FrameCount ~= 1
    or tear.Parent == nil
    or tear.Parent.Type ~= 1 then
        return
    end

    local p = SomethingWicked:UtilGetPlayerFromTear(tear)
    local t_data = tear:GetData()
    if p and p:HasCollectible(CollectibleType.SOMETHINGWICKED_SHOTGRUB)then
        if not t_data.somethingWicked_isShotgrubSplitTear then
            tear:AddTearFlags(TearFlags.TEAR_WIGGLE)
            t_data.somethingWicked_isShotgrubTear = true
        else
            local p_rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_SHOTGRUB)
            local chance = p.Luck * 0.05
            if p_rng:RandomFloat() < 0.2 + chance then
                tear:AddTearFlags(TearFlags.TEAR_POISON)
            end
        end
    end
end

this.angle = 75
this.damageMult = 0.3
function this:OnHitEnemy(tear)
    tear = tear:ToTear()
    if tear.Height > -5 then
        return
    end

    local t_data = tear:GetData()
    if t_data.somethingWicked_isShotgrubTear
    and tear.StickTarget == nil then
        local p = SomethingWicked:UtilGetPlayerFromTear(tear)
        if p then
            for i = -this.angle, this.angle, this.angle do
                local newAngle = tear.Velocity:Rotated(i) * -1
                local new = p:FireTear(tear.Position - tear.Velocity, newAngle:Resized(p.ShotSpeed * 10), false, false, false, nil, this.damageMult * (tear.CollisionDamage / p.Damage))
                --print(new.Parent.Type, "type")
                new.Parent = nil
                new.Height = new.Height / 4

                local n_data = new:GetData()
                n_data.somethingWicked_isShotgrubSplitTear = true
            end
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, this.FireGrubbyTear)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, this.OnHitEnemy, EntityType.ENTITY_TEAR)

this.EIDEntries = {}
return this