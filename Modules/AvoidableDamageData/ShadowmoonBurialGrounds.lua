local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
    -- 小怪
    {
        -- 猛撞 (食腐骨蟲)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 153686
    },
    {
        -- 地底爆發 (虛無生靈)
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 365201
    },
    -- [1] 莎妲娜‧血怒
    {
        -- 黑暗之蝕
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 164686,
        noPlayerDebuff = 162652
    },
    -- [2] 納里旭
    -- {
    --     -- 虛無漩渦
    --     type = AD.MISTAKE.SPELL_DAMAGE,
    --     spell = TODO
    -- },
    {
        -- 虛無破壞
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 153072
    },
    {
        -- 虛無衝擊
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 153501
    },
    -- [3] 骨喉
    {
        -- 猛撞
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 153395
    },
    -- [4] 耐祖奧
    {
        -- 惡意
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 154442
    },
    {
        -- 祭儀骸骨
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 154469
    }
}

local mapIds = {574, 575, 576}

AD:AddData("Shadowmoon Burial Grounds", mistakes, mapIds)
