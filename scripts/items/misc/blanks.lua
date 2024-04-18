local mod = SomethingWicked
local game = Game()

local blankSprite = Sprite()

local function realblankSlow(e, p)
    e:AddSlowing(EntityRef(p), 45, 0.7, mod.SlowColour)
end

function mod:microSilencerInstanceUpdate(effect)
    local player = effect.Parent
    local mandrake = effect.Variant == EffectVariant.SOMETHINGWICKED_MANDRAKE_SCREAM_LARGE

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

local speed = 40
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

            currWorstDistance = math.max(currWorstDistance, effect.Position:Distance(newPos))
        end

        e_data.sw_cachedFinalCornerDiff = currWorstDistance
    end

    e_data.sw_currentBlankCornerOffset = (e_data.sw_currentBlankCornerOffset or speed)
    local oset = e_data.sw_currentBlankCornerOffset
    if oset < e_data.sw_cachedFinalCornerDiff then
        e_data.sw_previouslyHitEnemies = e_data.sw_previouslyHitEnemies or {}
        local allProjectiles = Isaac.FindInRadius(effect.Position, 80000, EntityPartition.ENEMY | EntityPartition.BULLET)
        for index, ent in ipairs(allProjectiles) do
            local pos = ent.Position
            local dis = effect.Position-pos
            if dis.X < oset or dis.Y < oset then -- the people need a square radius
                if ent:IsVulnerableEnemy() then
                    if ent:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                        realblankSlow(ent, player)
                    end
                elseif ent:ToProjectile() then
                    ent:Die()
                end
            end
        end

        e_data.sw_currentBlankCornerOffset = oset + speed
    else
        effect:Remove()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, mod.microSilencerInstanceUpdate, EffectVariant.SOMETHINGWICKED_MANDRAKE_SCREAM_LARGE)
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function (_,effect)
    if effect.SubType == 0 then
        mod:microSilencerInstanceUpdate(effect)
    else
        mod:fullSilencerInstanceUpdate(effect)
    end
end, EffectVariant.SOMETHINGWICKED_BLANK)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function (_,effect)
    local s = effect:GetSprite()
    s:Load("effect_andshedbeniceshedbesoniceandshedbeallofmine.anm2", true)
end, EffectVariant.SOMETHINGWICKED_BLANK)

local function SpawnBlankInternal(position, player, subtype)
    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.SOMETHINGWICKED_BLANK, subtype, position, Vector.Zero, player)
end

function mod:DoMicroBlank(position, player)
    SpawnBlankInternal(position, player, 0)
end

function mod:DoMegaBlank(position, player)
    SpawnBlankInternal(position, player, 1)
end