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

    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_ITEMPOPUP, type, pos, Vector.Zero, player)
    local sprite = effect:GetSprite()
    sprite:ReplaceSpritesheet(0, gfx)
    sprite.LoadGraphics(sprite)
    --effect:Update()
    return effect
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function (_, player)
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
        end
    end
end)

local startOffset,endOffest = Vector(0, -20), Vector(0, -45)
local moveSpeed, timeToRampUp, turnSpeed, minRadius, maxRadius = 24, 16, 32, 10, 160
local disHopDuration, heightOffGround = 24, -30

local color = Color(1, 1, 1, 0.835) local whitenedColour = Color(1, 1, 1, 0.835, 1, 1, 1)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    local e_data = effect:GetData()
    if effect.SubType == mod.ItemPopupSubtypes.STANDARD then
        local mult = mod:Clamp((20/effect.FrameCount)/20, 0, 1)^0.4
        local velLerp = mod:Lerp(endOffest, startOffset, mult)
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
            effect.Position = mod:Lerp(p.Position, e_data.sw_disTargetPos, lerp)
            
            e_data.sw_lastOffGroundThing = e_data.sw_lastOffGroundThing or Vector(0, 0)
            local hop = math.sin(lerp/(1/math.pi))
            local v = Vector(0, heightOffGround*hop)
            effect.SpriteOffset = effect.SpriteOffset + (v-e_data.sw_lastOffGroundThing)
            e_data.sw_lastOffGroundThing = v
        end
        return
    end
end, EffectVariant.SOMETHINGWICKED_ITEMPOPUP)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_, effect)
    --if effect.SubType == mod.ItemPopupSubtypes.STANDARD then
        effect.Color = color
    --end
    if effect.SubType == mod.ItemPopupSubtypes.MOVE_TO_PLAYER then
        effect.Velocity = RandomVector()*10
        
        local e_data = effect:GetData()
        e_data.sw_itemNotifTrail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SPRITE_TRAIL, 0, effect.Position, Vector.Zero, effect):ToEffect()
        e_data.sw_itemNotifTrail:FollowParent(effect)
    end
end)