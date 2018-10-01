local AddOnName, _ = ...
local AceLocale = LibStub:GetLibrary("AceLocale-3.0")
local L = AceLocale:NewLocale(AddOnName, "zhTW")
if not L then return end
-- zhTW
L["Wind Dungeon Helper"] = "Wind 地城助手"
L["Author"] = "作者"
L["Description"] = "簡介"
L["Wind Dungeon Helper is an addon that can help you fight in dungeon easier. \n\nWind Dungeon Helper is works with modules.\nIf you want to share the module you built, just pull request on addon github page."] = "Wind 地城助手是一個能幫助你在地下城戰鬥的插件。\n\nWind 地城助手功能均由模组完成。\n如果你想分享你的獨創模組，只要在插件的 Github 主頁上提交合並請求即可。"
L["Modules"] = "模組"
L["Enable"] = "開啟"
L["Enables / disables Wind Dungeon Helper"] = "開啟/關閉 Wind 地城助手"
L["Enables / disables the module"] = "開啟/關閉該模組"

-- Avoidable Damage
L["Avoidable Damage"] = "可規避傷害"