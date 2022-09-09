local this = {}
CollectibleType.SOMETHINGWICKED_VOID_BOMBS = Isaac.GetItemIdByName("Void Bombs")

--Most of this code (the bomb related stuff atleast) came from Deliverance, ty to those devs very much

function this:BombUpdate(bomb)
    if bomb:GetData().isVoidBomb then
        if bomb:GetSprite():IsPlaying("Explode") then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, -1, -1, bomb.Position, Vector.Zero, bomb.SpawnerEntity)
            local void = Isaac.Spawn(EntityType.ENTITY_LASER, 1, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, bomb.Position, Vector.Zero, bomb.SpawnerEntity):ToLaser()
            effect.Visible = false
            void.Parent = effect
            void.Radius = 80
            void.Timeout = 76
            void:AddTearFlags(TearFlags.TEAR_PULSE)
            void.CollisionDamage = bomb.ExplosionDamage / 12
            SomethingWicked.sfx:Play(SoundEffect.SOUND_MAW_OF_VOID, 1, 0)
        end
    end
end

function this:bombInit(bomb)
    if bomb.SpawnerType == EntityType.ENTITY_PLAYER 
    and bomb.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.SOMETHINGWICKED_VOID_BOMBS) then
        if (bomb.Variant > 4 or bomb.Variant < 3) then
            if bomb.Variant == 0 then
                bomb.Variant = 7001
            end
        end
        bomb:GetData().isVoidBomb = true
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, this.bombInit)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, this.BombUpdate)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_VOID_BOMBS] = {
        desc = "↑ +5 bombs #Bombs spawn a Maw of The Void ring upon exploding",
        encycloDesc = SomethingWicked:UtilGenerateWikiDesc({"+5 bombs on pickup", "Bombs spawn a Maw of the Void ring upon exploding"}),
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_DEVIL,
            SomethingWicked.encyclopediaLootPools.POOL_BOMB_BUM
        }
    }
}
return this