local B, C, L, P = unpack(select(2, ...))
local AddOnName, ns = ...
WDH = LibStub("AceAddon-3.0"):NewAddon(AddOnName)

function WDH:OnInitialize()
    L = LibStub("AceLocale-3.0"):GetLocale(AddOnName)
    P = LibStub("AceDB-3.0"):New("WindDungeonHelperDB", C.defaultDB).profile

    B.Title = L["Wind Dungeon Helper"]
    B.Version = GetAddOnMetadata(AddOnName, "Version")

    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName, C.optionsTable)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, B.Title)
end

function WDH:OnEnable()
end