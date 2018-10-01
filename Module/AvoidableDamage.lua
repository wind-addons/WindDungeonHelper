local AddOnName, WDH = ...
local L = WDH.L
local B = WDH.Base
local C = WDH.Config
local DB = WDH.DataBase
-- local AD = WDH:NewModule("AvoidableDamage", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

DB.defaults.profile.modules.AvoidableDamage = {
    enable = true,
    public = true,
    custom_text = false,
}

C.ModulesOrder.AvoidableDamage = 20
C.ModulesOption.AvoidableDamage = {
    name = L["Avoidable Damage"],
    type = "group",
    args = {
        enable = {
            order = 1,
            name = L["Enable"],
            desc = L["Enables / disables the module"],
            type = "toggle",
            set = function(info,value) DB.profile.modules.AvoidableDamage.enable = value end,
            get = function(info) return DB.profile.modules.AvoidableDamage.enable end
        },
    }
}

-- function AD:OnInitialize()
--     self:RegisterEvent("PLAYER_ENTERING_WORLD")
-- end

function WDH:PLAYER_ENTERING_WORLD()
    print("AD Loaded")
end