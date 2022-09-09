--[[local this = {}
this.heartsVisual = Sprite()
PickupPrice.SOMETHINGWICKED_ONE_HEART_BREAK = -41
PickupPrice.SOMETHINGWICKED_TWO_SOUL_HEART_BREAK = -42

this.HeartFrames = {
    SOMETHINGWICKED_ONE_HEART_BREAK = 1,
    SOMETHINGWICKED_TWO_SOUL_HEART_BREAK = 0
}
this.heartsVisual:Load("gfx/ui/newshopprices.anm2")

function this:FuckShitUp(pickup) 
    if pickup.FrameCount == 1 then
        this:MyCoffinsAllISee(pickup)
    end
end

function this:DontForgetAboutIt(pickup)
    this:MyCoffinsAllISee(pickup)
end

function this:MyCoffinsAllISee(pickup)
    if SomethingWicked:isSmokeShop() 
    and (pickup:IsShopItem() or (SomethingWicked.game:GetRoom():IsFirstVisit() and SomethingWicked.game:GetRoom():GetFrameCount() <= 1)) then
        this:AddNewPickupPrice(this:GetAllPlayerHearts(), pickup)
        pickup.AutoUpdatePrice = false
        pickup.ShopItemId = -1
    end
end

function this:HandleNewPrices(pickup, collider)
    local player = collider:ToPlayer()
    if player and player:IsItemQueueEmpty() and player:CanPickupItem() then
        if (pickup.Price == PickupPrice.SOMETHINGWICKED_ONE_HEART_BREAK and player:GetEffectiveMaxHearts() > 0) or pickup.Price == PickupPrice.SOMETHINGWICKED_TWO_SOUL_HEART_BREAK  then
            player:GetData().SomethingWickedPData.brokenHeartQueued = true
            return nil
        end
        if pickup.Price > PickupPrice.SOMETHINGWICKED_ONE_HEART_BREAK and pickup.Price < PickupPrice.SOMETHINGWICKED_TWO_SOUL_HEART_BREAK then
            
            return nil
        else
            --return false
        end
    end
    return nil
end

function this:ChangeBackdrops(helper)
    if helper.SubType ~= 76 then
        return
    end
    helper.Visible = false
    helper.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    helper:AddEntityFlags(EntityFlag.FLAG_TRANSITION_UPDATE)
    if StageAPI then
        StageAPI.ChangeRoomGfx(SomethingWicked.RoomGFX.SmokeShop)
    end
end

function this:QueueBrokenHeartening(player)
    if player:GetData() and player:GetData().SomethingWickedPData.brokenHeartQueued and player:GetData().SomethingWickedPData.brokenHeartQueued == true 
    and player:IsItemQueueEmpty() == false then
        player:GetData().SomethingWickedPData.brokenHeartQueued = false
        if player:GetEffectiveMaxHearts() > 0 then
            if player:GetMaxHearts() <= 0 then
                player:AddBoneHearts(-2)
            else
                player:AddMaxHearts(-4)
            end
        else 
            player:AddSoulHearts(-8)
        end
        player:AddBrokenHearts(4)
        local totalHearts = this:GetAllPlayerHearts()
        local allItems = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)
        for _, entity in ipairs(allItems) do
            local pickup = entity:ToPickup()
            if pickup:IsShopItem() and pickup.Price <= PickupPrice.SOMETHINGWICKED_ONE_HEART_BREAK and pickup.Price ~= PickupPrice.PRICE_FREE then
                this:AddNewPickupPrice(totalHearts, pickup)
            end
        end
    end
end

function this:RenderPickupCost(pickup)
    if pickup:IsShopItem() and pickup.Price <= PickupPrice.SOMETHINGWICKED_ONE_HEART_BREAK and pickup.Price ~= PickupPrice.PRICE_FREE then
        local renderPos = Isaac.WorldToRenderPosition(pickup.Position)
        if pickup.Price == PickupPrice.SOMETHINGWICKED_ONE_HEART_BREAK then
            this.heartsVisual:SetFrame("Hearts", this.HeartFrames.SOMETHINGWICKED_ONE_HEART_BREAK)
        else
            this.heartsVisual:SetFrame("Hearts", this.HeartFrames.SOMETHINGWICKED_TWO_SOUL_HEART_BREAK)
        end
        
        this.heartsVisual:RenderLayer(0, renderPos)
    end
end


function this:GetAllPlayerHearts()
    local hearts = 0
    for _, player in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        hearts = hearts + player:GetEffectiveMaxHearts()
    end

    return hearts
end

function this:AddNewPickupPrice(totalhearts, pickup) 
    if totalhearts >= 1 then
        pickup.Price = PickupPrice.SOMETHINGWICKED_ONE_HEART_BREAK
    else
        pickup.Price = PickupPrice.SOMETHINGWICKED_TWO_SOUL_HEART_BREAK
    end
end

function SomethingWicked:isSmokeShop()
    local helperCheck = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BED, 76)
    if #helperCheck > 0 then
        return true
    end
    return false
end


SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.ChangeBackdrops, PickupVariant.PICKUP_BED)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, this.FuckShitUp, PickupVariant.PICKUP_COLLECTIBLE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, this.DontForgetAboutIt, PickupVariant.PICKUP_COLLECTIBLE)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.HandleNewPrices, PickupVariant.PICKUP_COLLECTIBLE)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, this.QueueBrokenHeartening)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, this.RenderPickupCost)

if StageAPI then
    SomethingWicked.RoomGroups = {
        Smokeshop = StageAPI.RoomsList("Smokeshop Rooms", include("content/luarooms/smokeshop rooms"))
    }

    function this:NewLevel()
        local level = SomethingWicked.game:GetLevel()

        local roomsList = level:GetRooms()
        for i = 0, roomsList.Size - 1 do
            local roomIndex = i
            local roomDesc = roomsList:Get(i)
            if roomDesc and roomDesc.Data.Type == RoomType.ROOM_SECRET then
                local newRoom = StageAPI.LevelRoom(nil, SomethingWicked.RoomGroups.Smokeshop, nil, RoomShape.ROOMSHAPE_1x1, RoomType.ROOM_SECRET)

                --StageAPI.SetLevelRoom(newRoom, roomIndex)
            end
        end
    end


    SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, this.NewLevel)
end]]