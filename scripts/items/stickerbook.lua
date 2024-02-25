local function ProcChance(player)
    return 1
end
SomethingWicked.TFCore:AddNewTearFlag(SomethingWicked.CustomTearFlags.FLAG_STICKER_BOOK, {
    ApplyLogic = function (_, player, tear)
        if player:HasCollectible(mod.ITEMS.STICKER_BOOK) then
            local c_rng = player:GetCollectibleRNG(mod.ITEMS.STICKER_BOOK)
            if c_rng:RandomFloat() < ProcChance(player) then
                return true
            end
        end
    end,
    PostApply = function (_, player, tear)
        local c_rng = player:GetCollectibleRNG(mod.ITEMS.STICKER_BOOK)
        this:MakeStickerY(tear, c_rng)
    end,
    EnemyHitEffect = function (_, tear, pos, enemy)
        this:HitEnemy(tear, pos, enemy)
    end
})
local stickerTypes = {
    "skull", --debuffs nearby enemies
    "bomb", --does an explode
    "heart", -- a lot of red creep
}

function this:HitEnemy(tear, pos, enemy)
    local t_data = tear:GetData()
    local e_data = enemy:GetData()
    if t_data.somethingWicked_sticker then
        local sticker = t_data.somethingWicked_sticker
        e_data.somethingWicked_stickers = e_data.somethingWicked_stickers or {}
        e_data.somethingWicked_stickers[sticker] = true
    end
end

function this:MakeStickerY(tear, rng)
    local t_data = tear:GetData()
    local stickerType = SomethingWicked:GetRandomElement(stickerTypes, rng)
    t_data.somethingWicked_sticker = stickerType
end

function this:OnEnemyDie(entity) 
    local e_data = entity:GetData()
    if e_data.somethingWicked_stickers then
        for key, _ in pairs(e_data.somethingWicked_stickers) do
            if key == "skull" then
                
            end
            if key == "bomb" then
                
            end
            if key == "heart" then
                
            end
        end
    end
end

this.EIDEntries = {
    [mod.ITEMS.STICKER_BOOK] = {
        desc = "bookie",
        Hide = true,
    }
}
return this