local mod = SomethingWicked
local directory = "scripts/misc/statusEffects/"

local function applyStatusEffect(ent, string, duration)
    local e_data = ent:GetData()
    e_data.sw_statArray = e_data.sw_statArray or {}

    e_data.sw_statArray[string] = ent.FrameCount + duration + 6*30
end

local function getStatusEffectDuration(ent, time, string)
    local e_data = ent:GetData()
    if e_data.sw_statArray and e_data.sw_statArray[string] then
        local frame = ent.FrameCount
        if frame < e_data.sw_statArray[string] then
            return 0
        end
    end

    if mod:GlobalPlayerHasTrinket(TrinketType.TRINKET_SECOND_HAND) then
        time = time * 2
    end
    return time
end

function mod:UtilAddCurse(ent, time)
    local e_data = ent:GetData()
    
    time = 30 * getStatusEffectDuration(ent, time, "curse")
    e_data.somethingWicked_curseTick = (e_data.somethingWicked_curseTick or 0) + time
    ent:SetColor(mod.CurseStatusColor, e_data.somethingWicked_curseTick, 1, false, false)
    applyStatusEffect(ent, "curse", time)
end

function mod:UtilAddBitter(ent, duration, player)
    duration = getStatusEffectDuration(ent, duration) * 30

    local e_data = ent:GetData()
    e_data.somethingWicked_bitterDuration = (e_data.somethingWicked_bitterDuration or 0) + duration
    e_data.somethingWicked_bitterParent = player
    ent:SetColor(mod.BitterStatusColor, duration, 2, false)
    applyStatusEffect(ent, "bitter", duration)
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

include(directory.."bitter")
include(directory.."curse")
include(directory.."dread")
include(directory.."electroStun")