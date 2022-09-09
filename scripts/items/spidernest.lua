local this = {}
EffectVariant.SOMETHINGWICKED_SPIDER_EGG = Isaac.GetEntityVariantByName("Spider Egg")
CollectibleType.SOMETHINGWICKED_SPIDER_EGG = Isaac.GetItemIdByName("Spider Egg")
this.framesToSpawnEggs = 165
this.SpiderCap = 7

function this:IsFiring(player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_SPIDER_EGG) then
        return
    end

    local p_data = player:GetData()
    p_data.SomethingWickedPData.spiderEgg_FireCountdown = math.max((p_data.SomethingWickedPData.spiderEgg_FireCountdown or 0) + (player:GetFireDirection() ~= Direction.NO_DIRECTION and 1 or -1), 0)

    if p_data.SomethingWickedPData.spiderEgg_FireCountdown >= this.framesToSpawnEggs then
        p_data.SomethingWickedPData.spiderEgg_FireCountdown = 0

        if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_SPIDER) >= this.SpiderCap then
            return
        end
        local testEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_SPIDER_EGG, 0, player.Position, RandomVector() * 6, player):ToEffect()
        testEffect.FallingSpeed = 10
        testEffect.FallingAcceleration = -0.75
        testEffect.Parent = player

        SomethingWicked.sfx:Play(SoundEffect.SOUND_BOIL_HATCH, 0.5, 0)
    end
end

function this:UpdateEffect(effect)
    effect.FallingSpeed = effect.FallingSpeed + effect.FallingAcceleration
    effect.m_Height = effect.m_Height + effect.FallingSpeed
    effect.SpriteOffset = Vector(0, -1) * effect.m_Height

    if effect.m_Height < -10 then
        SomethingWicked.game:SpawnParticles(effect.Position, EffectVariant.BLOOD_PARTICLE, 3, 3, Color(1, 1, 1, 1, 1, 1, 1))

        local player = effect.Parent:ToPlayer()
        if player then
            player:AddBlueSpider(effect.Position)
        end

        effect:Remove()
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.IsFiring)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.UpdateEffect, EffectVariant.SOMETHINGWICKED_SPIDER_EGG)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_SPIDER_EGG] = {
        desc = "↑ While firing, will spawn a spider egg every "..(this.framesToSpawnEggs / 30).." seconds, which spawns a blue spider on landing",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_TREASURE,
            SomethingWicked.encyclopediaLootPools.POOL_ROTTEN_BEGGAR,
            SomethingWicked.encyclopediaLootPools.POOL_KEY_MASTER,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_TREASURE,
        },
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"While firing, will spawn a spider egg every "..(this.framesToSpawnEggs / 30).." seconds, which spawns a blue spider on landing"})
    }
}
return this