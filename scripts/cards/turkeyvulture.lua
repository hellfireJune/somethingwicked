local this = {}
--Card.SOMETHINGWICKED_TURKEY_VULTURE = Isaac.GetCardIdByName("TurkeyVulture")
SomethingWicked.enums.MachineVariant.MACHINE_TERATOMA_BEGGAR = Isaac.GetEntityVariantByName("Teratoma Beggar")
this.TeratomaBeggarActiveChance = 1-- 0.25

SomethingWicked.SlotHelpers:Init({
    slotVariant = SomethingWicked.enums.MachineVariant.MACHINE_TERATOMA_BEGGAR, 
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

function this:TeratomaBeggarCanPlay(player, slot)
    if player:GetNumCoins() > 0 then
        player:AddCoins(-1)
        
        local v_rng = slot:GetDropRNG()
        local rndmFloat = v_rng:RandomFloat()
        if rndmFloat <= this.TeratomaBeggarActiveChance then
            return rndmFloat
        end
        return 0
    end
end

this.payoutChances = {
    [1] = 0.2,
    [2] = 0.2,
    [3] = 0.35,
    [4] = 0.075,
    [5] = 0.1
}
function this:TeratomaBeggarOnPlay(player, amount, slot)
    amount = amount / this.TeratomaBeggarActiveChance
    local v_rng = slot:GetDropRNG()
    if amount < this.payoutChances[1] + this.payoutChances[2] then
        local boneVariant = FamiliarVariant.BONE_ORBITAL
        if amount < this.payoutChances[1] then
            boneVariant = FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL
        end
        local bones = v_rng:RandomInt(3) + 1
        for i = 1, bones, 1 do
            local bone = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, boneVariant, 0, slot.Position, Vector.Zero, player)
            bone.Parent = player
        end
        return
    end
    if amount < this.payoutChances[1] + this.payoutChances[2] + this.payoutChances[3] then
        
        local spiders = v_rng:RandomInt(3) + 1
        for i = 1, spiders, 1 do
            local payoutVector = SomethingWicked.SlotHelpers:GetPayoutVector(v_rng)
            player:ThrowBlueSpider(slot.Position, slot.Position + (payoutVector * 6))
        end
        return
    end
    if amount < this.payoutChances[1] + this.payoutChances[2] + this.payoutChances[3] + this.payoutChances[4] + this.payoutChances[5] then
        local payoutVector = SomethingWicked.SlotHelpers:GetPayoutVector(v_rng)
        local heartType = HeartSubType.HEART_ROTTEN
        if amount < this.payoutChances[1] + this.payoutChances[2] + this.payoutChances[3] + this.payoutChances[4] then
            heartType = HeartSubType.HEART_BONE
        end
        Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, heartType, slot.Position, payoutVector, slot)
        return
    end
    
    return true
end

this.EIDEntries = {
    --[[[Card.SOMETHINGWICKED_TURKEY_VULTURE] = { 
        desc = "kils"
    }]]
}
return this