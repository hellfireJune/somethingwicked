local mod = SomethingWicked
local game = Game()

local function resetPos(f, room)
    local rwidth = room:GetGridWidth()
    local pos = Vector(rwidth*20 + (rwidth%2==0 and 0 or 20), 70)
    f.Position = pos
end

local function familiarUpdate(_, f)
    local room = game:GetRoom()
    if room:GetFrameCount() == 0 or f.FrameCount == 1 then
        resetPos(f, room)
    end
    game:UpdateStrangeAttractor(f.Position, 10, 80000)

    if f.FrameCount % 2 == 0 then
        local enemies = Isaac.FindInRadius(f.Position, 140, 8)
        for index, value in ipairs(enemies) do
            if not value:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                value:AddBurn(EntityRef(f), 40, f.Player.Damage)
            end
        end
    end
    EntityEffect.CreateLight(f.Position, 3)
    EntityEffect.CreateLight(f.Position, 2)
    EntityEffect.CreateLight(f.Position, 2)
    EntityEffect.CreateLight(f.Position, 1)
    EntityEffect.CreateLight(f.Position, 1)

    if f.FrameCount < 24 then
        f.Visible = true
        f.PositionOffset = Vector(0, -100*(0.8^f.FrameCount))
    else
        f.PositionOffset = Vector(0, math.sin(f.FrameCount/20))
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, familiarUpdate, FamiliarVariant.SOMETHINGWICKED_THE_SUN)

local function familiarInit(_, f)
    resetPos(f, game:GetRoom())
    f:GetSprite():SetRenderFlags(AnimRenderFlags.ENABLE_LAYER_LIGHTING)
    f:GetSprite():GetLayer(0):GetBlendMode():SetMode(BlendType.ADDITIVE)
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, familiarInit, FamiliarVariant.SOMETHINGWICKED_THE_SUN)

local beamSprite = Sprite()
beamSprite:Load("gfx/effect_sunbeam.anm2", true)
beamSprite:Play("Idle", false)

local beamLayer = beamSprite:GetLayer("beam")
beamLayer:SetWrapSMode(1)
beamLayer:SetWrapTMode(0)
local snapBeam = Beam(beamSprite, "beam", false, false)
local function preSunRender(_, f)
    if not f.Visible then
        return
    end
    local pos = f.Position + f.PositionOffset
    beamSprite.Color = Color(1,1,1, 1)
    for i = 1, 6, 1 do
        snapBeam:Add(Isaac.WorldToScreen(pos), 48, 0.1)
        snapBeam:Add(Isaac.WorldToScreen(pos+ Vector(0, 96):Rotated(f.FrameCount*1.2+(60*i))), 1, 0.2)
        snapBeam:Render()
    end

    for i = 1, 6, 1 do
        snapBeam:Add(Isaac.WorldToScreen(pos), 32, 0.2)
        snapBeam:Add(Isaac.WorldToScreen(pos + Vector(0, 64):Rotated(f.FrameCount*1.2+(60*i)+30)), 1, 0.4)
        snapBeam:Render()
    end

    local sp = f:GetSprite()
    local l = sp:GetLayer(0)
    l:SetSize(Vector(1,1)*(1+(math.sin(f.FrameCount/10)*0.05)))
end
mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, preSunRender, FamiliarVariant.SOMETHINGWICKED_THE_SUN)