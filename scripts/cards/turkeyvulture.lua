local this = {}
--Card.SOMETHINGWICKED_TURKEY_VULTURE = Isaac.GetCardIdByName("TurkeyVulture")
SomethingWicked.MachineVariant.MACHINE_TERATOMA_BEGGAR = Isaac.GetEntityVariantByName("Teratoma Beggar")
SomethingWicked.MachineVariant.MACHINE_VOID_BEGGAR = Isaac.GetEntityVariantByName("Void Beggar")
this.TeratomaBeggarActiveChance = 0.25
this.VoidBeggarActiveChance = 1 --0.25

SomethingWicked.SlotHelpers:Init({
    slotVariant = SomethingWicked.MachineVariant.MACHINE_TERATOMA_BEGGAR, 
    isBeggar = true,

    functionCanPlay = function (player, slot)
        return this:TeratomaBeggarCanPlay(player, slot)
    end,
    functionOnPlay = function (player, amount, slot)
        return this:TeratomaBeggarOnPlay(player, amount, slot)
    end,

    animNamePlaying = "PayNothing",
    animFramesPlaying = 27,
    animNameDeath = "Teleport",
    animNamePayout = "Prize",
    animEventDeath = "Disappear"
})
SomethingWicked.SlotHelpers:Init({
    slotVariant = SomethingWicked.MachineVariant.MACHINE_VOID_BEGGAR,
    isBeggar = true,
    isEvilBeggar = true,

    functionCanPlay = function (player, slot)
        return this:VoidBeggarCanPlay(player, slot)
    end,
    functionOnPlay = function (player, amount, slot)
        return this:VoidBeggarOnPlay(player, amount, slot)
    end,
    
    animNamePlaying = "PayNothing",
    animFramesPlaying = 27,
    animNameDeath = "Teleport",
    animNamePayout = "Prize",
    animEventDeath = "Disappear"
})

function this:TeratomaBeggarCanPlay(player, slot)
    return SomethingWicked.SlotHelpers:BaseCoinCanPlay(player, slot, this.TeratomaBeggarActiveChance)
end

this.teratomaPayoutChances = {
    [1] = 0.2, --teratoma orbitals
    [2] = 0.2, -- bone orbitals
    [3] = 0.35, --spiders
    [4] = 0.075, --bone heart
    [5] = 0.1 --rotten/morbid heart
}
function this:TeratomaBeggarOnPlay(player, amount, slot)
    amount = 1--amount / this.TeratomaBeggarActiveChance
    local v_rng = slot:GetDropRNG()
    if amount < this.teratomaPayoutChances[1] + this.teratomaPayoutChances[2] then
        local boneVariant = FamiliarVariant.BONE_ORBITAL
        if amount < this.teratomaPayoutChances[1] then
            boneVariant = FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL
        end
        local bones = v_rng:RandomInt(3) + 1
        for i = 1, bones, 1 do
            local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, boneVariant, 0, slot.Position, Vector.Zero, player)
            bone.Parent = player
        end
        return
    end
    if amount < this.teratomaPayoutChances[1] + this.teratomaPayoutChances[2] + this.teratomaPayoutChances[3] then
        
        local spiders = v_rng:RandomInt(3) + 1
        for i = 1, spiders, 1 do
            local payoutVector = SomethingWicked.SlotHelpers:GetPayoutVector(v_rng)
            player:ThrowBlueSpider(slot.Position, slot.Position + (payoutVector * 6))
        end
        return
    end
    if amount < this.teratomaPayoutChances[1] + this.teratomaPayoutChances[2] + this.teratomaPayoutChances[3] + this.teratomaPayoutChances[4] + this.teratomaPayoutChances[5] then
        local payoutVector = SomethingWicked.SlotHelpers:GetPayoutVector(v_rng)
        local heartType = HeartSubType.HEART_ROTTEN
        if amount < this.teratomaPayoutChances[1] + this.teratomaPayoutChances[2] + this.teratomaPayoutChances[3] + this.teratomaPayoutChances[4] then
            heartType = HeartSubType.HEART_BONE
        elseif FiendFolio then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, FiendFolio.PICKUP.VARIANT.MORBID_HEART, 0, slot.Position, payoutVector, slot)
            return
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, heartType, slot.Position, payoutVector, slot)
        return
    end
    
    local collectible = SomethingWicked.ItemHelpers:RandomItemFromCustomPool(SomethingWicked.ItemPoolEnum.TERATOMA_BEGGAR, v_rng)
    if collectible == -1 then
        collectible = SomethingWicked.game:GetItemPool():GetCollectible(ItemPoolType.POOL_BEGGAR, true)
    end
    local room = SomethingWicked.game:GetRoom()
    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, collectible, room:FindFreePickupSpawnPosition(slot.Position), Vector.Zero, player)
    return true
end

--Void Beggar Time
function this:VoidBeggarCanPlay(player, slot)
    player:TakeDamage(0.5, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 30)
    local s_data = slot:GetData()
    s_data.PersistantBeggarData.TimesSpentMoneyOn = (s_data.PersistantBeggarData.TimesSpentMoneyOn or 0) + 1
    
    local v_rng = slot:GetDropRNG()
    local rndmFloat = v_rng:RandomFloat()
    if rndmFloat <= this.VoidBeggarActiveChance
    then
        return rndmFloat
    end
    return 0
end

function this:VoidBeggarOnPlay(player, amount, slot)
    amount = amount / this.VoidBeggarActiveChance
    local v_rng = slot:GetDropRNG()
end

this.EIDEntries = {
    --[[[Card.SOMETHINGWICKED_TURKEY_VULTURE] = { 
        desc = "kils"
    }]]
}
return this