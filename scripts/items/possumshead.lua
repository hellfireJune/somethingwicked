local this = {}

function this:UseItem(_, _, player)
    if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) ~= true then
        local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_ORBITAL, 0, player.Position, Vector.Zero, player)
        bone.Parent = player
    end
    local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
    for _, e in ipairs(pickups) do
        local pickup = e:ToPickup()
        if pickup.Variant ~= PickupVariant.PICKUP_COLLECTIBLE
        and pickup:CanReroll() 
        and pickup:IsShopItem() ~= true then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                local wisp = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, CollectibleType.SOMETHINGWICKED_POSSUMS_HEAD, pickup.Position, Vector.Zero, player)
                wisp.Parent = player
            else
                local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_ORBITAL, 0, pickup.Position, Vector.Zero, player)
                bone.Parent = player
            end
            pickup:Remove()
        end
    end
end

function  this:OnWispDie(entity)
    if entity.Variant == FamiliarVariant.WISP and entity.SubType == CollectibleType.SOMETHINGWICKED_POSSUMS_HEAD then
            local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BONE_ORBITAL, 0, entity.Position, Vector.Zero, entity.Parent)
            bone.Parent = entity.Parent
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_POSSUMS_HEAD)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, this.OnWispDie, EntityType.ENTITY_FAMILIAR)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_POSSUMS_HEAD] = {
        desc = "Converts pickups into bone orbitals#Spawns one bone orbital on use",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Converts pickups in the room to bone orbitals on use","Spawns one bone orbital on use"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_ROTTEN_BEGGAR
        }
    }
}
return this