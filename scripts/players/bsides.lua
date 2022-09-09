local this = {}
--CollectibleType.SOMETHINGWICKED_MIRROR_SHARD = Isaac.GetItemIdByName("Mirror Shard")
this.Eden = include("scripts/players/bsides_scripts/eden")

SomethingWicked.enums.MachineVariant.MACHINE_BSIDE_CHEST = Isaac.GetEntityVariantByName("BSideinator")

SomethingWicked.SlotHelpers:Init({
    slotVariant = SomethingWicked.enums.MachineVariant.MACHINE_BSIDE_CHEST,
    functionCanPlay = function(player, slot)
        return this:CanPlay(player, slot)
    end,
    functionOnPlay = function (player, payoutAmount, slot)
        return this:OnPlay(player, payoutAmount, slot)
    end
})

function this:CanPlay(player, slot)
    local playerType = player:GetPlayerType()
    if SomethingWicked.BSides[playerType] then
        return 1
    end
end

function this:OnPlay(player, payoutAmount, slot)
    if payoutAmount ~= 1 then
        return
    end

    local p_data = player:GetData()
    local playerType = player:GetPlayerType()
    local bSide = SomethingWicked.BSides[playerType]

    if bSide.func then
        return bSide.func(player)
    end
    local itemsToRemove = {}
    local itemsToAdd = {}
    local bSideHP = {}
    if p_data.SomethingWickedPData.isBSide then
        p_data.SomethingWickedPData.isBSide = false

        itemsToRemove = bSide.BSideItems
        itemsToAdd = bSide.ASideItems
    else
        p_data.SomethingWickedPData.isBSide = true

        itemsToRemove = bSide.ASideItems
        itemsToAdd = bSide.BSideItems
    end
    bSideHP = bSide.BSideHP

    for _, value in ipairs(itemsToRemove) do
        if type(value) == "table" then
            value = value[1]
        end
        _, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, value)
        player:RemoveCollectible(value, false, math.max(slot, ActiveSlot.SLOT_PRIMARY))
    end
    local itemConf = Isaac.GetItemConfig()
    for _, value in ipairs(itemsToAdd) do
        if type(value) == "table"
        and value.pocketItem then
            player:SetPocketActiveItem(value[1], ActiveSlot.SLOT_POCKET, false)
        else
            local item = itemConf:GetCollectible(value)
            player:AddCollectible(value, item.MaxCharges)
        end 
    end

    if bSideHP then
        local mult = p_data.SomethingWickedPData.isBSide and 1 or -1

        if bSideHP.bhearts ~= nil then
            player:AddBlackHearts(bSideHP.bhearts * mult)
        end
        if bSideHP.mhearts ~= nil then
            player:AddMaxHearts(bSideHP.mhearts * mult)
            player:AddHearts(bSideHP.mhearts * mult)
        end
    end

    return p_data.SomethingWickedPData.isBSide
end

SomethingWicked.BSides = {
    [PlayerType.PLAYER_ISAAC] = {
        ASideItems = {
            CollectibleType.COLLECTIBLE_D6
        },
        BSideItems = {
            { CollectibleType.SOMETHINGWICKED_OLD_DICE, 
            pocketItem = true}
        },
    },
    [PlayerType.PLAYER_JUDAS] = {
        ASideItems = {
            CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL
        },
        BSideItems = {
            CollectibleType.SOMETHINGWICKED_BOOK_OF_LUCIFER
        },
        BSideHP = {bhearts = 2, mhearts = -2}
    },
    [PlayerType.PLAYER_APOLLYON] = {
        ASideItems = {
            CollectibleType.COLLECTIBLE_VOID
        },
        BSideItems = {CollectibleType.SOMETHINGWICKED_CHASM},
        BSideHP = {bhearts = 6, mhearts = -4}
    },
    [PlayerType.PLAYER_EDEN] = {
        func = function (player)
            return this.Eden:SwapToBSideFunction(player)
        end
    }
}