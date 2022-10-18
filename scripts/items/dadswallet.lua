local this = {}
CollectibleType.SOMETHINGWICKED_DADS_WALLET = Isaac.GetItemIdByName("Lost Wallet")
TrinketType.SOMETHINGWICKED_MEAL_COUPON = Isaac.GetTrinketIdByName("Meal Coupon")

this.PickupCollisionChecks = {
    [PickupVariant.PICKUP_HEART] = {
        [HeartSubType.HEART_HALF] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_FULL] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_SCARED] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_DOUBLEPACK] = function(player) return player:CanPickRedHearts() end,
        [HeartSubType.HEART_SOUL] = function(player) return player:CanPickSoulHearts() end,
        [HeartSubType.HEART_HALF_SOUL] = function(player) return player:CanPickSoulHearts() end,
        [HeartSubType.HEART_BLACK] = function(player) return player:CanPickBlackHearts() end,
        [HeartSubType.HEART_GOLDEN] = function(player) return player:CanPickGoldenHearts() end,
        [HeartSubType.HEART_BLENDED] = function(player) if not player:CanPickRedHearts() then return player:CanPickSoulHearts() end return true end,
        [HeartSubType.HEART_BONE] = function(player) return player:CanPickBoneHearts() end,
        [HeartSubType.HEART_ROTTEN] = function(player) return player:CanPickRottenHearts() end,
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = function (player)
        return player:NeedsCharge()
    end 
}
function this:PickupCollision(pickup, player)
    if not pickup:IsShopItem()
    or pickup.Price ~= PickupPrice.PRICE_FREE then
        return
    end

    player = player:ToPlayer()
    if player then
        local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_DADS_WALLET)
        local pickupFunction = this.PickupCollisionChecks[pickup.Variant]
        local flag
        if pickupFunction ~= nil then
            flag = ((type(pickupFunction) == "function" and pickupFunction(player) or pickupFunction[pickup.SubType](player)))
        else flag = true end

        if slot ~= -1 and charge > 0 and flag and player:CanPickupItem() and player:IsExtraAnimationFinished() then
            player:SetActiveCharge(charge - 1, slot)
            if charge == 1 then
                player:RemoveCollectible(CollectibleType.SOMETHINGWICKED_DADS_WALLET)
            end
        end
    end
end

function this:PickupUpdate(pickup)
    if not pickup:IsShopItem() then
        return
    end

    if SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_DADS_WALLET) then
        if pickup.Price > 0 then
            pickup.Price = PickupPrice.PRICE_FREE
        end
    end
end

function this:UseItem()
    return { Discharge = false}
end

function this:HeartUpdate(pickup)
    if not pickup:IsShopItem() then
        return
    end

    if SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_MEAL_COUPON) then
        if pickup.Price > 0 then
            pickup.Price = PickupPrice.PRICE_FREE
        end
    end
end

this.hasInitCHAPIHook = false
this.chapiPickupUpdateFunction = nil
function this:RunStart()
    if not this.hasInitCHAPIHook then
        this:InitCHAPIHook()
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, this.RunStart)

function this:InitCHAPIHook()
    this.hasInitCHAPIHook = true
    if not CustomHealthAPI then
        return
    end

    this.chapiPickupUpdateFunction = CustomHealthAPI.Helper.GetPriceOfPickup
    CustomHealthAPI.Helper.GetPriceOfPickup = function (pickup, force)
        if (SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_MEAL_COUPON)
        and pickup.Variant == PickupVariant.PICKUP_HEART) or SomethingWicked.ItemHelpers:GlobalPlayerHasCollectible(CollectibleType.SOMETHINGWICKED_DADS_WALLET) then
            return PickupPrice.PRICE_FREE
        end
        return this.chapiPickupUpdateFunction(pickup, force)
    end
end
if SomethingWicked.game:GetFrameCount() > 0 then
    this:InitCHAPIHook()
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, this.HeartUpdate, PickupVariant.PICKUP_HEART)

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, this.PickupUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, CollectibleType.SOMETHINGWICKED_DADS_WALLET)
SomethingWicked:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, this.PickupCollision)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_DADS_WALLET] = {
        desc = "All shop items will act as if they are free#Picking up a shop item will remove 1 charge from this#Upon losing all charges this item will dissapear",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_OLD_CHEST,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"All shop items will act as if they are free","Picking up a shop item will remove 1 charge from this","Upon losing all charges this item will dissapear"})
    }
}
return this