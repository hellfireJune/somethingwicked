--i wish i had a 19 inch rack
local mod = SomethingWicked
local offGreenColor = Color(0.376, 0.478, 0.215)

local beamSprite = Sprite()
beamSprite:Load("gfx/effect_wnic_connector.anm2", true)
beamSprite:Play("Idle", false)
beamSprite.Color = offGreenColor

local beamLayer = beamSprite:GetLayer("beam")
beamLayer:SetWrapSMode(1)
beamLayer:SetWrapTMode(0)
local snapBeam = Beam(beamSprite, "beam", false, false)

local loopController = nil
mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_PING, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.WNIC) then
            if (tear.Parent and tear.Parent.Type == EntityType.ENTITY_PLAYER) then
                return true
            end
        end
    end,
    EnemyHitEffect = function (_, tear, pos, enemy, p)
        if tear.Type == EntityType.ENTITY_TEAR and not tear:GetData().sw_loopIdx then
            --[[local nt = p:FireTear(p.Position, tear.Velocity, false, true, false, nil, math.min(tear.CollisionDamage / p.Damage,1))
            nt.Parent = nil]]
            local nt = mod:SpawnTearSplit(tear, p, pos, tear.Velocity, 0.8)
            nt:SetColor(tear.Color*Color(1,1,1,1,1,2,1), 15, 15, true, true)
            local nt_data = nt:GetData()
            nt_data.sw_loopIdx = tear.Index
            mod:addWickedTearFlag(nt, mod.CustomTearFlags.FLAG_PING)
        end
    end,
    PostApply = function (_, player, tear)
        mod:addTearToConnectors(tear)
    end
})

local function initLoopController()
    if not loopController or not loopController:Exists() then
        local loopMaster = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.ONERENDERHELPER, 0, Vector(100, 100), Vector.Zero, nil)
        loopMaster.DepthOffset = -9999
        loopController = loopMaster
    end
end

function mod:addTearToConnectors(tear)
    initLoopController()

    local t_data = tear:GetData()
---@diagnostic disable-next-line: need-check-nil, undefined-field
    local e_data = loopController:GetData()
    local idx =  tear.Index--getGenericId()
    
    if t_data.sw_loopIdx then
        e_data.sw_AgainTears = e_data.sw_AgainTears or {}
        e_data.sw_GoingTears =  e_data.sw_GoingTears or {}
        local parent = e_data.sw_GoingTears[t_data.sw_loopIdx]
        e_data.sw_AgainTears[idx] = {
            t = tear,
            posMap = parent.posMap,
        }
        tear.Position = parent.startPos
    else
        e_data.sw_GoingTears =  e_data.sw_GoingTears or {}
        e_data.sw_GoingTears[idx] = {
            t = tear,
            posMap = {},
            startPos = tear.Position-tear.Velocity
        }
    end
end

local function animOffset(frame)
    frame = frame%16
    return frame*-0.25
end
local maxDuration = 300
local blinkDuration, isVis = 4, 2
local timeToLast = 18
function mod:updateEveryPingTear()
    local effect = loopController
    if effect == nil then
        return
    end
    local e_data = effect:GetData()

    local t_renderData = {}
    local bonesWithoutFathers = {}
    local t_animoffset = {}
    if e_data.sw_GoingTears then
        for key, value in pairs(e_data.sw_GoingTears) do
            local ntab = value
            local t = ntab.t
            if t and t:Exists() then
                ntab.fcount = ntab.fcount or 0
                local vCount = ntab.fcount%blinkDuration
                local vis = vCount <= isVis

                local val = { pos = t.Position, v = vis, rPos = t.Position + t.PositionOffset }
                if #ntab.posMap == 0 then
                    val.heartscale = (Vector.One*t.Scale*0.7)
                    _,_,val.heartanim = mod:GetTearAnimPath(t.Scale*0.7 )
                end
                table.insert(ntab.posMap, val)
                if #ntab.posMap > maxDuration then
                    table.remove(ntab.posMap, 1)
                end
                ntab.fcount = ntab.fcount + 1
                t_renderData[key] = ntab.posMap
                t_animoffset[key] = animOffset(ntab.fcount)
            else
                ntab.posMap[#ntab.posMap] = nil
                bonesWithoutFathers[key] = ntab
                ntab = nil
            end

            e_data.sw_GoingTears[key] = ntab
        end
    end
    local boneRefs = {}
    local bonesWithoutFathers2 = {}
    local needlesslyComplicatedRenderList = {}
    
    if e_data.sw_AgainTears then
        for key, value in pairs(e_data.sw_AgainTears) do
            local ntab = value
            local t = ntab.t
            if t and t:Exists() then
                local t_data = t:GetData()
                local echoIdx = t_data.sw_loopIdx or key

                local fCount = t.FrameCount
                local pos = ntab.posMap[fCount]
                if pos then
                    pos = pos.pos
                    t.Velocity = pos - t.Position
                end
                if ntab.posMap[fCount-1] then
                    ntab.posMap[fCount-1].v = nil
                end

                if bonesWithoutFathers[echoIdx] then
                    boneRefs[echoIdx] = boneRefs[echoIdx] or { f = 999, ref = nil }
                    local brefs = boneRefs[echoIdx]
                    if t.FrameCount < brefs.f then
                        if brefs.ref then
                            e_data.sw_AgainTears[brefs.ref].render = nil
                        end
                        boneRefs[echoIdx] = { f = t.FrameCount, ref = key }
                        ntab.render = true
                    end
                end
                
                ntab.fcount = (ntab.fcount or 0) + 1
                if ntab.render then
                    needlesslyComplicatedRenderList[echoIdx] = ntab
                end
            else
                bonesWithoutFathers2[key] = ntab
                ntab = nil
            end

            e_data.sw_AgainTears[key] = ntab
        end
    end
    for key, value in pairs(needlesslyComplicatedRenderList) do
        t_renderData[key] = value.posMap
        t_animoffset[key] = animOffset(value.fcount)
    end
    e_data.sw_NoneTears = e_data.sw_NoneTears or {}
    for key, value in pairs(bonesWithoutFathers) do
        if not boneRefs[key] then
            e_data.sw_NoneTears[key] = value
        end
    end
    for key, value in pairs(bonesWithoutFathers2) do
        e_data.sw_NoneTears[key] = value
    end
    for key, value in pairs(e_data.sw_NoneTears) do
        local ntab = value
        ntab.fcount = (ntab.fcount or 0) + 1
        ntab.deathCount = (ntab.deathCount or 0) + 1
        local evenBotherRendering = ntab.deathCount < timeToLast/2 or ntab.deathCount%4<=1
        if ntab.deathCount > timeToLast then
            ntab = nil
        elseif evenBotherRendering then
            t_renderData[key] = ntab.posMap
            t_animoffset[key] = animOffset(ntab.fcount)
        end

        e_data.sw_NoneTears[key] = ntab
    end

    e_data.sw_tearBonesToRender = t_renderData
    e_data.sw_tearBonesOffset = t_animoffset
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_UPDATE, CallbackPriority.LATE, mod.updateEveryPingTear)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function (_, effect)
    local e_data = effect:GetData()
    local allBones = e_data.sw_tearBonesToRender
    if not allBones then
        return
    end

    local lastRPos
    for key, map in pairs(allBones) do
        local currentLong = 0
        local offset = e_data.sw_tearBonesOffset
        for index, value in ipairs(map) do
            local renderAnyway = index == #map

            if value.v then
                local rpos = Isaac.WorldToScreen(value.rPos)
                lastRPos = rpos
                beamSprite:GetAnimation()
                snapBeam:Add(rpos, (currentLong+4.25+offset[key])*4, 0.8)
                currentLong = currentLong + 1
                if value.heartanim then
                    beamSprite.Scale = value.heartscale
                    beamSprite:RenderLayer(value.heartanim, rpos)
                    beamSprite.Scale = Vector.One
                end
            end
            if not value.v or renderAnyway then
                if currentLong == 1 then
                    local rpos = lastRPos
                    snapBeam:Add(rpos, currentLong*4)
                end
                    
                if currentLong ~= 0 then
                    snapBeam:Render()
                end
                currentLong = 0
            end
        end
    end
end, mod.EFFECTS.ONERENDERHELPER)

--i dont actually wish i had a 19 inch rack, that sounds like a pain to deal with