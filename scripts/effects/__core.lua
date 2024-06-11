local mod = SomethingWicked
local game = Game()

local statusIcon = Sprite()
statusIcon:Load("gfx/somethingwicked_status_effects.anm2", true)

local directory = "scripts/effects/"
include(directory.."bitter")
include(directory.."curse")
include(directory.."dread")
include(directory.."electroStun")

local function applyStatusEffect(ent, string, duration)
    if duration == 0 then
        return
    end
    local e_data = ent:GetData()
    e_data.sw_statArray = e_data.sw_statArray or {}

    e_data.sw_statArray[string] = ent.FrameCount + duration + 6*30
end

local function getStatusEffectDuration(ent, time, string)
    local e_data = ent:GetData()

    if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
        return 0
    end

    local n = ent:ToNPC()
    if ((n == nil and ent:IsBoss()) or n:IsBoss() and ent.Type ~= 964) and e_data.sw_statArray and e_data.sw_statArray[string] then
        local frame = ent.FrameCount
        if frame < e_data.sw_statArray[string] then
            return 0
        end
    end

    if PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_SECOND_HAND) then
        time = time * 2
    end
    return math.floor(time)
end

function mod:UtilAddCurse(ent, time)
    time = 30 * getStatusEffectDuration(ent, time, "curse")
    if time == 0 then
        return
    end

    local e_data = ent:GetData()
    e_data.sw_curseTick = (e_data.sw_curseTick or 0) + time
    ent:SetColor(mod.CurseStatusColor, e_data.sw_curseTick, 3, false, false)
    applyStatusEffect(ent, "curse", time)
end

function mod:UtilAddDread(ent, time, p)
    time = 30 * getStatusEffectDuration(ent, time, "dread")
    if time == 0 then
        return
    end

    local e_data = ent:GetData()
    e_data.sw_dreadDuration = (e_data.sw_dreadDuration or 0) + time
    e_data.sw_dreadPlayer = p
    ent:SetColor(mod.DreadStatusColor, e_data.sw_dreadDuration, 3, false, false)
    applyStatusEffect(ent, "dread", time)
end

function mod:UtilAddElectrostun(ent, player, duration)
    --print(duration)
    duration = getStatusEffectDuration(ent, duration, "electroStun")
    if duration == 0 then
        return
    end
    local shouldRemove = false
    if not ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
        
        ent:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
        shouldRemove = true
    end

    local e_data = ent:GetData()
    e_data.sw_electroStun = (e_data.sw_electroStun or 0) + duration
    e_data.sw_electroStunParent = player
    e_data.sw_removeConfusedWhenDone = e_data.sw_removeConfusedWhenDone or shouldRemove
    applyStatusEffect(ent, "electroStun", duration)
end

function mod:StatusEffectUpdates(ent)
    mod:CurseStatusUpdate(ent)
    mod:DreadStatusUpdate(ent)
    mod:ElectroStunStatusUpdate(ent)

    local statusType = nil
    local e_data = ent:GetData()
    if e_data.sw_curseTick then
        statusType = "Curse"
    elseif e_data.sw_dreadDuration then
        statusType = "Dread"
    elseif e_data.sw_minotaurPrimed then
        statusType = "Radiohead"
    end

    e_data.sw_statusIconAnim = statusType
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_NPC_EFFECT_TICK, mod.StatusEffectUpdates)

local frameDict = {
    --[[["Curse"] = 1,
    ["Dread"] = 1,
    ["Radiohead"] = 1,]]
}
local frameMaster = 0
function mod:StatusTickMaster()
    frameMaster = game:GetFrameCount()
end

local dreadOffset = Vector(2,0)
function mod:RenderStatusEffects(npc, offset)
    local e_data = npc:GetData()
    local anim = e_data.sw_statusIconAnim

    if not anim then
        return
    end
    local offsetPos = -(npc.Size + 55)

    statusIcon:Play(anim)
    statusIcon:SetFrame(frameMaster%(frameDict[anim] or 1))

    local pos = npc.Position
    statusIcon:Render(Isaac.WorldToScreen(pos + Vector(0, offsetPos))+(dreadOffset*(e_data.sw_dreadIconOffset or 0)))
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.RenderStatusEffects)