local mod = SomethingWicked
local game = Game()

local RoomCount, BFFRoomCount = 8, 6

local function UpdateFamiliar(_, familiar)
    local player = familiar.Player
    local sprite = familiar:GetSprite()

    local playerhasBFF = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    if familiar.RoomClearCount >= (playerhasBFF and BFFRoomCount or RoomCount) then
        familiar.RoomClearCount = 0

        local pool = game:GetItemPool()
        local room = game:GetRoom()
        local itemConfig = Isaac.GetItemConfig()

        local poolType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
        if poolType == -1 then poolType = ItemPoolType.POOL_TREASURE end

        local collectible = -1
        while collectible == -1 do
            local newCollectible = pool:GetCollectible(poolType)
            local conf = itemConfig:GetCollectible(newCollectible)
            if conf:HasTags(ItemConfig.TAG_SUMMONABLE) then
                collectible = newCollectible
                 game:GetHUD():ShowItemText(player, conf)
            end
        end
        player:AddItemWisp(collectible, familiar.Position, true)
    end
    if familiar.Velocity.X > 0 then
        sprite.FlipX = true
    elseif familiar.Velocity.X < 0 then
        sprite.FlipX = false
    end

    familiar:FollowParent()
end

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, UpdateFamiliar, FamiliarVariant.SOMETHINGWICKED_SOLOMON)
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    familiar:AddToFollowers()
end, FamiliarVariant.SOMETHINGWICKED_SOLOMON)