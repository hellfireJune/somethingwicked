local mod = SomethingWicked
local game = Game()

local teratomaPayoutChances = {
    [1] = 0.2, --teratoma orbitals
    [2] = 0.2, -- bone orbitals
    [3] = 0.35, --spiders
    [4] = 0.075, --bone heart
    [5] = 0.1 --rotten/morbid heart
}
local function TeratomaBeggarOnPlay(player, amount, slot)
    amount = 1--amount / TeratomaBeggarActiveChance
    local v_rng = slot:GetDropRNG()
    if amount < teratomaPayoutChances[1] + teratomaPayoutChances[2] then
        local boneVariant = FamiliarVariant.BONE_ORBITAL
        if amount < teratomaPayoutChances[1] then
            boneVariant = FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL
        end
        local bones = v_rng:RandomInt(3) + 1
        for i = 1, bones, 1 do
            local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, boneVariant, 0, slot.Position, Vector.Zero, player)
            bone.Parent = player
        end
        return
    end
    if amount < teratomaPayoutChances[1] + teratomaPayoutChances[2] + teratomaPayoutChances[3] then
        
        local spiders = v_rng:RandomInt(3) + 1
        for i = 1, spiders, 1 do
            local payoutVector = mod:GetPayoutVector(v_rng)
            player:ThrowBlueSpider(slot.Position, slot.Position + (payoutVector * 6))
        end
        return
    end
    if amount < teratomaPayoutChances[1] + teratomaPayoutChances[2] + teratomaPayoutChances[3] + teratomaPayoutChances[4] + teratomaPayoutChances[5] then
        local payoutVector = mod:GetPayoutVector(v_rng)
        local heartType = HeartSubType.HEART_ROTTEN
        if amount < teratomaPayoutChances[1] + teratomaPayoutChances[2] + teratomaPayoutChances[3] + teratomaPayoutChances[4] then
            heartType = HeartSubType.HEART_BONE
        elseif FiendFolio then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, FiendFolio.PICKUP.VARIANT.MORBID_HEART, 0, slot.Position, payoutVector, slot)
            return
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, heartType, slot.Position, payoutVector, slot)
        return
    end
    
    local collectible = mod:RandomItemFromCustomPool(SomethingWicked.ItemPoolEnum.TERATOMA_BEGGAR, v_rng)
    if collectible == -1 then
        collectible = game:GetItemPool():GetCollectible(ItemPoolType.POOL_BEGGAR, true)
    end
    local room = game:GetRoom()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, room:FindFreePickupSpawnPosition(slot.Position), Vector.Zero, player)
    return true
end

SomethingWicked.SlotHelpers:Init({
    slotVariant = SomethingWicked.MachineVariant.MACHINE_TERATOMA_BEGGAR, 
    isBeggar = true,

    functionCanPlay = function (player, slot)
        return mod:BeggarCoinCanPlay(player, slot, 0.2)
    end,
    functionOnPlay = function (player, amount, slot)
        return TeratomaBeggarOnPlay(player, amount, slot)
    end,

    animNamePlaying = "PayNothing",
    animFramesPlaying = 27,
    animNameDeath = "Teleport",
    animNamePayout = "Prize",
    animEventDeath = "Disappear"
})