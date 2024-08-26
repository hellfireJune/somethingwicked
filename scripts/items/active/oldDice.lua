local mod = SomethingWicked
local game = Game()
local baseMaxCharge = 2

local function OnUse(_, _, rngObj, player, flags)
    if flags & UseFlag.USE_CARBATTERY ~= 0 then
        return
    end

    local queuedItem = player.QueuedItem.Item
    if not (queuedItem and queuedItem:IsCollectible()) then
        return { Discharge = false, ShowAnim = true }
    end

    local itemConfig = Isaac.GetItemConfig()
    local pool = game:GetItemPool()
    local room = game:GetRoom()
    local collectible = mod:GetCollectibleWithArgs(function (conf)
        return conf.Type ~= ItemType.ITEM_ACTIVE
    end)
    --Thanks to the REP+ team. Thanks.
    --mod:RemoveQueuedItem(player)
    player:ClearQueueItem()

    local conf = itemConfig:GetCollectible(collectible)
    game:GetHUD():ShowItemText(player, conf)
    pool:RemoveCollectible(collectible)
    local charge, slot = mod:CheckPlayerForActiveData(player, mod.ITEMS.OLD_DICE)

    if conf.Type == ItemType.ITEM_ACTIVE
    --[[and slot <= 1]] then
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, room:FindFreePickupSpawnPosition(player.Position), Vector.Zero, player)  
        return true
    else 
        player:AnimateCollectible(collectible, "Pickup", "PlayerPickupSparkle")
        player:QueueItem(conf, conf.InitCharge)
    end

end

local function OnFixedUpdate(_, player)
    local item = player.QueuedItem.Item
    if item == nil then
        return
    end

    local oldDices = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, mod.ITEMS.OLD_DICE, true)
    local dice = nil
    if item.Type == ItemType.ITEM_ACTIVE
    and player:GetActiveItem(ActiveSlot.SLOT_PRIMARY) == 0 then
        for _, v in ipairs(oldDices) do
            v = v:ToPickup()
            if v.Charge >= baseMaxCharge then
                dice = v
                break
            end
        end
    end

    if ((mod:CheckPlayerForActiveData(player, mod.ITEMS.OLD_DICE) >= baseMaxCharge)
    or dice ~= nil) then
        local dEffects = Isaac.FindByType(EntityType.ENTITY_EFFECT, mod.EFFECTS.DICE_OVERHEAD, -1, true)

        local flag = true
        for index, dEffect in ipairs(dEffects) do
            if GetPtrHash(dEffect.Parent) == GetPtrHash(player) then
                flag = false
            end
        end

        if flag then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.DICE_OVERHEAD, 0, player.Position, Vector.Zero, player)
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
                player:UseActiveItem(mod.ITEMS.OLD_DICE, 0, -1)
                player:AddCollectible(mod.ITEMS.OLD_DICE, dice.Charge - baseMaxCharge, false)

                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, dice.Position, Vector.Zero, dice)
                poof.Color = Color(0.1, 0.1, 0.1)
                dice:Remove()
            end
        end
    end
end

local function OnEffectUpdate(_, effect)
    local player = effect.Parent:ToPlayer()
    local sprite = effect:GetSprite()

    if (player == nil or
    player.QueuedItem.Item == nil or
    (mod:CheckPlayerForActiveData(player, mod.ITEMS.OLD_DICE) < baseMaxCharge
    and player.QueuedItem.Item.Type ~= ItemType.ITEM_ACTIVE)) then
        sprite:Play("Dissapear")
    elseif sprite:IsPlaying("Appear") 
    and sprite:GetFrame() == 6 then
        sprite:Play("Idle")
    end
    if sprite:GetFrame() == 5  
    and sprite:GetAnimation() == "Dissapear" then
        effect:Remove()
    end

    effect:FollowParent(effect.Parent)
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, OnFixedUpdate)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnEffectUpdate, mod.EFFECTS.DICE_OVERHEAD)
mod:AddCallback(ModCallbacks.MC_USE_ITEM, OnUse, mod.ITEMS.OLD_DICE)
