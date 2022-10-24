local this = {}
Card.SOMETHINGWICKEDTHOTH_THE_AEON_REVERSED = Isaac.GetCardIdByName("TheAeonReversed")
SomethingWicked.MachineVariant.MACHINE_INFINITEBEGGAR = Isaac.GetEntityVariantByName("Infinite Beggar")

function this:UseCard(_, player)
    local room = SomethingWicked.game:GetRoom()
    local machine = Isaac.Spawn(EntityType.ENTITY_SLOT, SomethingWicked.MachineVariant.MACHINE_INFINITEBEGGAR, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player) 
    
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, machine.Position + Vector(machine.Size, 0), Vector.Zero, machine)
    poof.Color = Color(0.1, 0.1, 0.1)
    poof.SpriteScale = Vector(1.5, 1.5)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 2, 0)
end


SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_THE_AEON_REVERSED)

SomethingWicked.SlotHelpers:Init({
    slotVariant = SomethingWicked.MachineVariant.MACHINE_INFINITEBEGGAR,
    isBeggar = true,

    functionCanPlay = function (player, slot)
        return this:InfiniteBeggarCanPlay(player, slot)
    end,
    functionOnPlay = function (player, amount, slot)
        return this:InfiniteBeggarOnPlay(player, amount, slot)
    end,
    
    animNamePlaying = "PayNothing",
    animFramesPlaying = 27,
    animNameDeath = "Teleport",
    animNamePayout = "Prize",
    animEventDeath = "Disappear"
})

function this:InfiniteBeggarCanPlay(player, slot)
    local s_data = slot:GetData()
    local chance = (s_data.PersistantBeggarData.TimesSpentMoneyOn or 0) / 100
    return SomethingWicked.SlotHelpers:BaseCoinCanPlay(player, slot, chance)
end

local availableSlots = {
    SomethingWicked.MachineVariant.MACHINE_SLOT,
    SomethingWicked.MachineVariant.MACHINE_BLOOD,
    SomethingWicked.MachineVariant.MACHINE_FORTUNE,
    SomethingWicked.MachineVariant.MACHINE_BEGGAR,
    SomethingWicked.MachineVariant.MACHINE_DEVIL_BEGGAR,
    SomethingWicked.MachineVariant.MACHINE_SHELL_GAME,
    SomethingWicked.MachineVariant.MACHINE_KEYMASTER,
    SomethingWicked.MachineVariant.MACHINE_BOMBBUM,
    SomethingWicked.MachineVariant.MACHINE_RESTOCK,
    SomethingWicked.MachineVariant.MACHINE_BATTERY_BUM,
    SomethingWicked.MachineVariant.MACHINE_HELL_GAME,
    SomethingWicked.MachineVariant.MACHINE_CRANE_GAME,
    SomethingWicked.MachineVariant.MACHINE_TERATOMA_BEGGAR,
    SomethingWicked.MachineVariant.MACHINE_VOID_BEGGAR,
    SomethingWicked.MachineVariant.MACHINE_VOIDBLOOD,
    SomethingWicked.MachineVariant.MACHINE_BEGGAR_ROTTEN,
    SomethingWicked.MachineVariant.MACHINE_CONFESSIONAL,
}
function this:InfiniteBeggarOnPlay(player, amount, slot)
    local s_data = slot:GetData()
    local timesToSpawnMachine = s_data.PersistantBeggarData.TimesSpentMoneyOn / 6
    
    if timesToSpawnMachine % 6 < 3 then
        timesToSpawnMachine = math.floor(timesToSpawnMachine)
    else
        timesToSpawnMachine = math.ceil(timesToSpawnMachine)
    end

    local rng = slot:GetDropRNG()
    local pos = slot.Position
    this:SpawnMachine(timesToSpawnMachine, 0, pos, rng)
    return true
end

function this:SpawnMachine(timesToSpawnMachine, delay, pos, rng)
    SomethingWicked:UtilScheduleForUpdate(function ()
        local type = SomethingWicked:GetRandomElement(availableSlots, rng)
        local room = SomethingWicked.game:GetRoom()
        local machine = Isaac.Spawn(EntityType.ENTITY_SLOT, type, 0, room:FindFreePickupSpawnPosition(pos, 40, true), Vector.Zero, nil) 
    
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, machine.Position + Vector(machine.Size, 0), Vector.Zero, machine)
        poof.SpriteScale = Vector(1.5, 1.5)
        SomethingWicked.sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 2, 0)

        timesToSpawnMachine = timesToSpawnMachine - 1
        if timesToSpawnMachine > 0 then
            this:SpawnMachine(timesToSpawnMachine, 5, pos, rng)
        end
    end, delay, ModCallbacks.MC_POST_UPDATE)
end

this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_THE_AEON_REVERSED] = {
        desc = "Spawns a crazy little guy"
    }
}
return this