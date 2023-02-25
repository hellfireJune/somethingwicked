local this = {}
CollectibleType.SOMETHINGWICKED_FUZZY_FLY = Isaac.GetItemIdByName("Fuzzy Fly")
FamiliarVariant.SOMETHINGWICKED_FUZZY_FLY = Isaac.GetEntityVariantByName("Fuzzy Fly Familiar")

local fuzzRadius = 200
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    familiar:MoveDiagonally(1)

    local nearbyProjectiles = Isaac.FindInRadius(familiar.Position, fuzzRadius, EntityPartition.BULLET)
    for index, bullet in ipairs(nearbyProjectiles) do
        local b_data = bullet:GetData()
        b_data.somethingWicked_shouldFuzzyThisFrame = true
    end
end, FamiliarVariant.SOMETHINGWICKED_FUZZY_FLY)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function (_, proj)
    
end)