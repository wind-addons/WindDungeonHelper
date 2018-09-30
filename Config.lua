local B, C, L, P = unpack(select(2, ...))

C.defaultDB = {
    profile = {
        enable = true,
    }
}

C.optionsTable = {
    type = "group",
    name = L["Wind Dungeon Helper"],
    args = {
        enable = {
            order = 10,
            name = "Enable",
            desc = "Enables / disables the addon",
            type = "toggle",
            set = function(info,val) P.enable = val end,
            get = function(info) return P.enable end
        },
        moreoptions = {
            order = 20,
            name = "More Options",
            type = "group",
            args = {
                text = {
                    name = "test title",
                    desc = "New test title",
                    type = "description",
                }
            }
        }
    }
}