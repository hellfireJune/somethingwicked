local mod = SomethingWicked

local function PEffectUpdate(_, player)
    local p_data = player:GetData()
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR) then
        p_data.SomethingWickedPData.splendorTimer = (p_data.SomethingWickedPData.splendorTimer or 120) - 1
        if p_data.SomethingWickedPData.isSplendorful == nil then
            p_data.SomethingWickedPData.isSplendorful = false
        end

        if p_data.SomethingWickedPData.splendorTimer < 0 then
            p_data.SomethingWickedPData.isSplendorful = not p_data.SomethingWickedPData.isSplendorful
            p_data.SomethingWickedPData.splendorTimer = p_data.SomethingWickedPData.isSplendorful and 114 or 90
            
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
            player:EvaluateItems()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PEffectUpdate)

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
    p_data.SomethingWickedPData.splendorTimer = p_data.SomethingWickedPData.splendorTimer or 0
    
    local multer = mod:Clamp(p_data.SomethingWickedPData.splendorTimer / 7 , 0, 1)* (p_data.SomethingWickedPData.isSplendorful and 1 or -1) + (p_data.SomethingWickedPData.isSplendorful and 0 or 1)
    local speedMult = mod:Lerp(3, 18, multer)
    local position = mod:DynamicOrbit(familiar, player, speedMult, Vector(45, 45))
    familiar.Velocity = position - familiar.Position

    local rotate = mod:GetAngleDegreesButGood((player.Position - position):Rotated(-90))
    local sprite = familiar:GetSprite()
    familiar.SpriteRotation = rotate

    local alpha = mod:Clamp(p_data.SomethingWickedPData.splendorTimer / 14 , 0, 1)
    sprite.Color = Color(1, 1, 1, player:GetHearts() < player:GetEffectiveMaxHearts() and alpha or 1)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, GabeSwordUpdate, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)