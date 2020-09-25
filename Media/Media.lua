local W, F, L = unpack(select(2, ...))
local locale = GetLocale()
local format = format

W.Media = {
	Icons = {},
	Textures = {}
}

local MediaPath = "Interface\\Addons\\WindDungeonHelper\\Media\\"

do
	local template = "|T%s:%d:%d:0:0:64:64:5:59:5:59|t"
	local s = 14
	function F.GetIconString(icon, size)
		return format(template, icon, size or s, size or s)
	end
end

local function AddMedia(name, file, type)
	W.Media[type][name] = MediaPath .. type .. "\\" .. file
end

if locale == "zhCN" then
	AddMedia("logo", "WindDungeonHelper_zhCN.tga", "Textures")
elseif locale == "zhTW" then
	AddMedia("logo", "WindDungeonHelper_zhTW.tga", "Textures")
else
	AddMedia("logo", "WindDungeonHelper.tga", "Textures")
end

AddMedia("sunUITank", "Tank.tga", "Icons")
AddMedia("sunUIHealer", "Healer.tga", "Icons")
AddMedia("sunUIDPS", "DPS.tga", "Icons")
