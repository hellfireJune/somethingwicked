local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local orbitalSprite = Sprite()
orbitalSprite:Load("gfx/effect_wisp_trail.anm2", true)
orbitalSprite:Play("Idle")

local time = 60
time=time*30
function mod:AddDisItem(player, isActuallyDis, pool, pos)
    if isActuallyDis == nil then
        isActuallyDis = true
    end
    local p_data = player:GetData()
    local collectible = mod:GetCollectibleWithArgs(function (conf, id)
        return conf.Type ~= ItemType.ITEM_ACTIVE and conf:HasTags(ItemConfig.TAG_SUMMONABLE) and (isActuallyDis or id ~= CollectibleType.SOMETHINGWICKED_ACHERON)
    end, pool)
    p_data.SomethingWickedPData.disItems = p_data.SomethingWickedPData.disItems or {}
    table.insert(p_data.SomethingWickedPData.disItems, {
        id = collectible,
        time = 0,
        dis = isActuallyDis,
        position = pos,
        readyToProcess = false,
    })
end

local function PickupItem(_, type, _, firstTime, _, _, player)
    if not player:HasCollectible(CollectibleType.SOMETHINGWICKED_DIS) or not firstTime then
        return
    end

    local iconf = Isaac.GetItemConfig()
    local item = iconf:GetCollectible(type)

    if item:HasTags(ItemConfig.TAG_QUEST) then
        return
    end
    mod:AddDisItem(player)
end

local maxDisOrbitals, disOrbitSpeed, orbitDistance, groundOffset = 10, 2, 50, Vector(0, -16)
local disYellow = Color(1, 1, 0) local disRed = Color(1, 0, 0)
local disOffsetYellow = Color(1, 1, 1, 0.635, 0.5, 0.5) local disOffsetRed = Color(1, 1, 1, 0.635, 0.5)
local function PlayerUpdate(_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.disItems then
        p_data.SomethingWickedPData.disRenderData = p_data.SomethingWickedPData.disRenderData or {}
        local madeFunnySoundThisFrame = false
        local iConfig = Isaac.GetItemConfig()
        local rng = player:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_DIS)

        for i = 1, #p_data.SomethingWickedPData.disItems, 1 do
            local tab = p_data.SomethingWickedPData.disItems[i]
            if tab ~= nil then
                if tab.readyToProcess then
                    tab.time = tab.time + 1
                else
                    local effect = tab.gainEffect
                    if tab.dis then
                        if not effect then
                            for j = 1, maxDisOrbitals, 1 do
                                if p_data.SomethingWickedPData.disRenderData[j] == nil then
                                    tab.renderIdx = j

                                    effect = mod:SpawnStandaloneItemPopup(tab.id, mod.ItemPopupSubtypes.DIS_FUNNY_MOMENTS, player.Position, player)
                                    effect.SpriteScale = Vector(0.66, 0.66)
                                    effect.SpriteOffset = groundOffset
                                    local colorLerp = rng:RandomFloat()
                                    effect.Color = Color.Lerp(disOffsetYellow, disOffsetRed, colorLerp)

                                    local renderTab = {
                                        gainEffect = effect,
                                        color = Color.Lerp(disYellow, disRed, colorLerp),
                                        orbitOffset = 36 * (j-1),
                                        shouldRender = false
                                    }
                                    p_data.SomethingWickedPData.disRenderData[j] = renderTab
                                    effect:GetData().sw_disTargetPos = (Vector.FromAngle(renderTab.orbitOffset + (p_data.sw_disRenderOrbit or 0)):Resized(orbitDistance) + player.Position)

                                    tab.gainEffect = effect
                                    goto finishedUnProcess
                                end

                            end
                            tab.readyToProcess = true
                        end
                    else
                        if (not effect and tab.position) then
                            effect = mod:SpawnStandaloneItemPopup(tab.id, mod.ItemPopupSubtypes.MOVE_TO_PLAYER, tab.position, player)
                            tab.gainEffect = effect
                            tab.position = nil
                        end
                    end
                    if tab.position == nil and (effect == nil or not effect:Exists()) then
                        tab.readyToProcess = true
                        game:GetHUD():ShowItemText(player, iConfig:GetCollectible(tab.id))
                        if tab.dis then
                            if tab.renderIdx then

                            end
                        else

                        end
                        --do on gain item vfx stuff here ig
                    end
                end
                ::finishedUnProcess::

                if tab.time > time then
                    table.remove(p_data.SomethingWickedPData.disItems, i)
                    i = i - 1

                    if not tab.dis then
                        mod:QueueItemPopUp(player, tab.id)
                        if not madeFunnySoundThisFrame then
                            madeFunnySoundThisFrame = true
                            sfx:Play(SoundEffect.SOUND_THUMBS_DOWN, 1, 0)
                        end
                    else
                        if tab.renderIdx then
                            p_data.SomethingWickedPData.disRenderData[tab.renderIdx] = nil
                        end
                    end
                else
                    p_data.SomethingWickedPData.disItems[i] = tab
                end
            end
        end

        p_data.sw_disRenderOrbit = (p_data.sw_disRenderOrbit or 0) + disOrbitSpeed
        for key, renderTab in pairs(p_data.SomethingWickedPData.disRenderData) do
            if not renderTab.orbitVector then
                renderTab.orbitVector = Vector.FromAngle(renderTab.orbitOffset + p_data.sw_disRenderOrbit):Resized(orbitDistance)
            else
                renderTab.orbitVector = renderTab.orbitVector:Rotated(disOrbitSpeed)
            end
            renderTab.renderPos = player.Position + renderTab.orbitVector + groundOffset

            if renderTab.gainEffect and renderTab.gainEffect:Exists() then
                local e_data = renderTab.gainEffect:GetData()
                e_data.sw_disTargetPos = renderTab.renderPos - groundOffset
            else
                if renderTab.gainEffect then
                    renderTab.gainEffect = nil
                end
                renderTab.shouldRender = true
            end
            p_data.SomethingWickedPData.disRenderData[key] = renderTab
        end
    end
end

local function EnemyDies(_, enemy)
    local allP = mod:AllPlayersWithCollectible(CollectibleType.SOMETHINGWICKED_ACHERON)
    for _, player in ipairs(allP) do
        local dmg = enemy.MaxHitPoints
        local p_data = player:GetData()

        p_data.SomethingWickedPData.acheronCharge = (p_data.SomethingWickedPData.acheronCharge or 0) + dmg
        local neededCharge = mod:Current45VoltCharge()*6
        while p_data.SomethingWickedPData.acheronCharge > neededCharge do
            p_data.SomethingWickedPData.acheronCharge = p_data.SomethingWickedPData.acheronCharge - neededCharge
            mod:AddDisItem(player, false, ItemPoolType.POOL_DEVIL, enemy.Position)
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, PickupItem) --FUUUUUTUUUUUUUUUUUUUURE
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PlayerUpdate)
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, EnemyDies)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function (_, player)
    local p_data = player:GetData()
    if p_data.SomethingWickedPData.disRenderData then
        for key, renderTab in pairs(p_data.SomethingWickedPData.disRenderData) do
            renderTab.renderPos = player.Position + renderTab.orbitVector + groundOffset

            if renderTab.shouldRender then
                orbitalSprite.Color = renderTab.color
                orbitalSprite:Render(Isaac.WorldToScreen(renderTab.renderPos))
            end
        end
    end
end)

mod:AddCustomCBack(mod.CustomCallbacks.SWCB_EVALUATE_TEMP_WISPS, function (_, player, data)
    if data.SomethingWickedPData.disItems then
        for _, value in ipairs(data.SomethingWickedPData.disItems) do
            if value.readyToProcess then
                mod:AddItemWispForEval(player, value.id)
            end
        end
    end
end)