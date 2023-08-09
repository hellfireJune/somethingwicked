local this = {}

function this:UseCard(_, player)
    local room = SomethingWicked.game:GetRoom()
    local machine = Isaac.Spawn(EntityType.ENTITY_SLOT, SomethingWicked.MachineVariant.MACHINE_VOIDBLOOD, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, player) 
    
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, machine.Position + Vector(machine.Size, 0), Vector.Zero, machine)
    poof.Color = Color(0.1, 0.1, 0.1)
    poof.SpriteScale = Vector(1.5, 1.5)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 2, 0)
end


SomethingWicked:AddCallback(ModCallbacks.MC_USE_CARD, this.UseCard, Card.SOMETHINGWICKEDTHOTH_THE_AEON)

this.EIDEntries = {
    [Card.SOMETHINGWICKEDTHOTH_THE_AEON] = {
        desc = "Spawns a void blood machine"
    }
}
return this