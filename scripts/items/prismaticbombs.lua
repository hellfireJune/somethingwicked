local this = {}
CollectibleType.SOMETHINGWICKED_PRISMATIC_BOMBS = Isaac.GetItemIdByName("Prismatic Bombs")
this.spriteSheet = "gfx/items/pick ups/bombs/costumes/voidbombs.png"

function this:BombUpdate(bomb)
    local player = bomb.SpawnerEntity:ToPlayer()
    if player == nil then
        return
    end

    local bombData = bomb:GetData()
    if bomb.FrameCount == 1 then
        SomethingWicked.ItemHelpers:ShouldConvertBomb(bomb, player, CollectibleType.SOMETHINGWICKED_PRISMATIC_BOMBS, this.BombSpriteSheet, "isPrismaticBomb", 0.2)
    elseif bombData.isPrismaticBomb then
        local lasers = Isaac.FindByType(7)
        for _, laser in ipairs(lasers) do
            
        end
    end
end

local colors = {
    [-45] = Color(1, 0, 0),
    [-15] = Color(0, 1, 0),
    [15] = Color(0, 0, 1),
    [45] = Color(1, 1, 0),
}
function this:TearCollision(tear, bomb)
    local t_data = tear:GetData()
    if t_data.somethingWicked_prismaticBombCheck then
        return
    end

    local b_data = bomb:GetData()
    bomb = bomb:ToBomb()
    if bomb and b_data.isPrismaticBomb then
        local velocity = tear.Velocity
        tear.Velocity = velocity:Rotated(-45)
        tear.Color = colors[-45]

        for i = -15, 30, 45 do
            local nt = Isaac.Spawn(2, tear.Variant, tear.Subtype, tear, velocity:Rotated(i), tear.SpawnerEntity)
            nt.TearFlags = tear.TearFlags
            nt.CollisionDamage = tear.CollisionDamage
            tear.Color = colors[i]
            nt:GetData().somethingWicked_prismaticBombCheck = true
        end
        t_data.somethingWicked_prismaticBombCheck = true
        return true
    end
end

SomethingWicked:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, this.TearCollision)
SomethingWicked:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, this.BombUpdate)

this.EIDEntries = {
    
}
return this