local AddOnName, WDH = ...
local L = WDH.L
local B = WDH.Base
local C = WDH.Config
local DB = WDH.DataBase

function WDH:OnInitialize()
    DB.profile = LibStub("AceDB-3.0"):New(AddOnName.."DB", DB.defaults).profile
    self:SetUpConfig()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function WDH:PLAYER_ENTERING_WORLD()
    --for i,v in pairs(B.OptionFrame2) do print(i,v) end
end

function WDH:SetUpConfig()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName, function() return C.CreateOptionTable() end)
    local optionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, B.AddonName)
    
    local logo = CreateFrame('Frame', nil, optionFrame)
    logo:SetFrameLevel(4)
    logo:SetSize(64, 64)
    logo:SetPoint('TOPRIGHT', -8, -8)
    logo:SetBackdrop({bgFile = ('Interface\\ICONS\\Achievement_Dungeon_Mythic15'):format(AddOnName)})
    optionFrame.logo = logo
end