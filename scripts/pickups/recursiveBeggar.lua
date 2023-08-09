local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local payoutChance = 0.2

local function SpawnMachine(timesToSpawnMachine, delay, pos, rng)
    local type = mod:GetRandomElement(mod.CONST.InfinityBeggarMachinePool, rng)
    local room = game:GetRoom()
    local machine = Isaac.Spawn(EntityType.ENTITY_SLOT, type, 0, room:FindFreePickupSpawnPosition(pos, 40, true), Vector.Zero, nil) 
    
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, machine.Position + Vector(machine.Size, 0), Vector.Zero, machine)
    poof.SpriteScale = Vector(1.5, 1.5)
    sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 2, 0)

    timesToSpawnMachine = timesToSpawnMachine - 1
    if timesToSpawnMachine > 0 then
        SpawnMachine(timesToSpawnMachine, delay+5, pos, rng)
    end
end

local function InfiniteBeggarOnPlay(player, amount, slot)
    local rng = slot:GetDropRNG()
    local pos = slot.Position
    local s_data = slot:GetData()

    local jackpotChance = ((s_data.PersistantBeggarData.TimesSpentMoneyOn or 0)-24) / 66
    if rng:RandomFloat() < jackpotChance then
        local timesToSpawnMachine = s_data.PersistantBeggarData.TimesSpentMoneyOn / 6
        if timesToSpawnMachine % 6 < 3 then
            timesToSpawnMachine = math.floor(timesToSpawnMachine)
        else
            timesToSpawnMachine = math.ceil(timesToSpawnMachine)
        end

        SpawnMachine(timesToSpawnMachine, 0, pos, rng)
    end
    
    return true
end

mod:InitSlotData({
    slotVariant = mod.MachineVariant.MACHINE_INFINITEBEGGAR,
    isBeggar = true,

    functionCanPlay = function (player, slot)
        return mod:BeggarCoinCanPlay(player, slot, payoutChance)
    end,
    functionOnPlay = function (player, amount, slot)
        return InfiniteBeggarOnPlay(player, amount, slot)
    end,
    
    animNamePlaying = "PayNothing",
    animFramesPlaying = 27,
    animNameDeath = "Teleport",
    animNamePayout = "Prize",
    animEventDeath = "Disappear"
})