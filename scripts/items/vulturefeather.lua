local this = {}
CollectibleType.SOMETHINGWICKED_VULTURE_FEATHER = Isaac.GetItemIdByName("Vulture Feather")

--TY to the Rep+ team for the GetSprite method of getting it to only run once 
function this:PickupInit(pickup)
    print("d")
    if pickup.SubType ~= HeartSubType.HEART_FULL 
    and pickup.SubType ~= HeartSubType.HEART_HALF 
    and pickup.SubType ~= HeartSubType.HEART_SCARED
    and pickup.SubType ~= HeartSubType.HEART_DOUBLEPACK 
    and pickup.SubType ~= HeartSubType.HEART_BLENDED then
        return
    end

    print("c")
    if not SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_VULTURE_FEATHER) then
        return
    end
    print("b")

    local sprite = pickup:GetSprite()
    if (sprite:IsPlaying("Appear") or sprite:IsPlaying("AppearFast")) 
    and sprite:GetFrame() == 0 then
        print("a")
        local r = pickup:GetDropRNG()
        local f = r:RandomFloat()
        if f < 0.333 then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_BONE, true)
            return
        end
        if f < 0.667 then
            pickup:Remove()
            return
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.PickupInit, PickupVariant.PICKUP_HEART)

this.EIDEntries = {}
return this