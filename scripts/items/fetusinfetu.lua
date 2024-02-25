this.maxCharge = 8
this.poofGreen = Color(0, 0.25, 0)
this.bloodGreen = Color(0, 1, 0, 1, 0, 0.15, 0)

function this:UseItem(_, _, player)
    for _, wisp in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.WISP, mod.ITEMS.FETUS_IN_FETU)) do
        player:ThrowBlueSpider(wisp.Position, Vector.Zero)
        wisp:Kill()
    end
    local p_data = player:GetData()

    local position = ((p_data.somethingwicked_fetusinfetu_deathPos) and p_data.somethingwicked_fetusinfetu_deathPos or player.Position)
    local boner = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_TERATOMA_ORBITAL, 0, position, Vector.Zero, player)
    boner:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    SomethingWicked.game:SpawnParticles(position, EffectVariant.BLOOD_PARTICLE, 3, 3, this.bloodGreen)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, position, Vector.Zero, player)
    poof.Color = this.poofGreen
    local bloodSplat = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_SPLAT, 0, position, Vector.Zero, player)
    bloodSplat.Color = this.bloodGreen

    SomethingWicked.sfx:Play(SoundEffect.SOUND_SPLATTER)
    p_data.somethingwicked_fetusinfetu_deathPos = nil
    return true
end

function this:OnNPCKill(enemy)
    local allPlayers = SomethingWicked.ItemHelpers:AllPlayersWithCollectible(mod.ITEMS.FETUS_IN_FETU)
    for _, player in ipairs(allPlayers) do
        local charge, slot = SomethingWicked.ItemHelpers:CheckPlayerForActiveData(player, mod.ITEMS.FETUS_IN_FETU)
        if charge < this.maxCharge * 2 then
            player:SetActiveCharge(charge + 1, slot)
    
            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position - Vector(0, 60), Vector.Zero, player)
            local p_data = player:GetData()
            p_data.somethingwicked_fetusinfetu_deathPos = enemy.Position
            SomethingWicked.game:GetHUD():FlashChargeBar(player, slot)
            SomethingWicked.sfx:Play(SoundEffect.SOUND_BEEP)
        end
    end
end

function this:ResetPos()
    for index, value in ipairs(SomethingWicked:UtilGetAllPlayers()) do
        local p_data = value:GetData()
        p_data.somethingwicked_fetusinfetu_deathPos = nil
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_USE_ITEM, this.UseItem, mod.ITEMS.FETUS_IN_FETU)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, this.OnNPCKill)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, this.ResetPos)

this.EIDEntries = {
    [mod.ITEMS.FETUS_IN_FETU] = {
        desc = "Spawns 1 teratoma orbital on use#Teratoma orbitals will die upon taking any damage, projectiles will pierce through them, but they will spawn spiders on room clear#Gains 1 charge on killing enemies, can overcharge",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"Spawns 1 teratoma orbital on use","Teratoma orbitals will die upon taking any damage, projectiles will pierce through them, but they will spawn spiders on room clear","Gains 1 charge on killing enemies, can overcharge"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_ROTTEN_BEGGAR
        }
    }
}
return this