local mod = SomethingWicked
local game = Game()

local blankSprite = Sprite()
blankSprite:Load("gfx/sw_blank.anm2", true)
blankSprite:Play("Idle")

local beamSprite = Sprite()
beamSprite:Load("gfx/effect_blankconnector.anm2", true)
beamSprite:Play("Idle", false)

local beamLayer = beamSprite:GetLayer("beam")
beamLayer:SetWrapSMode(1)
beamLayer:SetWrapTMode(0)

local snapBeam = Beam(beamSprite, "beam", false, false)

local function realblankSlow(e, p,m)
    e:AddSlowing(EntityRef(p), 45*(m or 1), 0.8, mod.SlowColour)
end

function mod:microSilencerInstanceUpdate(effect)
    local player = effect.Parent
    local mandrake = effect.Variant == mod.EFFECTS.MANDRAKE_SCREAM_LARGE

    local e_data = effect:GetData()
    e_data.sw_previouslyHitEnemies = e_data.sw_previouslyHitEnemies or {}

    local capsule = effect:GetNullCapsule("hitboxithink")
    local flag = EntityPartition.ENEMY | (mandrake and 0 or EntityPartition.BULLET)
    local nearbyEnemies = Isaac.FindInCapsule(capsule, flag)
    for _, ent in pairs(nearbyEnemies) do
        local apply = not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS)
        if ent:IsVulnerableEnemy() then
            local key = ""..ent.Index
            if not e_data.sw_previouslyHitEnemies[key] then
                e_data.sw_previouslyHitEnemies[key] = true                
                if mandrake then
                    if apply then
                        ent:AddFreeze(EntityRef(player), 90)
                    end
                    ent:TakeDamage(25, 0, EntityRef(player), 1)
             elseif apply then
                    realblankSlow(ent, player)
                end
            end
        elseif not mandrake then
            --blank bullet removal
            local proj = ent:ToProjectile()
            if proj then
                ent:Die()
            end
        end
    end

    local s = effect:GetSprite()
    if s:IsFinished() then
        effect:Remove()
    end
end

local speed = 30
local flatxmult = 1.8
function mod:fullSilencerInstanceUpdate(effect)
    local player = effect.Parent
    local e_data = effect:GetData()
    

    if not e_data.sw_cachedFinalCornerDiff then
        local room = game:GetRoom()
        local gridSize = Vector(40, 40)
        local origin = room:GetTopLeftPos()+gridSize

        local rightWidth = Vector((room:GetGridWidth()*40)-40,40)
        local bottomHeight = Vector(40,(room:GetGridHeight()*40)-40)

        local currWorstDistance = 0
        for i = 1, 4, 1 do
            local newPos = origin
            if i > 2 then
                newPos = newPos + bottomHeight
            end
            if i % 2 == 0 then
                newPos = newPos + rightWidth
            end

            local dis = (effect.Position - newPos)*Vector(1/flatxmult, 1)
            currWorstDistance = math.max(currWorstDistance, dis:Length())
        end

        e_data.sw_cachedFinalCornerDiff = currWorstDistance
    end

    e_data.sw_currentBlankCornerOffset = (e_data.sw_currentBlankCornerOffset or speed)
    local oset = e_data.sw_currentBlankCornerOffset
    if oset < e_data.sw_cachedFinalCornerDiff then
        e_data.sw_previouslyHitEnemies = e_data.sw_previouslyHitEnemies or {}
        local allProjectiles = Isaac.FindInRadius(effect.Position, 80000, EntityPartition.ENEMY | EntityPartition.BULLET)
        local borderOset = oset-speed*4
        for index, ent in ipairs(allProjectiles) do
            local pos = ent.Position
            local dis = effect.Position-pos
            if (dis.X < oset*flatxmult or dis.Y < oset) and (dis.X > borderOset*flatxmult or dis.Y > borderOset or ent:ToProjectile()) then -- the people need a square (rectangular) radius
                if ent:IsVulnerableEnemy() then
                    if not ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not mod:UtilTableHasValue(e_data.sw_previouslyHitEnemies, ""..ent.InitSeed) then
                        table.insert(e_data.sw_previouslyHitEnemies, ""..ent.InitSeed)
                        realblankSlow(ent, player, 3)
                    end
                elseif ent:ToProjectile() then
                    ent:Die()
                end
            end
        end

        e_data.sw_currentBlankCornerOffset = oset + speed
        e_data.sw_dontboostoset = true
    else
        effect:Remove()
    end
end

local function megaBlankRender(_, effect)
    local e_data = effect:GetData()
    if e_data.sw_currentBlankCornerOffset then

        for j = 1, 2, 1 do
            local color = j == 1 and Color(1, 1, 1, 0.4) or Color(1,1,1)
            blankSprite.Color = color
            beamSprite.Color = color
            local unflippedY = {} local flippedY = {} local unflippedX = {} local flippedX = {}
            for i = 1, 4, 1 do
                local oset = e_data.sw_currentBlankCornerOffset
                if not e_data.sw_dontboostoset then
                    oset = oset+(speed/2)
                end
                if j == 1 then
                    oset = math.max(0, oset-speed*2)
                end
                e_data.sw_dontboostoset = false
                local flipX = i % 2 == 0
                local flipY = i > 2

                blankSprite.FlipX = flipX
                blankSprite.FlipY = flipY

                local xmult = flipX and 1 or -1
                local ymult = flipY and 1 or -1
                local pos = Vector(oset*xmult*flatxmult, oset*ymult)
                pos = pos + effect.Position
                
                local rpos = Isaac.WorldToRenderPosition(pos)
                blankSprite:Render(rpos)

                local yCorner = blankSprite:GetNullFrame("connector1")
                local xCorner = blankSprite:GetNullFrame("connector2")
                local xPos = xCorner:GetPos() + rpos
                local yPos = yCorner:GetPos() + rpos
                if flipX then
                    
                else

                end
                if flipY then
                    
                else

                end
            end
        end
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, megaBlankRender, mod.EFFECTS.BLANK)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.microSilencerInstanceUpdate, mod.EFFECTS.MANDRAKE_SCREAM_LARGE)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_,effect)
    if effect.SubType == 0 then
        mod:microSilencerInstanceUpdate(effect)
    else
        mod:fullSilencerInstanceUpdate(effect)
    end
end, mod.EFFECTS.BLANK)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_,effect)
    local s = effect:GetSprite()
    s:Load("effect_andshedbeniceshedbesoniceandshedbeallofmine.anm2", true)
end, mod.EFFECTS.BLANK)

local function SpawnBlankInternal(position, player, subtype)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, mod.EFFECTS.BLANK, subtype, position, Vector.Zero, player)
end

function mod:DoMicroBlank(position, player)
    SpawnBlankInternal(position, player, 0)
end

function mod:DoMegaBlank(position, player)
    SpawnBlankInternal(position, player, 1)
end 