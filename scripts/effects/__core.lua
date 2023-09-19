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
    if ((n == nil and ent:IsBoss()) or n:IsBoss()) and e_data.sw_statArray and e_data.sw_statArray[string] then
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
    time = 30 * getStatusEffectDuration(ent, time, "curse")
    if time == 0 then
        return
    end

    local e_data = ent:GetData()
    e_data.sw_curseTick = (e_data.sw_curseTick or 0) + time
    ent:SetColor(mod.CurseStatusColor, e_data.sw_curseTick, 3, false, false)
    applyStatusEffect(ent, "curse", time)
end

function mod:UtilAddBitter(ent, duration, player)
    duration = getStatusEffectDuration(ent, duration, "bitter") * 30
    if duration == 0 then
        return
    end

    local e_data = ent:GetData()
    e_data.sw_bitterDuration = (e_data.sw_bitterDuration or 0) + duration
    e_data.sw_bitterParent = player
    ent:SetColor(mod.BitterStatusColor, duration, 2, false)
    applyStatusEffect(ent, "bitter", duration)
end

function mod:UtilAddDread(ent, stacks)
    local e_data = ent:GetData()
    e_data.sw_dreadStacks = (e_data.sw_dreadStacks or 0) + stacks
    e_data.sw_dreadDelay = 1
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
    mod:BitterStatusUpdate(ent)
    mod:DreadStatusUpdate(ent)
    mod:ElectroStunStatusUpdate(ent)

    local statusType = nil
    local e_data = ent:GetData()
    if e_data.sw_curseTick then
        statusType = "Curse"
    elseif e_data.sw_dreadStacks then
        -- dread isnt real yet
    elseif e_data.sw_bitterDuration then
        -- bitter isnt either (but slightly more real than dread)
    end

    e_data.sw_statusIconAnim = statusType
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_NPC_EFFECT_TICK, mod.StatusEffectUpdates)

local frameDict = {
    ["Curse"] = 20
}
local frameMaster = 0
function mod:StatusTickMaster()
    frameMaster = game:GetFrameCount()
end

function mod:RenderStatusEffects(npc, offset)
    local e_data = npc:GetData()
    local anim = e_data.sw_statusIconAnim

    if not anim then
        return
    end
    local offsetPos = -(npc.Size + 55)

    statusIcon:Play(anim)
    statusIcon:SetFrame(frameMaster%frameDict[anim])

    local pos = npc.Position
    statusIcon:Render(Isaac.WorldToScreen(pos + Vector(0, offsetPos)))
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.RenderStatusEffects)