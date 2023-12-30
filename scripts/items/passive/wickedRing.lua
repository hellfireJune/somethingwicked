local mod = SomethingWicked
local game = Game()
local sfx = SFXManager()

local sprite = Sprite()
sprite:Load("gfx/effect_wickedring_ui.anm2", true)
sprite:SetAnimation("Idle")

local function procChance(player)
    return 0.17 + player.Luck/20
end
local function getDamageNeeded()
    local level = game:GetLevel()
    return 40 + 20*level:GetAbsoluteStage()
end

local function getFrameLerp(frame)
    return math.max(0, mod:Lerp(1, 0, (frame/12)^2))
end
local function updatePlayersProgress(player)
    local p_data = player:GetData()
    p_data.SomethingWickedPData.WickedRingCharge = p_data.SomethingWickedPData.WickedRingCharge or 0

    local render = {}
    local progress = (p_data.SomethingWickedPData.WickedRingCharge/getDamageNeeded())
    progress = math.floor(progress*22)
    render.progress = progress

    render.frameRaw = 0
    render.frame = 0
    p_data.sw_wickedRingRender = render
end

mod:AddNewTearFlag(mod.CustomTearFlags.FLAG_CRITCHARGE, {
    ApplyLogic = function (_, p)
        if p:HasCollectible(CollectibleType.SOMETHINGWICKED_WICKED_RING) then
            local rng = p:GetCollectibleRNG(CollectibleType.SOMETHINGWICKED_WICKED_RING)
            if rng:RandomFloat() < procChance(p) then
                return true
            end
        end
    end,
    PostApply = function (_, player, tear)
        tear.CollisionDamage = tear.CollisionDamage / 0.82
    end,
    EnemyHitEffect = function (_, tear, pos, enemy, p)
        local dmg = math.min(tear.CollisionDamage, enemy.HitPoints)

        local p_data = p:GetData()
        p_data.SomethingWickedPData.WickedRingCharge = (p_data.SomethingWickedPData.WickedRingCharge or 0) + dmg
        
        local dmgNeeded = getDamageNeeded()
        while p_data.SomethingWickedPData.WickedRingCharge >= dmgNeeded do
            p_data.SomethingWickedPData.WickedRingCharge = p_data.SomethingWickedPData.WickedRingCharge - dmgNeeded

            mod:ChargeFirstActive(p)
        end
        updatePlayersProgress(p)
    end,
    TearColor = Color(50, 50, 50, 1, 0)
})

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function (_, player)
    if player:HasCollectible(CollectibleType.SOMETHINGWICKED_WICKED_RING) then
        local p_data = player:GetData()
        if not p_data.sw_wickedRingRender then
            updatePlayersProgress(player)
        end

        p_data.sw_wickedRingRender.frameRaw = p_data.sw_wickedRingRender.frameRaw + 1
        p_data.sw_wickedRingRender.frame = getFrameLerp(p_data.sw_wickedRingRender.frameRaw)
    end
end)

local a = 0.55
local regColor = Color(1,1,1,a)
local nextColor = Color(1,1,1,a,1,1,1)
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function (_, player)
    local p_data = player:GetData()
    if p_data.sw_wickedRingRender then
        sprite:SetFrame(p_data.sw_wickedRingRender.progress)

        local renderPos = Isaac.WorldToScreen(player.Position - Vector(0.5, -10))
        for i = 1, 2, 1 do
            local isBar = i == 1
            if isBar == true then
                sprite.Color = Color.Lerp(regColor, nextColor, p_data.sw_wickedRingRender.frame)
            else
                sprite.Color = regColor
            end

            sprite:RenderLayer(i-1, renderPos)
        end
    end
end)