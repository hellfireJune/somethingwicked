local mod = SomethingWicked
local this = {}
CollectibleType.SOMETHINGWICKED_GANYMEDE = Isaac.GetItemIdByName(" Ganymede ")

local fireNeeded = 3
local volleyNum = 12
local minSpread = 27.5
local additionalSpread = 40
function this:OnFirePure(shooter, vector, scalar, player)
    local p_data = player:GetData()
    p_data.sw_ganymedeTick = p_data.sw_ganymedeTick or 0
    if shooter.Type == EntityType.ENTITY_PLAYER then
        if p_data.sw_ganymedeTick >= fireNeeded then
            p_data.sw_ganymedeTick = 0
        end
        p_data.sw_ganymedeTick =p_data.sw_ganymedeTick + 1
    end

    if p_data.sw_ganymedeTick == fireNeeded then
        local c_rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_GANYMEDE)
        for i = 1, volleyNum, 1 do
            local mult = i%2==1 and -1 or 1
            local addSpread = c_rng:RandomFloat()*additionalSpread
            local ang = (minSpread + addSpread)*mult
            local v = vector:Rotated(ang)

            v = mod:UtilGetFireVector(v, player)
            local dv = Vector.FromAngle(addSpread)
            v:Resize(v:Length()^(1/dv.X)/(1.15 + (c_rng:RandomFloat()-0.5)*0.15)*1.5)
            local t = player:FireTear(shooter.Position - v, v, false, false, false, nil, scalar)
            t:AddTearFlags(TearFlags.TEAR_SPECTRAL)
            t.Height = t.Height*3
            local t_data = t:GetData()
            t_data.sw_gany = {faller = player.MaxFireDelay/10}
        end
    end
end
mod:AddCustomCBack(mod.CustomCallbacks.SWCB_ON_FIRE_PURE, this.OnFirePure)

local noCollideFrames = 8
local noFallFrames = 94
local maxSpinSpeed = 15
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function (_, tear)
    local t_data = tear:GetData()
    local g = t_data.sw_gany
    if not g then
        return
    end

    local gp = g.parent
    local vel = g.savedVel
    local dontFall = true
    if not gp and not vel and tear.FrameCount > noCollideFrames
    and tear.FrameCount % 3 == 1 then -- my life fears for the performance of this
        --tears
        local tears = Isaac.FindInRadius(tear.Position, tear.Size*1.2, EntityPartition.ENTITY_TEAR)
        for _, nt in ipairs(tears) do
            local ntd = nt:GetData()
            if not ntd.sw_gany then
                g.parent = nt
                gp = g.parent
                goto newParent
                break
            end
        end

        ::newParent::
        if gp or vel then
            
        end
    end
    g.olOrbVec = g.olOrbVec or Vector.Zero
    if gp ~= nil then
        if not gp:Exists() then
            g.parent = nil
            gp = nil
        else
            vel = (gp.Position + gp.Velocity) - g.olOrbVec - tear.Position
            g.savedVel = gp.Velocity
            g.savedPos = gp.Position

            local pt = gp:ToTear()
            if pt then
                -- set height
            end
        end
    end

    if vel then
        if gp == nil then
            g.savedPos = (g.savedPos or tear.Position) + g.savedVel
            vel = (g.savedPos + g.savedVel) - g.olOrbVec - tear.Position
        end
        local ov = g.olOrbVec
        local pos = (tear.Position-ov)
        local nPos = pos+vel

        local dis = tear.Position - pos
        local ang = mod.EnemyHelpers:GetAngleDegreesButGood(dis) local len = dis:Length()
        len = mod.EnemyHelpers:Lerp(len, tear.Size*2, 0.1)

        g.orbSpeed = g.orbSpeed or 0
        g.orbSpeed = mod:Clamp(g.orbSpeed+g.orbSpeed, 0.1, maxSpinSpeed)
        ang = ang + g.orbSpeed

        local orbVec = Vector.FromAngle(ang)*len
        tear.Velocity = nPos+orbVec - tear.Position
        g.olOrbVec = orbVec
        
        if tear.FrameCount > noFallFrames*g.faller*2 then
            dontFall = false
        end
    else
        if tear.FrameCount > noFallFrames*g.faller then
            dontFall = false
        end
        tear.Velocity = mod.EnemyHelpers:Lerp(tear.Velocity, Vector.Zero, 0.1)
    end
    if dontFall then
        tear.Height = tear.Height - tear.FallingSpeed
        tear.FallingSpeed = 0
    end

    t_data.sw_gany = g
end)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_GANYMEDE] = {
        desc = "plaetside",
        Hide = true,
    }
}
return this