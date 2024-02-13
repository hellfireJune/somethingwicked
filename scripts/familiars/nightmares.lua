local mod = SomethingWicked
local sfx = SFXManager()

local damage, inc = 2, 24

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    local player = familiar.Player
    local sprite = familiar:GetSprite()
    local f_data = familiar:GetData()

    local isFiring = player:GetFireDirection() ~= Direction.NO_DIRECTION
    if not isFiring then
        sprite:Play("Idle")
        local speedMult = 7
        local position = mod:DynamicOrbit(familiar, player, speedMult, Vector(60, 60))
        familiar.Velocity = position - familiar.Position
        familiar.State = 0
    else
        familiar.State = 1
        familiar.Velocity = Vector.Zero
        if sprite:GetFrame() == 9 then
            sprite:Play("Attack", true)
        elseif sprite:IsEventTriggered("Attack") then
            f_data.sw_NightmareTick = (f_data.sw_NightmareTick or 0) + inc

            for i = 120, 360, 120 do
                local angle = f_data.sw_NightmareTick + i
                local vec = Vector.FromAngle(angle)*7

                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, familiar.Position, vec, familiar):ToTear()
                tear.Parent = familiar
                tear:Update()

                tear.CollisionDamage = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and damage*2 or damage
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
            end
        end
        sprite:Play("Attack")
    end
end, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)

mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, function (_, familiar, other)
    if familiar.SubType > 1 or familiar.State == 0 then
        return
    end
    local proj = other:ToProjectile()
    if proj then
        proj:Die()
    else
        if not other:ToNPC() then
            return
        end
    end
    familiar:TakeDamage(other.CollisionDamage, 0, EntityRef(other), 40)
end, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, function (_, ent)
    
    if ent.Variant ~= FamiliarVariant.SOMETHINGWICKED_NIGHTMARE then
        return
    end
    if ent.SubType > 1 then
        return true
    end
end, EntityType.ENTITY_FAMILIAR)