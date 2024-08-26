local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local time = 90
time=time*30
function mod:AddDisItem(player, isActuallyDis, pool, pos)
    if isActuallyDis == nil then
        isActuallyDis = true
    end
    local p_data = player:GetData()
    local collectible = mod:GetCollectibleWithArgs(function (conf, id)
        return conf.Type ~= ItemType.ITEM_ACTIVE and conf:HasTags(ItemConfig.TAG_SUMMONABLE) and (isActuallyDis or id ~= mod.ITEMS.ACHERON)
    end, pool)
    p_data.WickedPData.disItems = p_data.WickedPData.disItems or {}
    table.insert(p_data.WickedPData.disItems, {
        id = collectible,
        time = 0,
        dis = isActuallyDis,
        position = pos,
        readyToProcess = false,
    })
end

local function PickupItem(_, type, _, firstTime, _, _, player)
    if not player:HasCollectible(mod.ITEMS.DIS) or not firstTime then
        return
    end

    local iconf = Isaac.GetItemConfig()
    local item = iconf:GetCollectible(type)

    if item:HasTags(ItemConfig.TAG_QUEST) then
        return
    end
    mod:AddDisItem(player)
end

local maxDisOrbitals, disOrbitSpeed, orbitDistance, groundOffset = 10, 2, 80, Vector(0, -16)
local disYellow = Color(1, 1, 0) local disRed = Color(1, 0, 0)
local disOffsetYellow = Color(1, 1, 1, 0.635, 0.5, 0.5) local disOffsetRed = Color(1, 1, 1, 0.635, 0.5)
local function PlayerUpdate(_, player)
    local p_data = player:GetData()
    local reset = p_data.sw_resetDis
    if p_data.WickedPData.disItems then
        p_data.WickedPData.disRenderData = p_data.WickedPData.disRenderData or {}
        local madeFunnySoundThisFrame = false
        local iConfig = Isaac.GetItemConfig()
        local rng = player:GetCollectibleRNG(mod.ITEMS.DIS)

        for i = 1, #p_data.WickedPData.disItems, 1 do
            local tab = p_data.WickedPData.disItems[i]
            if tab ~= nil then
                if tab.readyToProcess then
                    tab.time = tab.time + 1
                else
                    local effect = tab.gainEffect
                    if tab.dis then
                        if not effect then
                            for j = 1, maxDisOrbitals, 1 do
                                if p_data.WickedPData.disRenderData[j] == nil then
                                    tab.renderIdx = j

                                    effect = mod:SpawnStandaloneItemPopup(tab.id, mod.ItemPopupSubtypes.DIS_FUNNY_MOMENTS, player.Position, player)
                                    --effect.SpriteScale = Vector(0.66, 0.66)
                                    effect.SpriteOffset = groundOffset
                                    local colorLerp = rng:RandomFloat()
                                    effect.Color = Color.Lerp(disOffsetYellow, disOffsetRed, colorLerp)

                                    local renderTab = {
                                        gainEffect = effect,
                                        color = Color.Lerp(disYellow, disRed, colorLerp),
                                        orbitOffset = 36 * (j-1),
                                        mainIdx = i
                                    }
                                    p_data.WickedPData.disRenderData[j] = renderTab
                                    effect:GetData().sw_disTargetPos = (Vector.FromAngle(renderTab.orbitOffset + (p_data.sw_disRenderOrbit or 0)):Resized(orbitDistance) + player.Position)

                                    tab.gainEffect = effect
                                    sfx:Play(SoundEffect.SOUND_SOUL_PICKUP)
                                    goto finishedUnProcess
                                end

                            end
                            tab.readyToProcess = true
                        end
                    else
                        if (not effect and tab.position) then
                            effect = mod:SpawnStandaloneItemPopup(tab.id, mod.ItemPopupSubtypes.MOVE_TO_PLAYER, tab.position, player)
                            sfx:Play(SoundEffect.SOUND_MEATY_DEATHS, 0.8, 0)
                            effect:MakeBloodPoof()
                            tab.gainEffect = effect
                            tab.position = nil
                        end
                    end
                    if tab.position == nil and (effect == nil or not effect:Exists()) then
                        tab.readyToProcess = true
                        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
                        game:GetHUD():ShowItemText(player, iConfig:GetCollectible(tab.id))
                        if tab.dis then
                            if tab.renderIdx then
                                sfx:Play(SoundEffect.SOUND_DEATH_CARD)
                            end
                        else
                            sfx:Play(SoundEffect.SOUND_DEATH_CARD)
                        end
                        --do on gain item vfx stuff here ig
                    end
                end
                ::finishedUnProcess::

                if (not tab.dis and tab.time > time) or (tab.dis and reset) then
                    table.remove(p_data.WickedPData.disItems, i)
                    i = i - 1

                    if tab.dis then
                        if tab.renderIdx then
                            local effect = p_data.WickedPData.disRenderData[tab.renderIdx].effect
                            local explode = Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.WISP_EXPLODE, 0, effect.Position + effect.PositionOffset, Vector.Zero, effect)
                            explode.DepthOffset = 20
                            sfx:Play(SoundEffect.SOUND_DEMON_HIT, 0.8, 0)
                            local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position+effect.PositionOffset, Vector.Zero, effect)
                            poof.Color = p_data.WickedPData.disRenderData[tab.renderIdx].color
                            poof.SpriteScale = Vector(0.5, 0.5)
                            effect:Remove()
                            p_data.WickedPData.disRenderData[tab.renderIdx] = nil
                        end
                    else
                        mod:QueueItemPopUp(player, tab.id)
                    end
                    if not madeFunnySoundThisFrame then
                        madeFunnySoundThisFrame = true
                        sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0)
                    end
                else
                    p_data.WickedPData.disItems[i] = tab
                end
            end
        end

        p_data.sw_disRenderOrbit = (p_data.sw_disRenderOrbit or 0) + disOrbitSpeed
        for key, renderTab in pairs(p_data.WickedPData.disRenderData) do
            if not renderTab.orbitVector then
                renderTab.orbitVector = Vector.FromAngle(renderTab.orbitOffset + p_data.sw_disRenderOrbit):Resized(orbitDistance + (rng:RandomFloat()*45))
            else
                renderTab.orbitVector = renderTab.orbitVector:Rotated(disOrbitSpeed)
            end
            renderTab.renderPos = player.Position + renderTab.orbitVector

            if renderTab.gainEffect and renderTab.gainEffect:Exists() then
                local e_data = renderTab.gainEffect:GetData()
                e_data.sw_disTargetPos = renderTab.renderPos - groundOffset
            else

                if renderTab.effect == nil or not renderTab.effect:Exists() then
                    
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 
                mod.EFFECTS.DIS_WISP, 0, renderTab.renderPos+groundOffset, Vector.Zero, nil)
                effect.Color = renderTab.color
                effect:GetSprite():Play("Idle")
                effect.SpriteOffset = groundOffset
                renderTab.effect = effect

                if renderTab.gainEffect then
                    renderTab.gainEffect = nil
                    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, effect.Position, Vector.Zero, effect)
                    poof.Color = renderTab.color
                    poof.SpriteScale = Vector(0.75, 0.75)
                end
                end
            end

            if renderTab.effect then
                local effect = renderTab.effect
                effect.Position = renderTab.renderPos
            end
            p_data.WickedPData.disRenderData[key] = renderTab
        end
    end
    p_data.sw_resetDis = nil
end

local function EnemyDies(_, enemy)
    local allP = mod:AllPlayersWithCollectible(mod.ITEMS.ACHERON)
    for _, player in ipairs(allP) do
        local dmg = enemy.MaxHitPoints
        local p_data = player:GetData()

        p_data.WickedPData.acheronCharge = (p_data.WickedPData.acheronCharge or 0) + dmg
        local neededCharge = mod:Current45VoltCharge()*6
        while p_data.WickedPData.acheronCharge > neededCharge do
            p_data.WickedPData.acheronCharge = p_data.WickedPData.acheronCharge - neededCharge
            mod:AddDisItem(player, false, ItemPoolType.POOL_DEVIL, enemy.Position)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, PickupItem) --FUUUUUTUUUUUUUUUUUUUURE
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, EnemyDies)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player, data)
    if data.WickedPData.disItems then
        for _, value in ipairs(data.WickedPData.disItems) do
            if value.readyToProcess then
                mod:AddItemWispForEval(player, value.id)
            end
        end
    end
end)