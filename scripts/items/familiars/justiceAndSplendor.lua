local mod = SomethingWicked

function mod:justiceSplendorTick(player)
    local p_data = player:GetData()
        p_data.WickedPData.splendorTimer = (p_data.WickedPData.splendorTimer or 120) - 1
        if p_data.WickedPData.isSplendorful == nil then
            p_data.WickedPData.isSplendorful = false
        end

        if p_data.WickedPData.splendorTimer < 0 then
            p_data.WickedPData.isSplendorful = not p_data.WickedPData.isSplendorful
            p_data.WickedPData.splendorTimer = p_data.WickedPData.isSplendorful and 114 or 90
            
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
            player:EvaluateItems()
        end
end
mod:AddPeffectCheck(function (p)
    return p:HasCollectible(mod.ITEMS.JUSTICE_AND_SPLENDOR)
end, mod.justiceSplendorTick)

local function GabeSwordInit(_,familiar)
    familiar:AddToOrbit(30)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    familiar.OrbitSpeed = 0
    
    local player = familiar.Player
    local rotate = mod:GetAngleDegreesButGood((player.Position - familiar.Position):Rotated(-90))
    local sprite = familiar:GetSprite()
    sprite.Rotation = rotate
    familiar.SpriteOffset = Vector(0, -10)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, GabeSwordInit, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)

local function GabeSwordUpdate(_, familiar)
    local player = familiar.Player
    local p_data = player:GetData()
    p_data.WickedPData.splendorTimer = p_data.WickedPData.splendorTimer or 0
    
    local multer = mod:Clamp(p_data.WickedPData.splendorTimer / 7 , 0, 1)* (p_data.WickedPData.isSplendorful and 1 or -1) + (p_data.WickedPData.isSplendorful and 0 or 1)
    local speedMult = mod:Lerp(3, 18, multer)
    local position = mod:DynamicOrbit(familiar, player, speedMult, Vector(45, 45))
    mod:SetFamiliarOrbitPosWOVisualBugs(familiar, position, position - familiar.Position)

    local rotate = mod:GetAngleDegreesButGood((player.Position - position):Rotated(-90))
    local sprite = familiar:GetSprite()
    familiar.SpriteRotation = rotate

    local alpha = mod:Clamp(p_data.WickedPData.splendorTimer / 14 , 0, 1)
    sprite.Color = Color(1, 1, 1, player:GetHearts() < player:GetEffectiveMaxHearts() and alpha or 1)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, GabeSwordUpdate, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)

mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, function (_, knife, proj)
    if proj:ToProjectile() then
        proj:Die()
    end
end, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)