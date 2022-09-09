local this = {}
CollectibleType.SOMETHINGWICKED_OLD_DICE = Isaac.GetItemIdByName("Old Dice")
this.effect = Isaac.GetEntityVariantByName("Dice Overhead VFX")
this.BaseMaxCharge = 2

function this:OnUse(_, rngObj, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        return
    end

    local queuedItem = player.QueuedItem.Item
    if not (queuedItem and queuedItem:IsCollectible()) then
        return { Discharge = false, ShowAnim = true }
    end

    local pool = SomethingWicked.game:GetItemPool()
    local room = SomethingWicked.game:GetRoom()
    local itemConfig = Isaac.GetItemConfig()
    
    local poolType = pool:GetPoolForRoom(room:GetType(), room:GetAwardSeed())
    if poolType == -1 then poolType = ItemPoolType.POOL_TREASURE end

    local collectible = -1
    while collectible == -1 do
        local newCollectible = pool:GetCollectible(poolType, true)
        local conf = itemConfig:GetCollectible(newCollectible)
        if conf.Type ~= ItemType.ITEM_ACTIVE then
            collectible = newCollectible
        end
    end

    --Thanks to the REP+ team. Thanks.
    SomethingWicked.ItemHelpers:RemoveQueuedItem(player)

    local conf = itemConfig:GetCollectible(collectible)
    SomethingWicked.game:GetHUD():ShowItemText(player, conf)
    local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_OLD_DICE)

    if conf.Type == ItemType.ITEM_ACTIVE
    --[[and slot <= 1]] then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
        return true
    else 
        player:AnimateCollectible(collectible, "Pickup", "PlayerPickupSparkle")
        player:QueueItem(conf, conf.InitCharge)
    end

end

function this:OnFixedUpdate(player)
    local item = player.QueuedItem.Item
    if item == nil then
        return
    end

    local oldDices = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.SOMETHINGWICKED_OLD_DICE, true)
    local dice = nil
    if item.Type == ItemType.ITEM_ACTIVE
    and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == 0 then
        for _, v in ipairs(oldDices) do
            v = v:ToPickup()
            if v.Charge >= this.BaseMaxCharge then
                dice = v
                break
            end
        end
    end

    if ((SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_OLD_DICE) >= this.BaseMaxCharge)
    or dice ~= nil) then
        local dEffects = Isaac.FindByType(EntityType.ENTITY_EFFECT, this.effect, -1, true)

        local flag = true
        for index, dEffect in ipairs(dEffects) do
            if GetPtrHash(dEffect.Parent) == GetPtrHash(player) then
                flag = false
            end
        end

        if flag then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, this.effect, 0, player.Position, Vector.Zero, player)
            effect.Parent = player
            effect.SpriteOffset = Vector(0, -40)

            effect:GetSprite():Play("Appear", true)
        end


        --once again i thank agent cucco and the job mod
        if dice then
            local buttonToPress = ButtonAction.ACTION_ITEM
            local noDrop = true
            local pType = player:GetPlayerType()

            if pType == PlayerType.PLAYER_JACOB
            or pType == PlayerType.PLAYER_ESAU then
                noDrop = false
                if pType == PlayerType.PLAYER_ESAU then
                    buttonToPress = ButtonAction.ACTION_POCKET
                end
            end

            if Input.IsActionPressed(buttonToPress, player.ControllerIndex)
            and (noDrop or not Input.IsActionPressed(ButtonAction.ACTION_DROP, player.ControllerIndex)) then
                player:UseActiveItem(CollectibleType.SOMETHINGWICKED_OLD_DICE, 0, -1)
                player:AddCollectible(CollectibleType.SOMETHINGWICKED_OLD_DICE, dice.Charge - this.BaseMaxCharge, false)

                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, dice.Position, Vector.Zero, dice)
                poof.Color = Color(0.1, 0.1, 0.1)
                dice:Remove()
            end
        end
    end
end

function this:OnEffectUpdate(effect)
    local player = effect.Parent:ToPlayer()
    local sprite = effect:GetSprite()
    
    if (player == nil or
    player.QueuedItem.Item == nil or
    (SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, CollectibleType.SOMETHINGWICKED_OLD_DICE) < this.BaseMaxCharge
    and player.QueuedItem.Item.Type ~= ItemType.ITEM_ACTIVE)) then
        sprite:Play("Dissapear")
    elseif sprite:IsPlaying("Appear") 
    and sprite:GetFrame() == 6 then
        sprite:Play("Idle")
    elseif sprite:IsFinished("Disappear") then
        effect:Remove()
    end

    effect:FollowParent(effect.Parent)
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.OnFixedUpdate)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.OnEffectUpdate, this.effect)
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.OnUse, CollectibleType.SOMETHINGWICKED_OLD_DICE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_OLD_DICE] = {
        desc = "Upon use, rerolls the current item being picked up into a random passive item# Does nothing if you are not picking up an item#If dropped to pick up another active, can be used while you are picking up the active",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SHOP,
            SomethingWicked.encyclopediaLootPools.POOL_CRANE_GAME
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Upon use, rerolls the current item being picked up into a random passive item", "Does nothing if you are not picking up an item","If dropped to pick up another active, can be used while you are picking up the active"}),
    }
}
return this