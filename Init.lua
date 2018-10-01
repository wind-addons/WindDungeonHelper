local AddOnName, WDH = ...
local pairs = pairs
LibStub("AceAddon-3.0"):NewAddon(WDH, AddOnName, "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(AddOnName, true)
WDH.L = L
WDH.Base = {}
WDH.Config = {}
WDH.DataBase = {}
local B = WDH.Base
local DB = WDH.DataBase
--------------------------------------------------------------
-- Base
B.AddonName = L["Wind Dungeon Helper"]
B.Version = GetAddOnMetadata(AddOnName, "Version")
--------------------------------------------------------------
-- Config
WDH.Config.ModulesOrder = {}
WDH.Config.ModulesOption = {}
function WDH.Config.CreateOptionTable()
    local tempOptionsTable = {
        type = "group",
        name = B.ColorString(B.AddonName).." - "..B.Version,
        args = {
            author = {
                order = 1,
                name = L["Author"]..": "..B.ColorString("五氣歸元-暗影之月(TW)", 0, 1, 0.59).." @ "..B.ColorString("人生海海"),
                type = "description",
            },
            enable = {
                order = 2,
                name = L["Enable"],
                desc = L["Enables / disables Wind Dungeon Helper"],
                type = "toggle",
                set = function(info,val) DB.profile.enable = val end,
                get = function(info) return DB.profile.enable end
            },
            addondesctitle = {
				order = 3,
				type = "header",
				name = L["Description"],
            },
            addondesctext = {
				order = 4,
				type = "description",
				name = L["Wind Dungeon Helper is an addon that can help you fight in dungeon easier. \n\nWind Dungeon Helper is works with modules.\nIf you want to share the module you built, just pull request on addon github page."],
            },
            moduleconfigtitle = {
				order = 5,
				type = "header",
				name = L["Modules"],
            },
        }
    }

    for k, v in pairs(WDH.Config.ModulesOption) do
        tempOptionsTable.args.k = v
        tempOptionsTable.args.k.order = WDH.Config.ModulesOrder.k
    end

    return tempOptionsTable
end

--------------------------------------------------------------
-- DataBase
DB.defaults = {
    profile = {
        enable = true,
        modules = {},
    }
}

------------------------------------------
-- 摘自 ElvUI 源代码
-- 转换 RGB 数值为 16 进制
-- 此处 r, g, b 各值均为 0~1 之间
local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return format("%02x%02x%02x", r*255, g*255, b*255)
end
-- 改自 ElvUI_CustomTweaks
-- 为字符串添加自定义颜色
function B.ColorString(str, r, g, b)
	local hex
	local coloredString
	
	if r and g and b then
		hex = RGBToHex(r, g, b)
	else
		-- 默认设置为浅蓝色
		hex = RGBToHex(52/255, 152/255, 219/255)
	end
	
	coloredString = "|cff"..hex..str.."|r"
	return coloredString
end

