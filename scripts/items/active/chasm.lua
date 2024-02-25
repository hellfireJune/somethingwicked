local mod = SomethingWicked
local sfx = SFXManager()

local tearColor = Color(0.25, 0.25, 0.25, 1, 0.1, 0.1, 0.5)
local smokeColors = {Color(0, 0, 0), Color(0, 0, 0, 1, 0.25, 0.25, 1)}

local function UseItem(_, _, _, player)
    local stacksToAdd = 0
    local itemsInRoom = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)

    for _, item in ipairs(itemsInRoom) do
        item = item:ToPickup()
        if item.SubType > 0
        and (not item:IsShopItem() or item.Price == PickupPrice.PRICE_FREE) then
            item:Remove()
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, item.Position, Vector.Zero, item)
            poof.Color = tearColor
            sfx:Play(SoundEffect.SOUND_BLACK_POOF, 1, 0)
            if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
                player:AddWisp(mod.ITEMS.CHASM, player.Position)
            end

            stacksToAdd = stacksToAdd + 1
        end
    end

    local qItem = player.QueuedItem.Item
    if qItem
    and qItem:IsCollectible() then
        mod:RemoveQueuedItem(player)
        stacksToAdd = stacksToAdd + 1
    end

    local p_data = player:GetData()
    p_data.SomethingWickedPData.chasmStacks = (p_data.SomethingWickedPData.chasmStacks or 0) + stacksToAdd
    return true
end

local function FireTear(_, tear)
    local player = SomethingWicked:UtilGetPlayerFromTear(tear)
    if player then
        local p_data = player:GetData()
        if p_data.SomethingWickedPData.chasmStacks then
            local rng = player:GetCollectibleRNG(mod.ITEMS.CHASM)
            local rndmFloat = rng:RandomFloat()
            --the scientfic notation flex
            if rndmFloat < p_data.SomethingWickedPData.chasmStacks*(10^-1) then
                --tear:ChangeVariant(TearVariant.SOMETHINGWICKED_LOCUST_CLUSTER_TEAR)
                tear.CollisionDamage = tear.CollisionDamage * 2.6
                tear.Color = tearColor
            end
        end
    end
end
local function PlayerUpdate(_, player)
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
            trail.Color = SomethingWicked:GetRandomElement(smokeColors, rng)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, FireTear)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.CHASM)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)