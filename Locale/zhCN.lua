local AddOnName, _ = ...
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(AddOnName, "zhCN")
if not L then return end
-- zhCN
L["Wind Dungeon Helper"] = "Wind 地下城助手"
L["Author"] = "作者"
L["Description"] = "简介"
L["Wind Dungeon Helper is an addon that can help you fight in dungeon easier. \n\nWind Dungeon Helper is works with modules.\nIf you want to share the module you built, just pull request on addon github page."] = "Wind 地下城助手是一个能帮助你在地下城战斗的插件。\n\nWind 地下城助手功能均由模块完成。\n如果你想分享你的独创模块，只要在插件的 Github 主页上提交合并请求即可。"
L["Modules"] = "模块"
L["Enable"] = "启用"
L["Enables / disables Wind Dungeon Helper"] = "启用/停用 Wind 地下城助手"
L["Enables / disables the module"] = "启用/停用该模块"

-- Avoidable Damage
L["Avoidable Damage"] = "可规避伤害"