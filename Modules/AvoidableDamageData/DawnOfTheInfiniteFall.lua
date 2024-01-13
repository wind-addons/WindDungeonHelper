local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

-- TODO: Chronikar:Withering Sandpool - initial damage not avoidable, rest is

local mistakes = {
    -- Chronikar
    {
        -- Chronikar:Withering Sandpool
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 401794
    },
    {
        -- Chronikar:Eon Fragments
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 405970
    },
    -- Manifested Timeways
    {
        -- Manifested Timeways:Fragments of Time
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 404650
    },
    -- Blight of Galakrond
    {
        -- Blight of Galakrond:Necrotic Winds
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 408008
    },
    {
        -- Blight of Galakrond:Incinerating Blightbreath
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 408177
    },
    {
        -- Blight of Galakrond:Blight Seep
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 407147
    },
    {
        -- Blight of Galakrond:Blight Reclamation
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 407159,
        playerIsNotTank = true
    },
    -- Iridikron
    {
        -- Iridikron:Punctured Ground
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 414376
    },
    {
        -- Iridikron:Rending Earthspikes
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 409287
    },
    -- Mobs
    {
        -- Blight Spew
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 412810
    },
    {
        -- Timerip
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 412065
    },
    {
        -- Sand Zone
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 413332
    },
    {
        -- Errant Time
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 414032
    },
    {
        -- Corrosive Expulsion
        type = AD.MISTAKE.SPELL_DAMAGE,
        spell = 407027
    }
}

local mapIds = {2190, 2191, 2192, 2193, 2194, 2195, 2196, 2197, 2197}

AD:AddData("Dawn of the Infinite", mistakes, mapIds)
