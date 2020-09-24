local W, F, L, _, O = unpack(select(2, ...))

O.enemyProgress = {
    order = 4,
    name = L["Enemy Progress"],
    type = "group",
    get = function(info)
        return W.db[info[#info - 1]][info[#info]]
    end,
    args = {
        enable = {
            order = 1,
            name = L["Enable"],
            desc = L["Enables / disables the module"],
            type = "toggle",
            set = function(info, value)
                W.db[info[#info - 1]][info[#info]] = value
                -- if EP.db.enable then
                --     EP:Enable()
                -- else
                --     EP:Disable()
                -- end
            end,
            width = "full"
        }
    }
}
