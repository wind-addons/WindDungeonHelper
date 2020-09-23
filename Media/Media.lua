local W, F, L = unpack(select(2, ...))
local format = format

W.Media = {
	Icons = {},
	Textures = {}
}

local MediaPath = "Interface\\Addons\\ElvUI_WindTools\\Media\\"

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

AddMedia("Tank", "Tank.tga", "Icons")
AddMedia("Damager", "Damager.tga", "Icons")
AddMedia("Healer", "Healer.tga", "Icons")