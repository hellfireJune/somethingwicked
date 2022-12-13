local this = {}
CollectibleType.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR = Isaac.GetItemIdByName("Justice and Splendor")
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
            p_data.SomethingWickedPData.splendorTimer = p_data.SomethingWickedPData.isSplendorful and 90 or 150
            
            player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
            player:EvaluateItems()
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PEffectUpdate)

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
SomethingWicked:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, this.GabeSwordCache)

function this:GabeSwordInit(familiar)
    familiar:AddToOrbit(30)
    familiar.OrbitDistance = Vector(30, 30)
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, this.GabeSwordInit, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)

function this:GabeSwordUpdate(familiar)
    local player = familiar.Player
    local p_data = player:GetData()
    
    local multer = SomethingWicked:Clamp(p_data.SomethingWickedPData.splendorTimer / 4 , 0, 1)* (p_data.SomethingWickedPData.isSplendorful and 1 or -1) + (p_data.SomethingWickedPData.isSplendorful and 0 or 1)
    local speedMult = SomethingWicked.EnemyHelpers:Lerp(3, 18, multer)
    speedMult = SomethingWicked.EnemyHelpers:Lerp(familiar.OrbitSpeed, speedMult, 0.2)
    familiar.OrbitSpeed = speedMult
    local position = SomethingWicked.FamiliarHelpers:DynamicOrbit(familiar, player)
    familiar.Velocity = position - familiar.Position
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, this.GabeSwordUpdate, FamiliarVariant.SOMETHINGWICKED_JUSTICE_AND_SPLENDOR)

this.EIDEntries = {}
return this