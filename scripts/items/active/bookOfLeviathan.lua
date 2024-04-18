local mod = SomethingWicked
local sfx = SFXManager()
local game = Game()

local bolSprite = Sprite()
bolSprite:Load("gfx/effect_leviathanitemoverlay.anm2", true)
bolSprite:Play("Idle")

local function IsCurseOnFloor()
    local level = game:GetLevel()
    local curses = level:GetCurses()

    if curses ~= 0 then
        return true
    end
    return false
end

local function UseItem(_, _, _, player, flags)
    if flags & UseFlag.USE_OWNED ~= 0 and not IsCurseOnFloor() then
        return { Discharge = false, ShowAnim = true }
    end

    local ceffects = player:GetEffects()
    ceffects:AddNullEffect(mod.NULL.VIATHAN)
    --player:AddCacheFlags(CacheFlag.CACHE_ALL, true)
    player:AddBlackHearts(2)
    --perpetually spinning moon thing vfx would be cool
    
    sfx:Play(SoundEffect.SOUND_DEVIL_CARD, 1, 0)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 1, player.Position, Vector.Zero, player)
    local poof2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF02, 2, player.Position, Vector.Zero, player)
    poof2.Color = Color(0.7, 0, 0.7)
    poof.Color = Color(0.7, 0, 0.7)
    return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, UseItem, mod.ITEMS.BOOK_OF_LEVIATHAN)

mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, function (_, item)
    if not IsCurseOnFloor() then
        return 0
    end
end, mod.ITEMS.BOOK_OF_LEVIATHAN)

local pulseSpeed = 0.1
function mod:LeviathanPlayerUpdate(player)
    local p_data = player:GetData()
    p_data.sw_leviathanRenderTab = nil 
    if player:HasCollectible(mod.ITEMS.BOOK_OF_LEVIATHAN) and IsCurseOnFloor() then
        local tab = {}

        local frame = game:GetFrameCount()
        frame = (math.sin(frame*pulseSpeed)/2)+0.5

        tab.alpha = frame

        local tabsTab = {}
        for i = 0, 3, 1 do
            if player:GetActiveItem(i) == mod.ITEMS.BOOK_OF_LEVIATHAN then
                tabsTab[i] = tab
            end
        end

        p_data.sw_leviathanRenderTab = tabsTab
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.LeviathanPlayerUpdate)

--[[function mod:BookOfLeviathanOnDamage(player, effects)
end]]

mod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, function (_,player, slot, offset, alpha, scale)
    local p_data = player:GetData()
    if p_data.sw_leviathanRenderTab then
        local tab = p_data.sw_leviathanRenderTab[slot]
        if tab then
            bolSprite.Scale = scale*Vector.One
            bolSprite.Color = Color(1,1,1,alpha*tab.alpha)
            bolSprite:Render(offset+(Vector(16,16)*scale))
        end
    end
end)
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, CallbackPriority.EARLY, function (_,player, slot, offset, alpha, scale)
    local p_data = player:GetData()
    if p_data.sw_leviathanRenderTab then
        local tab = p_data.sw_leviathanRenderTab[slot]
        if tab then
            bolSprite.Scale = scale*Vector.One
            bolSprite.Color = Color(1,1,1,alpha*tab.alpha)
            --print(tab.alpha, alpha)

            local pos = offset+(Vector(16,16)*scale)
            --bolSprite:Play("BackGlow")
            bolSprite:Render(pos)
            --bolSprite:Play("Idle")
            --bolSprite:Render(pos)
        end
    end
end)