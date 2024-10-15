local mod = SomethingWicked
local game = Game()

local statusIcon = Sprite()
statusIcon:Load("gfx/somethingwicked_status_effects.anm2", true)

local directory = "scripts/effects/"
include(directory.."bitter")
include(directory.."curse")
include(directory.."dread")
include(directory.."electroStun")

local function getAllSegmentedEnemies(ent)
    local segments = { ent }
    local sigmaChild = ent
    local loops = 0
    for i = 1, 2, 1 do
        Isaac.DebugString("start new search")
        local childParent = ent
        while childParent ~= nil do
            sigmaChild = childParent
            if i == 1 then
                childParent = childParent.Child
            else
                childParent = childParent.Parent
            end
            if childParent ~= nil then
                if childParent:Exists() and childParent:ToNPC() and (i ~= 1 or childParent.Parent) then
                    table.insert(segments, childParent)
                else
                    childParent = nil
                end
            end
            loops = loops + 1
            Isaac.DebugString(tostring(loops))
        end
    end
    return segments, sigmaChild
end

local function applyCooldowns(ent, string, duration)
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

local function AddStatusEffectInternal(ent, time, color, key, applyFunc)
    local segments, main = getAllSegmentedEnemies(ent)
    time = 30 * getStatusEffectDuration(main, time, key)
    if time == 0 then
        return
    end

    local dataKey = "sw_"..key.."Duration"
    for index, segment in pairs(segments) do    
        local e_data = segment:GetData()
        e_data[dataKey] = (e_data[dataKey] or 0) + time
        if color then
            segment:SetColor(color, e_data[dataKey], 3, false, false) 
        end
        if applyFunc then
            applyFunc(segment, e_data)
        end
    end
    applyCooldowns(main, key, time)
end

function mod:UtilAddCurse(ent, time)
    AddStatusEffectInternal(ent, time, mod.CurseStatusColor, "curse")
end

function mod:UtilAddDread(ent, time, p)
    AddStatusEffectInternal(ent, time, mod.DreadStatusColor, "dread", function (_, data)
        data.sw_dreadPlayer = p
    end)
end

function mod:UtilAddElectrostun(ent, p, time)
    AddStatusEffectInternal(ent, time, nil, "electroStun", function (_, data)
        data.sw_electroStunParent = p
        
        local shouldRemove = false
        if not ent:HasEntityFlags(EntityFlag.FLAG_CONFUSION) then
        
            ent:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
            shouldRemove = true
        end
        data.sw_removeConfusedWhenDone = data.sw_removeConfusedWhenDone or shouldRemove
    end)
end

function mod:StatusEffectUpdates(ent)
    mod:CurseStatusUpdate(ent)
    mod:DreadStatusUpdate(ent)
    mod:ElectroStunStatusUpdate(ent)

    local statusType = nil
    local e_data = ent:GetData()
    if ent.Parent and ent.Parent:ToNPC() then
        e_data.sw_dontRenderIcon = true
    end
    if not e_data.FFStatusIcon and not e_data.sw_dontRenderIcon then
        if e_data.sw_curseDuration then
            statusType = "Curse"
        elseif e_data.sw_dreadDuration then
            statusType = "Dread"
        elseif e_data.sw_minotaurPrimed then
            statusType = "Radiohead"
        end
    else
        statusType = nil
    end
    if e_data.sw_darknessTick ~= nil then
        e_data.sw_darknessTick = e_data.sw_darknessTick - 1
        if e_data.sw_darknessTick <= 0 then
            e_data.sw_darknessTick = nil
        end
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
    local npcSprite = npc:GetSprite()
    local nullFrame = npcSprite:GetNullFrame("OverlayEffect")
    local offsetPos = Vector(0,0)
    if nullFrame then
        offsetPos = nullFrame:GetPos()
    end

    statusIcon:Play(anim)
    statusIcon:SetFrame(frameMaster%(frameDict[anim] or 1))

    local pos = npc.Position
    statusIcon:Render(Isaac.WorldToScreen(pos)+ offsetPos+(dreadOffset*(e_data.sw_dreadIconOffset or 0)))
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, mod.RenderStatusEffects)