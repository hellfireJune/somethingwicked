local mod = SomethingWicked

function SomethingWicked:QueueItemPopUp(player, item, type, frameDelay)
    type = type or 1
    frameDelay = frameDelay or 1

    local p_data = player:GetData()
    p_data.sw_itemPopUps = p_data.sw_itemPopUps or {}

    table.insert(p_data.sw_itemPopUps, {item = item, type = type, frame = frameDelay})
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

            local itemConfig = Isaac.GetItemConfig():GetCollectible(popUp.item)
            local gfx = itemConfig.GfxFileName

            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_ITEMPOPUP, popUp.type, player.Position, Vector.Zero, player)
            effect.Color = Color(1, 1, 1, 0.835)
            local sprite = effect:GetSprite()
            sprite:ReplaceSpritesheet(0, gfx)
            sprite.LoadGraphics(sprite)
            effect:Update()
        end
    end
end)

local startOffset,endOffest = Vector(0, -20), Vector(0, -60)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_, effect)
    if effect.SubType == 1 then
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
    end
end, EffectVariant.SOMETHINGWICKED_ITEMPOPUP)