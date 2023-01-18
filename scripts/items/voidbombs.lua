local this = {}
CollectibleType.SOMETHINGWICKED_VOID_BOMBS = Isaac.GetItemIdByName("Void Bombs")
EffectVariant.SOMETHINGWICKED_MOTV_HELPER = Isaac.GetEntityVariantByName("[SW] maw of the void helper")
this.BombSpriteSheet = "gfx/items/pick ups/bombs/costumes/voidbombs.png"

--Most of this code (the bomb related stuff atleast) came from Deliverance, ty to those devs very much

local function FetusProcChance(player)
    return 0.2 + (0.026 * player.Luck)
end

function this:BombUpdate(bomb)
    if not bomb.SpawnerEntity then
        return
    end
    local player = bomb.SpawnerEntity:ToPlayer()
    if player == nil then
        return
    end

    local bombData = bomb:GetData()
    local sprite = bomb:GetSprite()
    if bomb.FrameCount == 1 then
        SomethingWicked.ItemHelpers:ShouldConvertBomb(bomb, player, CollectibleType.SOMETHINGWICKED_VOID_BOMBS, this.BombSpriteSheet, "isVoidBomb", FetusProcChance(player))
    elseif bombData.isVoidBomb then
        if sprite:IsPlaying("Explode") then
            local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_MOTV_HELPER, 0, bomb.Position, Vector.Zero, player)
            local void = Isaac.Spawn(EntityType.ENTITY_LASER, 1, LaserSubType.LASER_SUBTYPE_RING_FOLLOW_PARENT, bomb.Position, Vector.Zero, player):ToLaser()
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