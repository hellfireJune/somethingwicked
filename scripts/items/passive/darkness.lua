local mod = SomethingWicked
local game = Game()

local beamSprite = Sprite()
beamSprite:Load("gfx/effect_darknessbeam.anm2", true)
beamSprite:Play("RegularTear6", false)

local otherSpeedMult = 0.2
local fullDarkFrames = 12
local gapNum, gapPercent, gapPadding = 3, 0.33, 0.2
local gapSpeed, sineSpeed, orbitSpeed = 0.66, 0.1, 3.5
local gapSize = 45
local minAngle = 8

local function round(num, factor, forcePad)
    factor = factor or 1
    forcePad = forcePad or 0
    local d = num/factor
    if d > 0.5 then
        d = math.ceil(d)
        forcePad = -forcePad
    else
        d = math.floor(d)
    end
    return (d+forcePad)*factor
end
local function roundVector(vector, factor, forcePad)
    local x = round(vector.X, factor, forcePad) --vector.X % 1 > 0.5 and math.ceil(vector.X) or math.floor(vector.X)
    local y = round(vector.Y, factor, forcePad) --vector.Y % 1 > 0.5 and math.ceil(vector.Y) or math.floor(vector.Y)
    return Vector(x,y)
end

local function updateRenderEffect(_,effect)
    if effect.SubType ~= mod.MOTVHelperSubtypes.DARKNESSTRAIL then
        return
    end
    local e_data = effect:GetData()
    local t = effect.Parent
    local fullDark = false
    if t then
        local t_data = t:GetData()
        e_data.sw_savedScale = t_data.sw_savedScale or t:ToTear().Scale
        fullDark = t_data.sw_fullDark
    end

    local frames = effect.FrameCount
    if not e_data.sw_randomFramesAdded then
        e_data.sw_randomFramesAdded = effect:GetDropRNG():RandomInt(360)
    end
    frames = frames + e_data.sw_randomFramesAdded
    e_data.sw_framesFullyDark = e_data.sw_framesFullyDark or 0
    e_data.sw_drknessRender = nil
    if fullDark or e_data.sw_framesFullyDark > 1 then
        e_data.sw_framesFullyDark = mod:Clamp(e_data.sw_framesFullyDark + (fullDark and 1 or -1), 0, fullDarkFrames)
        --beam renderer. three gaps in the things, set to different sine waves so its like an oscillating little thing around it
        local gapPercents = {}
        for i = 1, gapNum, 1 do
            local lerp = frames * i*gapSpeed
            lerp = math.sin(lerp*sineSpeed)
            lerp=(lerp+1)/2
            local gap = mod:Lerp(gapPercent*(i-1)+gapPadding, gapPercent*i, lerp)

            --print(gap)
            gapPercents[i] = gap
        end

        local orbit = (orbitSpeed*frames)%360
        local beamAngles = {}
        local darknessLerp = (e_data.sw_framesFullyDark/fullDarkFrames)^2
        for i, gap in ipairs(gapPercents) do
            local nextGap = gapPercents[i+1]
            if not nextGap then
                nextGap = gapPercents[1]+1
            end
            gap = gap*360+gapSize
            nextGap = nextGap*360-gapSize

            local tabPos = {}
            for j = -1, 1, 2 do
                local lerp = (darknessLerp/2)*j
                local pos = mod:Lerp(gap, nextGap, 0.5+lerp)+orbit
                table.insert(tabPos, pos)
            end
            table.insert(beamAngles, tabPos)
        end

        local distance = e_data.sw_savedScale*10
        local beamPos = {}

        local pathLerp=  e_data.sw_savedScale*math.max(0.1, darknessLerp)
        local animPath = mod:GetTearAnimPath(pathLerp)
        for index, value in ipairs(beamAngles) do
            local positions = {}

            local start = value[1]
            local curr, final = start, value[2]
            --while curr <= final do
            for i = 1, minAngle, 1 do
                curr = i/minAngle
                curr = mod:Lerp(start, final, curr)

                local v = Vector.FromAngle(curr):Resized(distance)
                local div = (curr-start)/(final-start)*32
                v = roundVector(v, e_data.sw_savedScale*2, e_data.sw_savedScale/2) --i dont even think this function works but i dont want to debug it
                table.insert(positions, {pos = v, float = div})
                
                --[[if curr % angleIncrement == 0 then
                    curr = curr+angleIncrement
                else
                    local d = math.ceil(curr/angleIncrement)
                    curr = d*angleIncrement
                end
                if not finalHit then
                    curr = math.min(curr, final)
                end]]
            end
            table.insert(beamPos, positions)
        end
        e_data.sw_drknessRender = beamPos
        e_data.sw_drknessScalar = (Vector.One*e_data.sw_savedScale)
        e_data.sw_drknessAnimPath = "Regular"..animPath

        e_data.sw_drknessBackRender = "Regular"..mod:GetTearAnimPath(pathLerp*2.4)
    elseif not t then
        effect:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, updateRenderEffect, mod.EFFECTS.MOTV_HELPER)

mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_DARKNESS, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.DARKNESS) then
            return true
        end
    end,
    OverrideTearUpdate = function (_, tear)
        local player = mod:UtilGetPlayerFromTear(tear)
        if not player then
            return
        end

        local t_data = tear:GetData()
        t_data.sw_drknessLastMult = t_data.sw_drknessLastMult or 1
        
        local phase = player:GetFireDirection() == Direction.NO_DIRECTION
        local expMult = phase and 1 or otherSpeedMult
        expMult = mod:Lerp(t_data.sw_drknessLastMult, expMult, 0.7333)
        local frames = math.max(0, tear.FrameCount-3)
        expMult = math.max(1-((frames^2)/10), expMult)

        t_data.sw_drknessLastMult = mod:MultiplyTearVelocity(tear, "sw_darkness", expMult, true)
        t_data.sw_drknessPhase = phase
        if not phase and tear.FrameCount % 2 == 0 then
            local ogCapsule = tear:GetCollisionCapsule(Vector.Zero)
            local capsule = Capsule(ogCapsule:GetPosition(), Vector.One*tear.Size*1.26, 0, 1)
            local es = Isaac.FindInCapsule(capsule, 8)

            for index, value in ipairs(es) do
                if value:IsVulnerableEnemy() then
                    local v_data = value:GetData()
                    if not v_data.sw_darknessTick and value:TakeDamage(2, 0, EntityRef(tear), 1) then
                        v_data.sw_darknessTick = 2
                    end
                end
            end
        end

        local cmult = (expMult-otherSpeedMult)/(1-otherSpeedMult)
        cmult = mod:Lerp(t_data.sw_drknessColourMult or cmult, cmult, 0.4)
        t_data.sw_drknessColourMult = cmult
        tear:SetColor(tear.Color*Color(cmult,cmult,cmult), 2, 2, false, false)

        t_data.sw_fullDark = cmult <= otherSpeedMult
        if not t_data.sw_drknessEffect then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.MOTV_HELPER,
            mod.MOTVHelperSubtypes.DARKNESSTRAIL, tear.Position, Vector.Zero, tear):ToEffect()
            effect.Parent = tear
            effect:FollowParent(tear)
            t_data.sw_drknessEffect = effect
        end
        t_data.sw_drknessEffect.ParentOffset = tear.PositionOffset
    end,
    OverrideTearCollision = function (_,tear,other)
        local t_data = tear:GetData()
        if not t_data.sw_drknessPhase then
            --[[if tear.FrameCount % 2 == 0 then
                other:TakeDamage(tear.CollisionDamage/5, 0, EntityRef(tear), 1)
            end]]

            return true
        end
    end
})

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function (_, tear, offset)
    local t_data = tear:GetData()
    if t_data.sw_drknessRender then
        local pos = tear.Position-- + tear.PositionOffset
        --print("do it again")
        beamSprite:Play(t_data.sw_drknessBackRender)
        --beamSprite.Scale = t_data.sw_drknessScalar
        beamSprite.Color = Color(1, 1, 1, 1, 0.66, 0, 0)
        beamSprite:Render(Isaac.WorldToScreen(pos))

        beamSprite:Play(t_data.sw_drknessAnimPath)
        beamSprite.Color = Color(1,1,1)
        beamSprite.Scale = t_data.sw_drknessScalar
        for index, value in ipairs(t_data.sw_drknessRender) do
            for j, t in ipairs(value) do
                local renderPos = Isaac.WorldToScreen(t.pos + pos)
                beamSprite:Render(renderPos)
            end
        end
    end
end)