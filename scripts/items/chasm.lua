local this = {}
CollectibleType.SOMETHINGWICKED_CHASM = Isaac.GetItemIdByName("Chasm")

function this:UseItem(_, _, player)
    local stacksToAdd = 0
    local itemsInRoom = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

    for _, item in ipairs(itemsInRoom) do
        item = item:ToPickup()
        if item.SubType > 0
        and (not item:IsShopItem() or item.Price == PickupPrice.PRICE_FREE) then
            item:Remove()
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, item)
            poof.Color = this.tearColor
            SomethingWicked.sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                player:AddWisp(CollectibleType.SOMETHINGWICKED_CHASM, player.Position)
            end

            stacksToAdd = stacksToAdd + 1
        end
    end

    local qItem = player.QueuedItem.Item
    if qItem
    and qItem:IsCollectible() then
        SomethingWicked.ItemHelpers:RemoveQueuedItem(player)
        stacksToAdd = stacksToAdd + 1
    end

    local p_data = player:GetData()
    p_data.SomethingWickedPData.chasmStacks = (p_data.SomethingWickedPData.chasmStacks or 0) + stacksToAdd
    return true
end

function this:FireTear(tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player then
        local p_data = player:GetData()
        if p_data.SomethingWickedPData.chasmStacks then
            local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_CHASM)
            local rndmFloat = rng:RandomFloat()
            --the scientfic notation flex
            if rndmFloat < p_data.SomethingWickedPData.chasmStacks*(10^-1) then
                --tear:ChangeVariant(TearVariant.SOMETHINGWICKED_LOCUST_CLUSTER_TEAR)
                tear.CollisionDamage = tear.CollisionDamage * 2.6
                tear.Color = this.tearColor
            end
        end
    end
end

this.tearColor = Color(0.25, 0.25, 0.25, 1, 0.1, 0.1, 0.5)
this.smokeColors = {Color(0, 0, 0), Color(0, 0, 0, 1, 0.25, 0.25, 1)}
function this:PlayerUpdate(player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.chasmStacks
    and p_data.SomethingWickedPData.chasmStacks > 0 then
        p_data.somethingwicked_chasmsmoketick = (p_data.somethingwicked_chasmsmoketick or (5 * math.max(1, 10 - p_data.SomethingWickedPData.chasmStacks))) - 1
        --print(p_data.somethingwicked_chasmsmoketick)
        if p_data.somethingwicked_chasmsmoketick <= 0 then
            p_data.somethingwicked_chasmsmoketick = nil

            local trail = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HAEMO_TRAIL, 0, player.Position + Vector(0, -30), RandomVector() * 6, player)
            local rng = trail:GetDropRNG()
            --trail.Position = trail.Position + Vector(-10 + rng:RandomInt(21), -10 + rng:RandomInt(21))
            trail.Color = SomethingWicked:GetRandomElement(this.smokeColors, rng)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, this.FireTear)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_CHASM)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_CHASM] = {
        desc = "↑ Destroys all items in the rooms and gives the user a 10% chance to deal 2.6x damage on anything they fire# !!! No bonus for destroying over 10 items",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Destroys all items in the rooms and gives the user a 10% chance to deal 2.6x damage on anything they fire","No bonus for destroying over 10 items"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE
        }
    }
}
return this