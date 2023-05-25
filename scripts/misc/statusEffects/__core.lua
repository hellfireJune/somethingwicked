local mod = SomethingWicked
local directory = "scripts/misc/statusEffects/"
mod.curseColor = Color(1, 1, 1, 1, 0.1, 0, 0.3)
mod.WWColor = Color(0.5, 0.5, 0, 1, 0.6, 0.3, 0)
mod.dreadColor = Color(1, 1, 1, 1, 0.4)
mod.electroStunColor = Color(1, 1, 1, 1, 0.5, 0.82, 1)

local function getStatusEffectDuration(ent, time)
    if mod.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.TRINKET_SECOND_HAND) then
        time = time * 2
    end
    return time
end

function mod:UtilAddCurse(ent, time)
    local e_data = ent:GetData()
    
    time = 30 * getStatusEffectDuration(ent, time)
    e_data.somethingWicked_curseTick = (e_data.somethingWicked_curseTick or 0) + time
    ent:SetColor(mod.curseColor, e_data.somethingWicked_curseTick, 1, false, false)
end

function mod:UtilAddBitter(ent, duration, player)
    duration = getStatusEffectDuration(ent, duration) * 30

    local e_data = ent:GetData()
    e_data.somethingWicked_bitterDuration = (e_data.somethingWicked_bitterDuration or 0) + duration
    e_data.somethingWicked_bitterParent = player
    ent:SetColor(mod.WWColor, duration, 2, false)
end

function mod:UtilAddDread(ent, stacks)
    local e_data = ent:GetData()
    e_data.somethingWicked_dreadStacks = (e_data.somethingWicked_dreadStacks or 0) + stacks
    e_data.somethingWicked_dreadDelay = 1
end

function mod:UtilAddElectrostun(ent, player, duration)
    ent:AddConfusion(EntityRef(player), duration, false)

    local e_data = ent:GetData()
    e_data.somethingWicked_electroStun = true
    e_data.somethingWicked_electroStunParent = player
end

function mod:UtilAddUnravel(ent, dmg)
    local e_data = ent:GetData()
    e_data.sw_unravelDMG = (e_data.sw_unravelDMG or 0)+dmg
end

include(directory.."bitter")
include(directory.."curse")
include(directory.."dread")
include(directory.."electroStun")
include(directory.."unravel")