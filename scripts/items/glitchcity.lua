local this = {}
CollectibleType.SOMETHINGWICKED_GLITCHCITY = Isaac.GetItemIdByName("GLITCHCITY")
EffectVariant.SOMETHINGWICKED_GLITCHED_TILE = Isaac.GetEntityVariantByName("Glitchcity Glitched Tile")
local mod = SomethingWicked
local game = Game()

local chancePerItem = 0.005
local chanceToTurn = 1
local blacklist = {CollectibleType.SOMETHINGWICKED_GLITCHCITY, CollectibleType.COLLECTIBLE_MISSINGNO}
function this:PlayerUpdate(player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_GLITCHCITY) then
        local stacks = player:GetCollectibleNum(CollectibleType.SOMETHINGWICKED_GLITCHCITY)
        local mult = stacks * chancePerItem

        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_GLITCHCITY)
        local float = rng:RandomFloat()
        if mult > float then
            local room = game:GetRoom()
            local width = room:GetGridWidth() * 40
            local height = room:GetGridHeight() * 40
            local randomPos = Vector( math.max(80, rng:RandomInt(width-40)), math.max(80, rng:RandomInt(height-40))) + Vector(0, 80)
            randomPos = room:GetClampedGridIndex(randomPos)
            randomPos = room:GetGridPosition(randomPos)

            local glitchedTile = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_GLITCHED_TILE, 0, randomPos, Vector.Zero, player):ToEffect()
            glitchedTile.Timeout = 170
        end

        if game.TimeCounter % (30*90) == 0 then
            if float < chanceToTurn then
                --based off of the code for that one DDLC item in fiendfolio
                local iconfig = Isaac.GetItemConfig()
                local allItemIds = iconfig:GetCollectibles().Size - 1

                local items = {}
                for i = 1, allItemIds, 1 do
                    local item = iconfig:GetCollectible(i)
                    if item ~= nil and not item.Hidden and not item:HasTags(ItemConfig.TAG_QUEST) and item.Type ~= ItemType.ITEM_ACTIVE
                    and not mod:UtilTableHasValue(blacklist, i) then
                        for ii = 1, player:GetCollectibleNum(i), 1 do
                            table.insert(items, i)
                        end
                    end
                end

                items = mod:UtilShuffleTable(items, rng)

                local unlockySod = items[1]
                if unlockySod == nil then
                    return
                end
                player:RemoveCollectible(unlockySod)
                player:AnimateCollectible(unlockySod , "LiftItem", "PlayerPickupSparkle")

                mod:UtilScheduleForUpdate(function ()
                    local conf = iconfig:GetCollectible(CollectibleType.SOMETHINGWICKED_GLITCHCITY)
                    player:AnimateCollectible(CollectibleType.SOMETHINGWICKED_GLITCHCITY, "Pickup", "PlayerPickupSparkle")
                    player:QueueItem(conf, conf.InitCharge)
                    game:GetHUD():ShowItemText(player, conf)
                    mod.sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK)

                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)
                    local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, player.Position, Vector.Zero, player)
                end, 13)
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, this.PlayerUpdate)

local damage = 8
function this:EffectUpdate(effect)
    if effect.FrameCount % 2 == 0 then
        local nearbyEnemies = Isaac.FindInRadius(effect.Position, 17, EntityPartition.ENEMY)
        for index, value in ipairs(nearbyEnemies) do
            value:TakeDamage(damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(effect), 1)
        end
    end
    local nearbyProjs = Isaac.FindInRadius(effect.Position, 30, EntityPartition.BULLET)
    for index, value in ipairs(nearbyProjs) do
        if effect.Position:DistanceSquared(value.Position + value.PositionOffset) < 28^2 then
            value:Die()
        end
    end

    local sprite = effect:GetSprite()
    if sprite:IsFinished("Appear") then
        sprite:Play("Idle")
    end
    if effect.FrameCount == 150 then
        sprite:Play("Disappear")
        mod.sfx:Play(SoundEffect.SOUND_BUTTON_PRESS, 1)
    end
    if sprite:IsFinished("Disappear") then
        effect:Remove()
    end
end


local spritePaths = { 
    "supermariomaker",
    "white",
    "six",
    "bricks",
    "DPsbrainlump",
    "theanswer",
    "grassy",
    "monolith",
}
function this:EffectInit(effect)
    local directory = "gfx/effects/glitchcity/"
    local e_rng = effect:GetDropRNG()
    local sprite = effect:GetSprite()
    mod.sfx:Play(SoundEffect.SOUND_LASERRING_WEAK)
    effect.DepthOffset = 1000

    for i = 0, 3, 1 do
        local path = directory..SomethingWicked:GetRandomElement(spritePaths, e_rng)..".png"
        sprite:ReplaceSpritesheet(i, path)
    end
    game:SpawnParticles(effect.Position, EffectVariant.ROCK_PARTICLE, 2, 3, Color(100, 100, 100))
    sprite:LoadGraphics()
    sprite:Play("Appear", true)

    local room = game:GetRoom()
    local grid = room:GetGridEntityFromPos(effect.Position)
    if grid then
        grid:Destroy()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, this.EffectInit, EffectVariant.SOMETHINGWICKED_GLITCHED_TILE)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, this.EffectUpdate, EffectVariant.SOMETHINGWICKED_GLITCHED_TILE)

this.EIDEntries = {
    [CollectibleType.SOMETHINGWICKED_GLITCHCITY] = {
        desc = "Periodically spawns \"Glitched Tiles\" while held, which destroy rocks, block projectiles and damage enemies"..
        "#!!! While held, every minute and a half, another random item held will turn into GLITCHCITY",
        pools = {
            SomethingWicked.encyclopediaLootPools.POOL_SECRET,
            SomethingWicked.encyclopediaLootPools.POOL_GREED_SECRET
        }
    }
}
return this