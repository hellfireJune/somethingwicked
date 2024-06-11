local this = {}
local itemSpriteToMachine = {
    [this.formSlot] = SomethingWicked.MachineVariant.MACHINE_SLOT,
    [this.formFortune] = SomethingWicked.MachineVariant.MACHINE_FORTUNE,
    [this.formBlood] = SomethingWicked.MachineVariant.MACHINE_BLOOD,
    --add eternal slot machine also when u make it june :3
}
local slotScrollOrder = {
    [this.formSlot] = this.formFortune,
    [this.formFortune] = this.formBlood,
    [this.formBlood] = this.formSlot,
}

function this:PlayerUpdate(player)
    for index, value in pairs(SomethingWicked.ItemHelpers:GetAllActiveDatasOfType(player, mod.ITEMS.MAGIC_CLAY)) do
        player:RemoveCollectible(mod.ITEMS.MAGIC_CLAY)
        player:AddCollectible(this.formSlot, false, index, value)
    end

    if Input.IsActionTriggered(11, player.ControllerIndex) then
        for i = 0, 3, 1 do
            local coll = player:GetActiveItem(i)

            local itemToScrollto = slotScrollOrder[coll]
            if itemToScrollto then
                local charge = player:GetActiveCharge(i) + player:GetBatteryCharge(i)
                player:RemoveCollectible(coll)
                player:AddCollectible(itemToScrollto, false, i, charge)
            end
        end
    end
end
SomethingWicked:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, this.PlayerUpdate)

function this:UseItem(id, _, player, flags)
    local thingToDo = itemSpriteToMachine[id]
    if not thingToDo then
        return
    end
    local room = SomethingWicked.game:GetRoom()
    local machine = Isaac.Spawn(EntityType.ENTITY_SLOT, thingToDo, 0, room:FindFreePickupSpawnPosition(player.Position, 40, true), Vector.Zero, nil) 

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, machine.Position + Vector(machine.Size, 0), Vector.Zero, machine)
    poof.SpriteScale = Vector(1.5, 1.5)
    SomethingWicked.sfx:Play(SoundEffect.SOUND_SUMMONSOUND, 2, 0)
end
SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem)

this.EIDEntries = {}
return this