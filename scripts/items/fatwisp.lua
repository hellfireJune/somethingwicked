function this:FamiliarInit(familiar)
    familiar:AddToOrbit(8)
    familiar.OrbitDistance = Vector(40, 30)
    familiar.OrbitSpeed = -0.03
end

function this:FamiliarUpdate(familiar)
    local player = familiar.Player
    familiar.Velocity = familiar:GetOrbitPosition(player.Position + player.Velocity) - familiar.Position

    if familiar.HitPoints >= 0.1 then
        --SomethingWicked.FamiliarHelpers:KillableFamiliarFunction(familiar, true, false, true, DamageFlag.DAMAGE_NOKILL)
    else
        local room = SomethingWicked.game:GetRoom()
        if room:GetFrameCount() == 0 then
            familiar.Visible = true

            local shouldBuff = player:HasCollectible(CollectibleType.SOMETHINGWICKED_PLANCHETTE) or player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
            familiar.HitPoints = shouldBuff and 4 or 2
            return
        end

        local f_data = familiar:GetData()
        if f_data.somethingWicked_fatWispShouldDissapear then
            f_data.somethingWicked_fatWispShouldDissapear = false

            familiar.Visible = false

            for i = 1, 3, 1 do
                local nwisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_LIGHTHOUSE, familiar.Position, Vector.Zero, familiar):ToFamiliar()
                nwisp.Parent = familiar
                nwisp:RemoveFromOrbit()
                nwisp.OrbitDistance = Vector(8, 8)
                nwisp:Update()

            end
            this:ReCalc(familiar.OrbitLayer)
        end 
    end
end

function this:ReCalc(layer)
    for index, value in ipairs(Isaac.FindByType(3)) do
        value = value:ToFamiliar() 
        if value and value.OrbitLayer == layer then
            value:RecalculateOrbitOffset(layer, true)
        end
    end
end

function this:FamiliarDMG(ent, amount, flags, source, dmgCooldown)
    if ent.Variant ~= FamiliarVariant.SOMETHINGWICKED_BIG_WISP then
        return
    end
    if flags & DamageFlag.DAMAGE_NOKILL == 0 then
        ent:TakeDamage(amount, flags | DamageFlag.DAMAGE_NOKILL, source, dmgCooldown)
        return false
    end
    ent:GetData()["somethingWicked_fatWispShouldDissapear"] = true
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.FamiliarUpdate, FamiliarVariant.SOMETHINGWICKED_BIG_WISP)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.FamiliarInit, FamiliarVariant.SOMETHINGWICKED_BIG_WISP)
SomethingWicked:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, this.FamiliarDMG, EntityType.ENTITY_FAMILIAR)
SomethingWicked:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, function (_, familiar, other)
    local proj = other:ToProjectile()
    if proj then
        proj:Die()
    else
        if not other:ToNPC() then
            return
        end
    end
    familiar:TakeDamage(other.CollisionDamage, DamageFlag.DAMAGE_NOKILL, EntityRef(other), 40)
end, FamiliarVariant.SOMETHINGWICKED_BIG_WISP)

function this:WispUpdate(familiar)
    if familiar.SubType ~= CollectibleType.SOMETHINGWICKED_LIGHTHOUSE then
        return
    end

    local room = SomethingWicked.game:GetRoom()
    if room:GetFrameCount() == 0 then
        familiar:Remove()
        return
    end

    local orbitSpeed = (math.sin(familiar.FrameCount / 20))
    familiar.Velocity = SomethingWicked.FamiliarHelpers:DynamicOrbit(familiar, familiar.Parent, 16 * orbitSpeed, Vector(8, 8)) - familiar.Position
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.WispUpdate, FamiliarVariant.WISP)

this.EIDEntries = {}
return this