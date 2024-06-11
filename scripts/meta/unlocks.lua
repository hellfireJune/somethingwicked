local mod = SomethingWicked

function mod:IncrementStonesOfThePitUsed()
    mod.save.PITSTONE_USED = (mod.save.PITSTONE_USED or 0) + 1
    
    if mod.save.PITSTONE_USED >= 2 then
        local psgd = Isaac.GetPersistentGameData()
        psgd:TryUnlock(mod.ACHIEVEMENTS.ADDER_STONE)
    end
end

function mod:PostStartGame()
    mod.save.WICKED_RUNS = (mod.save.WICKED_RUNS or 0) + 1

    if mod.save.WICKED_RUNS >= 5 then
        local psgd = Isaac.GetPersistentGameData()
        psgd:TryUnlock(mod.ACHIEVEMENTS.BOLTS_OF_LIGHT)
    end
end