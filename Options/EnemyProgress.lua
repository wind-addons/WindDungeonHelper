local W, F, L, _, O = unpack(select(2, ...))
local EP = W:GetModule("EnemyProgress")

O.enemyProgress = {
    order = 4,
    name = L["Enemy Progress"],
    type = "group",
    get = function(info)
        return W.db[info[#info - 1]][info[#info]]
    end,
    set = function(info, value)
        W.db[info[#info - 1]][info[#info]] = value
        EP:ProfileUpdate()
    end,
    args = {
        enable = {
            order = 1,
            name = L["Enable"],
            desc = L["Enables / disables the module"],
            type = "toggle",
            width = "full"
        }
    }
}
