local mod = SomethingWicked
local game = Game()
SomethingWicked.slotData = { }

--[[
    Possible Values for the InitData table
    slotVariant: the variant of the slot in entities2.xml. Necessary
    isBeggar: if this is a beggar. default is False.
    isEvilBeggar: if this beggar is evil. default is False.
    removeSubTypesAboveOne: if these should be removed if the subtype is above 1. default is True

    functionCanPlay: the function to determine if the machine should be played. If return value is nil, cannot pay out, else, return the "amount" to pay out. Takes a player argument and the entity argument of the slot.
    funcionOnPlay: the function of what happens when the machine is played. Return true if the machine should explode/the beggar should leave once this has happened. Takes a player argument, a payout amount argument, and the entity argument of the slot.
    functionOnDie: the function of what happens when this entity is killed. Takes a bool argument for if this should spawn an item (for slots), an entity argument for the slot and a player argument
        
    animNameIdle
    animNamePlaying
    animFramesPlaying
    animNamePayout
    animNameDeath
    animFramesDeath
    animNameBroken
    animEventPayout
    animEventDeath
]]
function mod:InitSlotData(initData)
    if initData.slotVariant == nil then
        print("june you bogus youre going to break your slot machines")
        return
    end

    if initData.isBeggar == nil then
        initData.isBeggar = false
    end
    if initData.isEvilBeggar == nil then
        initData.isEvilBeggar = false
    end
    if initData.removeSubTypesAboveOne == nil then
        initData.removeSubTypesAboveOne = true
    end
    initData.animNameIdle = initData.animNameIdle or "Idle"
    initData.animNamePlaying = initData.animNamePlaying or "Wiggle"
    initData.animFramesPlaying = initData.animFramesPlaying or 1
    initData.animNamePayout = initData.animNamePayout or "Prize"
    initData.animEventPayout = initData.animEventPayout or initData.animNamePayout
    initData.animNameDeath = initData.animNameDeath or "Death"
    initData.animFramesDeath = initData.animFramesDeath or 1
    initData.animNameBroken = initData.animNameBroken or "Broken"

    mod.slotData[initData.slotVariant] = initData
end

local function removingStuff(pickup, machine)
    if pickup.FrameCount <= 3
    and machine.Position:Distance(pickup.Position) <= machine.Size + pickup.Size + machine.Velocity:Length() + pickup.Velocity:Length()
    then
        pickup:Remove()
    end
end

local function MachineNewRoom()
    for index, value in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT)) do
        local v_slotData = mod.slotData[value.Variant]
        if v_slotData and v_slotData.removeSubTypesAboveOne and
         value.SubType > 0 then
            value:Remove()
        end
    end
end
local function MachineUpdate(_, player)
    --Like, 90% of this code I nabbed from andromeda's Wisp Wizard
    --Which itself was nabbed from the Harlot Beggar's mod, heh

    --I also took some stuff from AgentCucco's Job mod, for the destruction bit, ty 

    local machiness = Isaac.FindByType(EntityType.ENTITY_SLOT)

    for i, machine in ipairs(machiness) do
        if mod.slotData[machine.Variant] then
            local v_slotData = mod.slotData[machine.Variant]
            local v_sprite = machine:GetSprite()
            local v_data = machine:GetData()

            v_data.PersistantBeggarData = v_data.PersistantBeggarData or mod:BeggarData(machine)
    
            if machine.SubType == 0 then
                if v_sprite:IsPlaying(v_slotData.animNamePlaying) and v_sprite:GetFrame() == v_slotData.animFramesPlaying then 
                    if v_data.somethingWicked_payoutAmount == nil then
                        v_sprite:Play(v_slotData.animNameIdle)
                    else
                        v_sprite:Play(v_slotData.animNamePayout) 
                    end
                end
                if v_sprite:IsFinished(v_slotData.animNamePayout) then v_sprite:Play(v_slotData.animNameIdle) end
    
                if v_sprite:IsEventTriggered(v_slotData.animEventPayout) and v_data.somethingWicked_payoutAmount ~= nil then
                    if v_slotData.functionOnPlay(v_data.somethingWicked_payoutPlayer, v_data.somethingWicked_payoutAmount, machine) then
                        --Dead Machine 
                        v_sprite:Play(v_slotData.animNameDeath)
                        machine.SubType = 1
                        if v_slotData.isBeggar then
                            if v_slotData.functionOnDie then
                                if not v_slotData.functionOnDie(true, machine, v_data.somethingWicked_payoutPlayer) then
                                    local flag = LevelStateFlag.STATE_BUM_LEFT
                                    if v_slotData.isEvilBeggar then
                                        flag = LevelStateFlag.STATE_EVIL_BUM_LEFT
                                    end
                                    game:GetLevel():SetStateFlag(flag, true)
                                end
                            end
                        else
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION, 0, machine.Position, Vector.Zero, machine)
                            SomethingWicked.sfx:Play(SoundEffect.SOUND_EXPLOSION_WEAK, 1, 0)
    
                            if v_slotData.functionOnDie then
                                v_slotData.functionOnDie(true, machine, v_data.somethingWicked_payoutPlayer)
                            end
                        end
                    end
                    v_data.somethingWicked_payoutAmount = nil
                end
    
                if machine.Position:Distance(player.Position) <= player.Size + machine.Size
                and v_sprite:IsPlaying(v_slotData.animNameIdle) then
                    local payoutAmount = v_slotData.functionCanPlay(player, machine)
                    if payoutAmount ~= nil then
                        if payoutAmount  ~= 0 then
                            v_data.somethingWicked_payoutAmount = payoutAmount
                            v_data.somethingWicked_payoutPlayer = player
                        end
                        v_sprite:Play(v_slotData.animNamePlaying)
                    end
                end
            end
            
    
            --On Bombed
            if machine.GridCollisionClass == GridCollisionClass.COLLISION_WALL_EXCEPT_PLAYER
            and machine.SubType ~= 2 then
                if (machine.SubType ~= 1) then
                    if v_slotData.functionOnDie then
                        v_slotData.functionOnDie(false, machine, player)
                    end
                end
                for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
                    removingStuff(pickup, machine)
                end
                for _, pickup in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
                    removingStuff(pickup, machine)
                end
    
                if v_slotData.isBeggar then
                    machine:Kill()
                    local flag = LevelStateFlag.STATE_BUM_KILLED
                    if v_slotData.isEvilBeggar then
                        flag = LevelStateFlag.STATE_EVIL_BUM_KILLED
                    end
                    game:GetLevel():SetStateFlag(flag, true)
                else
                    if (not v_sprite:IsPlaying(v_slotData.animNameDeath))
                    and (not (v_sprite:GetAnimation() == v_slotData.animNameBroken)) then
                        v_sprite:Play(v_slotData.animNameDeath)
                    end
                    machine.SubType = 2
                end
                --now handle the on death stuff here methinks
            end
    
            if (v_slotData.animEventDeath == nil and (v_sprite:IsPlaying(v_slotData.animNameDeath) and v_sprite:GetFrame() == v_slotData.animFramesDeath))
            or (v_slotData.animEventDeath ~= nil and v_sprite:IsEventTriggered(v_slotData.animEventDeath)) then
                if v_slotData.isBeggar then
                    machine:Remove()
                else
                    v_sprite:Play(v_slotData.animNameBroken)
        
                    machine.Size = 0
                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MachineUpdate)
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MachineNewRoom)

--Slot/Beggar Data
SomethingWicked.save.runData.BeggarData = {}

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function (_, ent)
    if ent.Type == EntityType.ENTITY_SLOT
    and mod.slotData[ent.Variant] then
        SomethingWicked.save.runData.BeggarData[""..ent.InitSeed] = ent:GetData().PersistantBeggarData
    end
end)

function mod:BeggarData(machine)
    mod.save.runData.BeggarData = mod.save.runData.BeggarData or {}
    local hash = ""..machine.InitSeed
    if mod.save.runData.BeggarData[hash] then
        return mod.save.runData.BeggarData[hash]
    else
        return {}
    end
end

--Helper Functions
function mod:BeggarCoinCanPlay(player, slot, chance)
    if player:GetNumCoins() > 0 then
        player:AddCoins(-1)
        local s_data = slot:GetData()
        s_data.PersistantBeggarData.TimesSpentMoneyOn = (s_data.PersistantBeggarData.TimesSpentMoneyOn or 0) + 1
        
        local v_rng = slot:GetDropRNG()
        local rndmFloat = v_rng:RandomFloat()
        if rndmFloat <= chance
        and (game.Difficulty ~= Difficulty.DIFFICULTY_HARD or s_data.PersistantBeggarData.TimesSpentMoneyOn > 6) then
            return rndmFloat
        end
        return 0
    end
end