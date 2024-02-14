local mod = SomethingWicked
local sfx = SFXManager()

local beamSprite = Sprite()
beamSprite:Load("gfx/effect_nightmaretrail.anm2", true)
beamSprite:Play("Idle", false)

local beamLayer = beamSprite:GetLayer("beam")
beamLayer:SetWrapSMode(1)
beamLayer:SetWrapTMode(0)

local snapBeam = Beam(beamSprite, "beam", false, false)

local easyBottomSprite = Sprite()
easyBottomSprite:Load("gfx/familiar_sw_nightmare.anm2")
easyBottomSprite:Play("AttackBody")

local damage, inc = 2, 24
local snapbackFrames, lerpframes = 3, 6
local fOffset = Vector(0,-18)
local offsetTable = {
    [0] = 0,
    [1] = -2,
    [2] = -4,
    [3] = -4,
    [4] = -3,
}

local orbit = Vector(60, 60)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    local player = familiar.Player
    local sprite = familiar:GetSprite()
    local f_data = familiar:GetData()

    local isFiring = player:GetFireDirection() ~= Direction.NO_DIRECTION
    if not isFiring then
        f_data.sw_nightmareRenderBottom = false
        local renderSnapback, getNewSnapback = f_data.sw_nightmareSnapBack ~= nil, familiar.State == 1
        if not sprite:IsPlaying("Idle") then
            sprite:Play("Idle")
            sprite:SetFrame((f_data.sw_nightmareIdleFrame + 1) or 0)
        end
        local speedMult = 7
        local position, shouldLerp = mod:DynamicOrbit(familiar, player, speedMult, orbit)
        if shouldLerp and familiar.FrameCount > 3 then
            f_data.sw_nightmareLerpFrames = lerpframes
        end
        if getNewSnapback then
            f_data.sw_snapbackStartPos = familiar.Position
            f_data.sw_snapbackEndPos = position

            familiar.Position = position familiar.Velocity = Vector.Zero
        else
            if f_data.sw_nightmareLerpFrames then
                position = mod:Lerp(position, familiar.Position, math.min(1, 0.58 + (lerpframes-f_data.sw_nightmareLerpFrames*0.06)))

                f_data.sw_nightmareLerpFrames = f_data.sw_nightmareLerpFrames - 1
                if f_data.sw_nightmareLerpFrames == 0 then
                    f_data.sw_nightmareLerpFrames = nil
                end
            end
            mod:SetFamiliarOrbitPosWOVisualBugs(familiar, position, position - familiar.Position)

        end
        familiar.State = 0

        if renderSnapback then
            f_data.sw_nightmareSnapBack = f_data.sw_nightmareSnapBack - 1
            if f_data.sw_nightmareSnapBack < 1 then
                f_data.sw_snapbackStartPos = nil
                f_data.sw_nightmareSnapBack = nil
            end
        end

        f_data.sw_nightmareIdleFrame = sprite:GetFrame() % 20
    else
        if not sprite:IsPlaying("Attack") then
            sprite:Play("Attack")
            sprite:SetFrame((3 - (familiar.FireCooldown+ 3)) % 10)
        end
        f_data.sw_nightmareRenderBottom = true
        f_data.sw_nightmareSnapBack = snapbackFrames
        familiar.State = 1
        familiar.Velocity = Vector.Zero
        if sprite:IsEventTriggered("Attack") then
            familiar.FireCooldown = 10
            f_data.sw_NightmareTick = (f_data.sw_NightmareTick or 0) + inc

            for i = 120, 360, 120 do
                local angle = f_data.sw_NightmareTick + i
                local vec = Vector.FromAngle(angle)*7

                local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLOOD, 0, familiar.Position, vec, familiar):ToTear()
                tear.Parent = familiar
                tear:Update()
                tear.Height = tear.Height * 0.68

                tear.CollisionDamage = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and damage*2 or damage
                tear.Scale = tear.Scale * 0.6
                tear.Color = Color(0.3, 0.3, 0.3, 0.55, -0.1, -0.1, -0.1)
                tear:AddTearFlags(TearFlags.TEAR_SPECTRAL)
            end
        end
        f_data.sw_nightmareIdleFrame = (f_data.sw_nightmareIdleFrame + 1) % 20
        local mainFrame = math.floor(sprite:GetFrame()/2)
        local o = offsetTable[mainFrame]
        f_data.sw_nightmareTailOffset = Vector(0, o)
    end
    

    if familiar.FireCooldown > 0 then
        familiar.FireCooldown = familiar.FireCooldown - 1
    end
end, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar.SplatColor = Color(0, 0, 0, 0)
    familiar:AddToOrbit(60)
end, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)

mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, function (_, familiar, other)
    if familiar.SubType > 1 or familiar.State == 0 then
        return
    end
    local proj = other:ToProjectile()
    if proj then
        proj:Die()
    else
        if not other:ToNPC() then
            return
        end
    end
    familiar:TakeDamage(other.CollisionDamage, 0, EntityRef(other), 40)
end, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)

mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, function (_, ent)
    if ent.Variant ~= FamiliarVariant.SOMETHINGWICKED_NIGHTMARE then
        return
    end
    if ent.SubType > 1 or ent.State == 0 then
        return true
    end
end, EntityType.ENTITY_FAMILIAR)

mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, function (_, familiar)
    local f_data = familiar:GetData()
    if f_data.sw_nightmareSnapBack and f_data.sw_snapbackStartPos then        
        local origin = Isaac.WorldToScreen(f_data.sw_snapbackStartPos+fOffset)
        local target = Isaac.WorldToScreen(familiar.Position--[[f_data.sw_snapbackEndPos]]+fOffset)

        local width = f_data.sw_nightmareSnapBack/snapbackFrames
        local length = target:Distance(origin)
        beamSprite:GetAnimation()
        snapBeam:Add(origin, 0, width)
        snapBeam:Add(target, length, width)
        snapBeam:Render()
    end

    if f_data.sw_nightmareRenderBottom then
        easyBottomSprite:SetFrame(f_data.sw_nightmareIdleFrame)
        easyBottomSprite:Render(Isaac.WorldToScreen(familiar.Position - f_data.sw_nightmareTailOffset))
    end
end, FamiliarVariant.SOMETHINGWICKED_NIGHTMARE)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function (_, familiar)
    if familiar.Variant == FamiliarVariant.SOMETHINGWICKED_NIGHTMARE then
        
    end
end, EntityType.ENTITY_FAMILIAR)