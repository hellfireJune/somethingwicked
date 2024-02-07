local mod = SomethingWicked

local function FamiliarInit(_, familiar)
    familiar:AddToOrbit(60)
    familiar.OrbitDistance = Vector(60, 60)
	familiar.OrbitSpeed = 0.02
end
local function UpdateFamiliar(_, familiar)
    local player = familiar.Player
    familiar.OrbitDistance = Vector(60, 60)
	familiar.OrbitSpeed = 0.02

    mod:FluctuatingOrbitFunc(familiar, player, 1)
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, FamiliarInit, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function (_, knife, proj)
    if proj:ToProjectile() then
        proj:Die()
    end
end, FamiliarVariant.SOMETHINGWICKED_DEVILSKNIFE)