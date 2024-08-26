local mod = SomethingWicked
local game = Game()
local flags = 1 | 8 | 16
local gridScalar = 0.5
local function getSubIndex(pos, room)
    local baseIndex = room:GetGridIndex(pos) * 4

    local x = pos.X%40
    local y = pos.Y%40

    if x>=20 then
        baseIndex = baseIndex + 1
    end
    if y>=20 then
        baseIndex = baseIndex + 2
    end

    return baseIndex
end

function mod:SnakePathFind(entity, targetPosition, initialDirection, stuck)
    if stuck == nil then
        stuck = false
    end
		local room = game:GetRoom()
		local entityPosition = mod:GridAlignPosition(entity.Position, gridScalar)
		targetPosition = mod:GridAlignPosition(targetPosition, gridScalar)
        if room:GetGridCollisionAtPos(targetPosition) ~= GridCollisionClass.COLLISION_NONE then
            targetPosition = entityPosition
        end


		local loopingPositions = {targetPosition}
		local indexedGrids = {}

		local index = 0
		while #loopingPositions > 0 do
			local temporaryLoop = {}

			for _, position in pairs(loopingPositions) do
				if room:IsPositionInRoom(position, 0) then
					if room:GetGridCollisionAtPos(position) == GridCollisionClass.COLLISION_NONE then
						local gridIndex = getSubIndex(position, room)
						if not indexedGrids[gridIndex] then
							indexedGrids[gridIndex] = index

                            for i = 1, 4 do
                                table.insert(temporaryLoop, position + Vector(20, 0):Rotated(i * 90))
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
			local position = entityPosition + ((Vector(20, 20) * initialDirection):Rotated(i * 90))
			local positionIndex = getSubIndex(position, room)
			local value = indexedGrids[positionIndex]

			if value and value <= index then

                if i ~= 0 then

                local newPosition = entityPosition + ((Vector(20, 20) * initialDirection):Rotated(180))
                local newpositionIndex = getSubIndex(newPosition, room)
                local newvalue = indexedGrids[newpositionIndex] newvalue = newvalue and newvalue - 1
    
                    if newvalue and newvalue <= index then
                        value = newvalue
                    end
                end
				index = value
				choice = position
			end

	end
    if index == 99999
    and not stuck then
        choice, stuck = mod:SnakePathFind(entity, entityPosition, initialDirection, true)
    end

    return choice, index == 99999 and stuck
end

local function Visuals(_, familiar, player)
    local hasBFFs = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
    local color = hasBFFs and Color(1, 0.2, 0.2) or Color(1, 1, 1)
    --local sizeMult = familiar.Child ~= nil and 1 or 0.95
    familiar.Color = color
    familiar.SpriteScale = (hasBFFs and Vector(0.8, 0.8) or Vector(1, 1))-- * sizeMult
end

local function StartOfRoomAlignPosition(familiar, position, room)
    local sub = getSubIndex(position, room)%4

    local roomCenter = room:GetCenterPos()
    local xAlign = position.X < roomCenter.X local yAlign = position.Y < roomCenter.Y
    local differencePos = Vector(xAlign and 20 or 40, yAlign and 20 or 40)

    local subX = sub % 2 == 1 local subY = sub > 2
    local subPos = Vector(subX and 20 or 40, subY and 20 or 40)
    return position + differencePos-subPos
end

local function MoveAnyBodyPiecesRecursive(parent, familiar, newPos, isStuck)
    if familiar == nil then
        return
    end
    if game:GetRoom():GetFrameCount() == 0 then
        if parent == nil then
            familiar.Position = newPos
        else
            familiar.Position = parent.Position
        end
        if familiar.Child then
            MoveAnyBodyPiecesRecursive(familiar, familiar.Child)
        end
        return
    end

    if familiar.Child then
        MoveAnyBodyPiecesRecursive(familiar, familiar.Child)
    end


    if not newPos then
        newPos = parent.Position
    end

    local f_data = familiar:GetData()
    local direction = (newPos - familiar.Position):Normalized()
    if parent == nil then
        if direction:Length() ~= 0 then
            f_data.somethingWicked_rsDirection = direction
        end
        if isStuck then
            f_data.somethingWicked_rsDirection = f_data.somethingWicked_rsDirection:Rotated(-90)
        end
    end
    familiar.Position = newPos
    familiar.SpriteRotation = mod:GetAngleDegreesButGood(direction)+180
end

local frameCountShit = 6
local bodyLength = 6
local offset = Vector(9, 9)
local function HeadUpdate(_, familiar)
    local player = familiar.Player
    local f_data = familiar:GetData()

    f_data.somethingWicked_rsDirection = f_data.somethingWicked_rsDirection or Vector(1, 0)
    local lastTarget = familiar.Target
    familiar:PickEnemyTarget(80000, 0, flags, familiar.Velocity, 135)
    if familiar.Target == nil then
        familiar.Target = lastTarget
    end

    familiar.Position = mod:GridAlignPosition(familiar.Position, gridScalar)+offset
    familiar.Velocity = Vector.Zero
    local room = game:GetRoom()
    local newRoom = room:GetFrameCount() == 0
    if newRoom then
        familiar.Position = StartOfRoomAlignPosition(familiar, familiar.Position, room)
        MoveAnyBodyPiecesRecursive(nil, familiar, familiar.Position)
    elseif familiar.FrameCount % frameCountShit == 1 then
        local target = familiar.Target
        local targetPos = (target and target:Exists() and target.Position) or player.Position

        local newPos, isStuck = mod:SnakePathFind(familiar, targetPos, f_data.somethingWicked_rsDirection)
        --print(newPos, familiar.Position)

        MoveAnyBodyPiecesRecursive(nil, familiar, mod:GridAlignPosition(newPos, gridScalar)+offset, isStuck)
        f_data.sw_rsEnemiesCollided = {}
        --local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, newPos, Vector.Zero, nil)
    end
    Visuals(_, familiar, player)
end
SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, HeadUpdate, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE)

SomethingWicked:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function (_, familiar)
    print(familiar.Position)
    if familiar.FrameCount % frameCountShit == 1 then
        if not familiar.Parent or not familiar.Parent:Exists() then
            familiar:Die()
        end
    end
    Visuals(_, familiar, familiar.Player)
end, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY)

local damageoncollide = 4
local function SnakeCollideWithEnemy(familiar, enemy, head)
    if familiar.FrameCount % 2 == 1 then
        return
    end

    if enemy:ToNPC() and enemy:IsVulnerableEnemy() then        
        local isHead = head == nil
        if isHead then
            head = familiar
        end
        local f_data = head:GetData()
        f_data.sw_rsEnemiesCollided = f_data.sw_rsEnemiesCollided or {}

        if f_data.sw_rsEnemiesCollided[enemy.InitSeed] then
           return 
        end
        f_data.sw_rsEnemiesCollided[enemy.InitSeed] = true

        local damage = damageoncollide
            if not isHead then
                damage = damage / 2
            end
        enemy:TakeDamage(damage, 0, EntityRef(familiar), 1)
    end
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, function (_, familiar, other )
    SnakeCollideWithEnemy(familiar, other)
end, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE)

local function getHead(child)
    local f_data = child:GetData()
    if f_data.sw_cachedHead ~= nil then
        return f_data.sw_cachedHead
    end

    for i = 1, 100, 1 do
        if child.Parent == nil then
            f_data.sw_cachedHead = child
            return child
        end
        child = child.Parent
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, CallbackPriority.LATE, function (_, familiar, other )
    SnakeCollideWithEnemy(familiar, other, getHead(familiar))
end, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY)

local function HeadInit(_, familiar)
    local lastParent = familiar
    local player = familiar.Player

    familiar.Position = mod:GridAlignPosition(familiar.Position, gridScalar)
    for i = 1, bodyLength, 1 do
        local newBod = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY, 0, lastParent.Position, Vector.Zero, lastParent):ToFamiliar()
        newBod.Parent = lastParent
        lastParent.Child = newBod
        newBod.Player = player

        
        local sprite = newBod:GetSprite()
        sprite:SetFrame(4 * i%4)
        newBod:Update()

        lastParent = newBod
    end
    Visuals(_, familiar, familiar.Player)
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, HeadInit, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE)
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function (_, familiar)
    Visuals(_, familiar, familiar.Player)
end, FamiliarVariant.SOMETHINGWICKED_RETROSNAKE_BODY)