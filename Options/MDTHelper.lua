local W, F, L, _, O = unpack(select(2, ...))
local MH = W:GetModule("MDTHelper")

O.mdhHelper = {
    order = 6,
    name = L["MDT Helper"],
    type = "group",
    args = {
        importProfile = {
            order = 1,
            type = "execute",
            name = L["Import Enemy Data"],
            desc = L["Import the enemy data from Github repo."],
            width = 2,
            func = function()
                MH:ImportEnemyData()
            end
        },
        translateExistingProfile = {
            order = 2,
            type = "execute",
            name = L["Translate Existing Data"],
            desc = L["Translate NPC names and types with your language."],
            width = 2,
            func = function()
                MH:Translate()
            end
        }
    }
}
