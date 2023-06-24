local this = {}
 
function this:PostPlayerUpdate()
    local flag, player = SomethingWicked.ItemHelpers:GlobalPlayerHasTrinket(TrinketType.SOMETHINGWICKED_VOID_HEART)
    if flag and player then
        local allBloodMachines = Isaac.FindByType(EntityType.ENTITY_SLOT, SomethingWicked.MachineVariant.MACHINE_BLOOD)

        for _, machine in ipairs(allBloodMachines) do
            local nMachine = Isaac.Spawn(EntityType.ENTITY_SLOT, SomethingWicked.MachineVariant.MACHINE_VOIDBLOOD, 0, machine.Position, Vector.Zero, player) 
            machine:Remove()
            
            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, nMachine.Position + Vector(machine.Size, 0), Vector.Zero, nMachine)
            poof.Color = Color(0.1, 0.1, 0.1)
            poof.SpriteScale = Vector(1.5, 1.5)
            SomethingWicked.sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 2, 0)
        end
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_UPDATE, this.PostPlayerUpdate)

this.EIDEntries = {
    [TrinketType.SOMETHINGWICKED_VOID_HEART] = {
        isTrinket = true,
        desc = "!!! Turns all blood donation machines into void blood donation machines",
        encycloDesc = "Turns all blood donation machines into void blood donation machines"
    }
}
return this