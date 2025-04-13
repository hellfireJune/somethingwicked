local mod = SomethingWicked

function SomethingWicked:QueueItemPopUp(player, item, type, frameDelay)
    type = type or mod.ItemPopupSubtypes.STANDARD
    frameDelay = frameDelay or 1

    local p_data = player:GetData()
    p_data.sw_itemPopUps = p_data.sw_itemPopUps or {}

    table.insert(p_data.sw_itemPopUps, {item = item, type = type, frame = frameDelay})
end

function SomethingWicked:SpawnStandaloneItemPopup(item, type, pos, player)
    local itemConfig = Isaac.GetItemConfig():GetCollectible(item)
    local gfx = itemConfig.GfxFileName

    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.ITEMPOPUP, type, pos, Vector.Zero, player)
    local sprite = effect:GetSprite()
    sprite:ReplaceSpritesheet(0, gfx)
    sprite.LoadGraphics(sprite)
    effect.DepthOffset = 20
    --effect:Update()
    return effect
end

function mod:itemPopupTick(player)
    local p_data = player:GetData()
    if p_data.sw_itemPopUps then
        p_data.sw_popupWait = p_data.sw_popupWait or 0
        if p_data.sw_popupWait > 0 then
            p_data.sw_popupWait = p_data.sw_popupWait - 1
            return
        end

        local popUp = p_data.sw_itemPopUps[1]
        if popUp then
            table.remove(p_data.sw_itemPopUps, 1)
            mod:SpawnStandaloneItemPopup(popUp.item, popUp.type, player.Position, player)
            p_data.sw_popupWait = popUp.frame
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.itemPopupTick)

local startOffset,endOffest = Vector(0, -40), Vector(0, -65)
local moveSpeed, timeToRampUp, turnSpeed, minRadius, maxRadius = 24, 16, 32, 16, 160
local disHopDuration, heightOffGround = 20, -40

local color = Color(1, 1, 1, 0.835) local whitenedColour = Color(1, 1, 1, 0.835, 1, 1, 1)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    local e_data = effect:GetData()
    if effect.SubType == mod.ItemPopupSubtypes.STANDARD or effect.SubType == mod.ItemPopupSubtypes.STANDALONE_WITH_VEL then
        local mult = mod:Clamp((20/effect.FrameCount)/20, 0, 1)^0.4
        local velLerp = mod:Lerp(endOffest, startOffset, mult)
        if effect.SubType == mod.ItemPopupSubtypes.STANDALONE_WITH_VEL then
            velLerp = velLerp:Rotated(45*effect.Velocity.X*100)
        end
        effect.SpriteOffset = velLerp

        if effect.FrameCount > 20 then
            local flashMaster = (effect.FrameCount % 4)
            local shouldVis = flashMaster > 1
            
            effect.Visible = shouldVis
        end
        if effect.FrameCount > 35 then
            effect:Remove()
        end
        return
    end

    
    local p = effect.SpawnerEntity
    if not p then
        effect:Remove()
        return
    end
    if effect.SubType == mod.ItemPopupSubtypes.MOVE_TO_PLAYER then
        local moveSpeedMult = (effect.FrameCount / timeToRampUp)
        local angleMult = moveSpeedMult * 2/3

        moveSpeedMult =0.5 + (math.min(1,moveSpeedMult^2)/2)
        --[[angleMult = math.max(0.3, angleMult)*3
        mod:AngularMovementFunction(effect, p, moveSpeedMult*moveSpeed, angleMult*turnSpeed, 0.7)]]

        local d = effect.Position:Distance(p.Position)
        if d < maxRadius then
            if d < minRadius then
                effect:Remove()
                local trail = e_data.sw_itemNotifTrail
                mod:UtilScheduleForUpdate(function ()
                    if trail then
                        trail:Remove()
                    end
                end, 10, ModCallbacks.MC_POST_UPDATE)
            else
                effect.Color = Color.Lerp(whitenedColour, color, (d-minRadius)/maxRadius)
            end
        end
        
        
        local v = (p.Position - effect.Position):Normalized():Resized(math.min(d, moveSpeed*moveSpeedMult))
        effect.Velocity = mod:Lerp(v, effect.Velocity, 0.9)
        return
    end
    if effect.SubType == mod.ItemPopupSubtypes.DIS_FUNNY_MOMENTS then
        local lerp = effect.FrameCount / disHopDuration
        if lerp > 1 then
            effect:Remove()
        else
            local pos = mod:Lerp(p.Position, e_data.sw_disTargetPos, lerp)
            effect.Velocity = pos - effect.Position
            
            e_data.sw_lastOffGroundThing = e_data.sw_lastOffGroundThing or Vector(0, 0)
            local hop = math.sin(lerp/(1/math.pi))
            local v = Vector(0, heightOffGround*hop)
            effect.SpriteOffset = effect.SpriteOffset + (v-e_data.sw_lastOffGroundThing)
            e_data.sw_lastOffGroundThing = v
            if lerp > 0.33 then
                local col = Color(1, 1, 1, 1, 1, 1, 1)
                effect.Color = Color.Lerp(effect.Color, col, 0.33)
                effect.SpriteScale = mod:Lerp(Vector(1, 1), Vector(0.66, 0.66), (lerp-0.33)/0.66)
            end
            local trail = e_data.sw_itemNotifTrail
            trail.ParentOffset = effect.SpriteOffset + Vector(0, -16)
        end
        return
    end
end, mod.EFFECTS.ITEMPOPUP)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
    --if effect.SubType == mod.ItemPopupSubtypes.STANDARD then
        effect.Color = color
    --end
    if effect.SubType == mod.ItemPopupSubtypes.MOVE_TO_PLAYER or effect.SubType == mod.ItemPopupSubtypes.DIS_FUNNY_MOMENTS then
        effect.Velocity = RandomVector()*10
        
        local e_data = effect:GetData()
        e_data.sw_itemNotifTrail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, effect.Position, Vector.Zero, effect):ToEffect()
        e_data.sw_itemNotifTrail:FollowParent(effect)
    end
end, mod.EFFECTS.ITEMPOPUP)
