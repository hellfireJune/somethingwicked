local mod = SomethingWicked
local payoutChance = 1

local function VoidBeggarCanPlay(player, slot)
    player:TakeDamage(0.5, DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG, EntityRef(player), 30)
    local s_data = slot:GetData()
    s_data.PersistantBeggarData.TimesSpentMoneyOn = (s_data.PersistantBeggarData.TimesSpentMoneyOn or 0) + 1
    
    local v_rng = slot:GetDropRNG()
    local rndmFloat = v_rng:RandomFloat()
    if rndmFloat <= payoutChance
    then
        return rndmFloat / payoutChance
    end
    return 0
end

local function VoidBeggarOnPlay(player, amount, slot)
    local v_rng = slot:GetDropRNG()
end
mod:InitSlotData({
    slotVariant = SomethingWicked.MachineVariant.MACHINE_VOID_BEGGAR,
    isBeggar = true,
    isEvilBeggar = true,

    functionCanPlay = function (player, slot)
        return VoidBeggarCanPlay(player, slot)
    end,
    functionOnPlay = function (player, amount, slot)
        return VoidBeggarOnPlay(player, amount, slot)
    end,
    
    animNamePlaying = "PayNothing",
    animFramesPlaying = 27,
    animNameDeath = "Teleport",
    animNamePayout = "Prize",
    animEventDeath = "Disappear"
})