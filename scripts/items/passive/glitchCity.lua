local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local chanceToTurn = 1
local blacklist = {mod.ITEMS.GLITCHCITY, CollectibleType.COLLECTIBLE_MISSINGNO}
function mod:glitchCityTick(player)
    if player:HasCollectible(mod.ITEMS.GLITCHCITY) then
        local stacks = player:GetCollectibleNum(mod.ITEMS.GLITCHCITY)
        local p_data = player:GetData()
        p_data.sw_glitchCityTimer = (p_data.sw_glitchCityTimer or 170) - (stacks+0.2)
        --print(p_data.sw_glitchCityTimer, stacks, (stacks*10))
        
        local room = game:GetRoom()
        if room:GetFrameCount() <= 0 then
            p_data.sw_glitchCityTimer = math.min(p_data.sw_glitchCityTimer, 20)
        end

        local rng = player:GetCollectibleRNG(mod.ITEMS.GLITCHCITY)
        if p_data.sw_glitchCityTimer < 0 then
            while p_data.sw_glitchCityTimer < 0 do
                local target = mod:FindNearestVulnerableEnemy(player.Position)
                local randomPos = player.Position + RandomVector()*rng:RandomFloat()*200
                if target and target.Position:Distance(player.Position) > 240 then
                    target = nil
                elseif target then
                    randomPos = mod:Lerp(randomPos,
                    target.Position + (math.max((rng:RandomFloat()*target.Size)-28, 00)*(RandomVector()+Vector(0, -1))), rng:RandomFloat())
                end

                randomPos = room:GetClampedGridIndex(randomPos)
                randomPos = room:GetGridPosition(randomPos)

                local glitchedTile = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.GLITCHED_TILE, 0, randomPos, Vector.Zero, player):ToEffect()
                glitchedTile.Timeout = 170
                p_data.sw_glitchCityTimer = p_data.sw_glitchCityTimer + 170
            end
        end

        if game.TimeCounter % (30*90) == 0 then
            local float = rng:RandomFloat()
            if float < chanceToTurn then
                --based off of the code for that one DDLC item in fiendfolio
                local iconfig = Isaac.GetItemConfig()
                --local allItemIds = iconfig:GetCollectibles().Size - 1

                local allItemsHeld = player:GetCollectiblesList() 
                local items = {}
                for i,v in pairs(allItemsHeld) do
                    local item = iconfig:GetCollectible(i)
                    if item ~= nil and not item.Hidden and not item:HasTags(ItemConfig.TAG_QUEST) and item.Type ~= ItemType.ITEM_ACTIVE
                    and not mod:UtilTableHasValue(blacklist, i) then
                        for ii = 1, v, 1 do
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
                    local conf = iconfig:GetCollectible(mod.ITEMS.GLITCHCITY)
                    player:AnimateCollectible(mod.ITEMS.GLITCHCITY, "Pickup", "PlayerPickupSparkle")
                    player:QueueItem(conf, conf.InitCharge)
                    game:GetHUD():ShowItemText(player, conf)
                    sfx:Play(SoundEffect.SOUND_CHOIR_UNLOCK)

                    player:MakeGroundPoof ()
                end, 13)
            end
        end
    end
end

mod:AddPeffectCheck(function (p)
    return p:HasCollectible(mod.ITEMS.GLITCHCITY)
end, mod.glitchCityTick)

local damage = 60
local function EffectUpdate(_, effect)
    local room = game:GetRoom()
    local pos = room:GetClampedGridIndex(effect.Position)
    pos = room:GetGridPosition(pos)
    local sprite = effect:GetSprite()
    if sprite:IsPlaying("Idle") then
        
        local nearbyEnemies = Isaac.FindInRadius(pos, 17, EntityPartition.ENEMY)
        if #nearbyEnemies > 0 then
            sprite:Play("Disappear")
            sfx:Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_BURST, 0.5)
        end
        for index, ent in ipairs(nearbyEnemies) do
            ent:TakeDamage(damage, DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(effect), 1)
            --mod:DoKnifeDamage(effect, ent, Isaac.GetPlayer(1), damage)
            
            local veloc = (ent.Position - pos):Normalized()
            local pf = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.GLITCH_POOF, 0, pos+(veloc*40), Vector.Zero, nil)
            pf.Color = Color(1, 0.7, 0)
            pf.DepthOffset = 18
            if not ent:HasEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK) then
                veloc = veloc*15

                ent:AddEntityFlags(EntityFlag.FLAG_KNOCKED_BACK)
                ent:AddVelocity(veloc)

            end
        end
    end
    --[[local nearbyProjs = Isaac.FindInRadius(pos, 60, EntityPartition.BULLET)
    for index, value in ipairs(nearbyProjs) do
        if pos:Distance(value.Position + value.Velocity) < 35 then
            value:Die()
        end
        
        if pos:Distance(value.Position + value.PositionOffset + value.Velocity) < 35 then
            value:Die()
        end
    end]]

    if sprite:IsFinished("Appear") then
        sprite:Play("Idle")
    end
    if effect.FrameCount == 150 then
        sprite:Play("Disappear")
        sfx:Play(SoundEffect.SOUND_BUTTON_PRESS, 1)
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
} -- i want to redo this entirely
local function EffectInit(_, effect)
    local directory = "gfx/effects/glitchcity/"
    local e_rng = effect:GetDropRNG()
    local sprite = effect:GetSprite()
    sfx:Play(SoundEffect.SOUND_LASERRING_WEAK, 0.5)
    --effect.DepthOffset = 1000

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

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, EffectInit, mod.EFFECTS.GLITCHED_TILE)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, EffectUpdate, mod.EFFECTS.GLITCHED_TILE)