local this = {}
local mod = SomethingWicked
CollectibleType.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR = Isaac.GetItemIdByName("Swords of Light")
FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR = Isaac.GetEntityVariantByName("Splendorous Sword")

function this:PEffectUpdate(player)
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
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)

function this:GabeSwordCache(player, flags)
    if flags == CacheFlag.CACHE_FAMILIARS then
        local stacks, rng, sourceItem = SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, CollectibleType.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)
        if player:HasCollectible(CollectibleType.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR) then
            local p_data = player:GetData()
            if p_data.SomethingWickedPData.isSplendorful
            or player:GetHearts() >= player:GetEffectiveMaxHearts() then
                stacks = stacks + 1
            else
                stacks = 0
            end
        end
        player:CheckFamiliar(FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR, stacks, rng, sourceItem)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.GabeSwordCache)

function this:GabeSwordInit(familiar)
    familiar:AddToOrbit(30)
    familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    familiar.OrbitSpeed = 0
    
    local player = familiar.Player
    local rotate = mod.EnemyHelpers:GetAngleDegreesButGood((player.Position - familiar.Position):Rotated(-90))
    local sprite = familiar:GetSprite()
    sprite.Rotation = rotate
    familiar.SpriteOffset = Vector(0, -10)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.GabeSwordInit, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)

function this:GabeSwordUpdate(familiar)
    local player = familiar.Player
    local p_data = player:GetData()
    p_data.SomethingWickedPData.splendorTimer = p_data.SomethingWickedPData.splendorTimer or 0
    
    local multer = mod:Clamp(p_data.SomethingWickedPData.splendorTimer / 7 , 0, 1)* (p_data.SomethingWickedPData.isSplendorful and 1 or -1) + (p_data.SomethingWickedPData.isSplendorful and 0 or 1)
    local speedMult = mod.EnemyHelpers:Lerp(3, 18, multer)
    local position = mod.FamiliarHelpers:DynamicOrbit(familiar, player, speedMult, Vector(45, 45))
    familiar.Velocity = position - familiar.Position

    local rotate = mod.EnemyHelpers:GetAngleDegreesButGood((player.Position - position):Rotated(-90))
    local sprite = familiar:GetSprite()
    familiar.SpriteRotation = rotate

    local alpha = mod:Clamp(p_data.SomethingWickedPData.splendorTimer / 14 , 0, 1)
    sprite.Color = Color(1, 1, 1, player:GetHearts() < player:GetEffectiveMaxHearts() and alpha or 1)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.GabeSwordUpdate, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR] = {
        desc = "↑ Every 3 seconds, spawns 2 sword familiars that orbit the player that deal 45 contact damage per second#The swords will remain for 4 seconds after spawn#"..
        "The swords will stay permanently if Isaac has no damaged red heart containers, but will move slower when they would be gone",
        encycloDesc = mod:UtilGenerateWikiDesc({"Every 3 seconds, spawns 2 sword familiars that orbit the player that deal 45 contact damage per second","The swords will remain for 4 seconds after spawn",
        "The swords will stay permanently if Isaac has no damaged red heart containers, but will move slower when they would be gone"}),
        pools = { mod.encyclopediaLootPools.POOL_ANGEL, mod.encyclopediaLootPools.POOL_BABY_SHOP, mod.encyclopediaLootPools.POOL_GREED_ANGEL}
    }
}
return this