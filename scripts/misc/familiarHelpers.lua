local mod = SomethingWicked
SomethingWicked.FamiliarHelpers = {}

function SomethingWicked.FamiliarHelpers:KillableFamiliarFunction(familiar, blockProj, projectilesPierce, collideWithEnemies, flags)
    flags = flags or 0
    if blockProj then
        for _, value in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE, -1, -1, true)) do
            if value.Position:Distance(familiar.Position) < value.Size + familiar.Size then
                familiar:TakeDamage(value.CollisionDamage, flags, EntityRef(value), 4)
                if not projectilesPierce then
                    value:Die()
                end
            end
        end
    end

    if collideWithEnemies then
        for _, value in ipairs(Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.ENEMY)) do
            --print("kill")
            familiar:TakeDamage(value.CollisionDamage, flags, EntityRef(value), 4)
            break
        end
    end
end

function SomethingWicked.FamiliarHelpers:BasicFamiliarNum(player, collectible)
    local rng = player:GetCollectibleRNG(collectible)
    local sourceItem = Isaac.GetItemConfig():GetCollectible(collectible)
    local boxEffect = player:GetEffects():GetCollectibleEffect(CollectibleType.COLLECTIBLE_BOX_OF_FRIENDS)
    local boxStacks = 0
    if boxEffect ~= nil then
        boxStacks = boxEffect.Count
    end
    local itemStacks = player:GetCollectibleNum(collectible)
    return itemStacks + (itemStacks > 0 and boxStacks or 0), rng, sourceItem
end

function SomethingWicked.FamiliarHelpers:AddLocusts(player, amount, rng, position)
    position = position or player.Position
    for i = 1, amount, 1 do
        local subtype = rng:RandomInt(5) + 1
        local amountToSpawn = 1
        if subtype == LocustSubtypes.LOCUST_OF_CONQUEST then
            amountToSpawn = amountToSpawn + rng:RandomInt(3)
        end
        for _ = 1, amountToSpawn, 1 do
            local locust = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLUE_FLY, subtype, position, Vector.Zero, player):ToFamiliar()
            locust.Parent = player
            locust.Player = player
        end
    end
end

function SomethingWicked.FamiliarHelpers:DoesFamiliarShootPlayerTears(familiar)
	return (familiar.Variant == FamiliarVariant.INCUBUS
	or familiar.Variant == FamiliarVariant.SPRINKLER 
	or familiar.Variant == FamiliarVariant.TWISTED_BABY 
	or familiar.Variant == FamiliarVariant.BLOOD_BABY 
	or familiar.Variant == FamiliarVariant.UMBILICAL_BABY
    or familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION
    or familiar.Variant == FamiliarVariant.SOMETHINGWICKED_LEGION_B) 
end

function SomethingWicked.FamiliarHelpers:GetOrbitalPositionInLayer(fcheck, player)
    local posInLayer local totalLayerSize = 0 local shouldReset = false
    for _, familiar in ipairs(Isaac.FindByType(3)) do
        familiar = familiar:ToFamiliar()
        if (familiar.Parent and GetPtrHash(familiar.Parent) == GetPtrHash(player)) or GetPtrHash(familiar.Player) == GetPtrHash(player) and familiar.OrbitLayer == fcheck.OrbitLayer then
            totalLayerSize = totalLayerSize + 1
            if GetPtrHash(familiar) == GetPtrHash(fcheck) then
                posInLayer = totalLayerSize
            end
            if familiar.FrameCount == 0 and fcheck.FrameCount > 0 then
                shouldReset = true
            end
        end
    end
    return posInLayer, totalLayerSize, shouldReset
end

function SomethingWicked.FamiliarHelpers:DynamicOrbit(familiar, parent, speed, distance)
    local layerPos, size, shouldReset = SomethingWicked.FamiliarHelpers:GetOrbitalPositionInLayer(familiar, parent)
    local f_data = familiar:GetData()
    
    if shouldReset then
        f_data.somethingWicked__dynamicOrbitPos = 0 + speed
    else
        f_data.somethingWicked__dynamicOrbitPos = (f_data.somethingWicked__dynamicOrbitPos or 0) + speed
    end
    return parent.Position + distance * Vector.FromAngle(f_data.somethingWicked__dynamicOrbitPos + ((layerPos / size) * 360))
end

--these 2 taken from retribution thanks xalum
function SomethingWicked.FamiliarHelpers:GridAlignPosition(pos)
local x = pos.X
local y = pos.Y

x = 40 * math.floor(x/40 + 0.5)
y = 40 * math.floor(y/40 + 0.5)

return Vector(x, y)
end

function SomethingWicked.FamiliarHelpers:SnakePathFind(entity, targetPosition, initialDirection, stuck)
    if stuck == nil then
        stuck = false
    end
		local room = SomethingWicked.game:GetRoom()
		local entityPosition = SomethingWicked.FamiliarHelpers:GridAlignPosition(entity.Position)
		targetPosition = SomethingWicked.FamiliarHelpers:GridAlignPosition(targetPosition)

		local loopingPositions = {targetPosition}
		local indexedGrids = {}

		local index = 0
		while #loopingPositions > 0 do
			local temporaryLoop = {}

			for _, position in pairs(loopingPositions) do
				if room:IsPositionInRoom(position, 0) then
					if room:GetGridCollisionAtPos(position) == GridCollisionClass.COLLISION_NONE or index == 0 then
						local gridIndex = room:GetGridIndex(position)
						if not indexedGrids[gridIndex] then
							indexedGrids[gridIndex] = index

							for i = 1, 4 do
								table.insert(temporaryLoop, position + Vector(40, 0):Rotated(i * 90))
							end
						end
					end
				end
			end
			
			index = index + 1
			loopingPositions = temporaryLoop
		end

		local index = 99999
		local choice = entityPosition

		for i = -1, 1 do
			local position = entityPosition + ((Vector(40, 40) * initialDirection):Rotated(i * 90))
			local positionIndex = room:GetGridIndex(position)
			local value = indexedGrids[positionIndex]

			if value and value <= index then
				index = value
				choice = position

                if i ~= 0 then
                    
                local newPosition = entityPosition + ((Vector(40, 40) * initialDirection):Rotated(180))
                local newpositionIndex = room:GetGridIndex(newPosition)
                local newvalue = indexedGrids[newpositionIndex]
    
                if newvalue and newvalue <= index then
                        index = newvalue
                        choice = position
                    end
                end
			end

	end
    if index == 99999
    and not stuck then
        choice, stuck = SomethingWicked.FamiliarHelpers:SnakePathFind(entity, entityPosition, initialDirection, true)
    end

    return choice, index == 99999 and stuck
end

function mod.FamiliarHelpers:FindNearestVulnerableEnemy(pos, dis, blacklist)
    dis = dis or 80000
    local enemies = Isaac.FindInRadius(pos, dis, EntityPartition.ENEMY)
    local distance = 80009 local enemy = nil

    for index, value in ipairs(enemies) do
        local newDist = value.Position:Distance(pos)
        if value:IsVulnerableEnemy() and not value:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) and  newDist < distance
        and (blacklist == nil or not blacklist[""..value.InitSeed]) then
            distance = newDist
            enemy = value
        end
    end

    print(enemy)
    return enemy
end