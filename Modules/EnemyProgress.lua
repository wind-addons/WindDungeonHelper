local W, F, L = unpack(select(2, ...))
local EP = W:NewModule("EnemyProgress", "AceHook-3.0")

local _G = _G

local format = format
local select = select
local tonumber = tonumber

local GameTooltip = _G.GameTooltip

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local TooltipDataProcessor_AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall

local Enum_TooltipDataType_Unit = Enum.TooltipDataType.Unit

local function isWindToolsLoaded()
	if C_AddOns_IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if E and E.private and E.private.WT and E.private.WT.tooltips and E.private.WT.tooltips.objectiveProgress then
			return true
		end
	end
end

function EP:AddEnemyProgress(tt, data)
	if not _G.MDT or not self.db or not self.db.enable then
		return
	end

	if isWindToolsLoaded() or not tt or not tt == _G.GameTooltip and not tt.NumLines or tt:NumLines() == 0 then
		return
	end

	local npcID = select(6, strsplit("-", data.guid))
	local count, max = _G.MDT:GetEnemyForces(tonumber(npcID))

	if not count or not max or count == 0 or max == 0 then
		return
	end

	local left = format("%s |cff00d1b2%s|r - |cffffdd57%s|r", F.GetIconString(618858, 16), count, max)
	local right = format("%s |cff209cee%s|r%%", F.GetIconString(5926319, 16), F.Round(count / max * 100, self.db.accuracy))
	GameTooltip:AddDoubleLine(left, right)
	GameTooltip:Show()
end

function EP:ProfileUpdate()
	self.db = W.db.enemyProgress

	if self.db and self.db.enable then
		TooltipDataProcessor_AddTooltipPostCall(Enum_TooltipDataType_Unit, function(...)
			self:AddEnemyProgress(...)
		end)
	end
end

EP.OnInitialize = EP.ProfileUpdate
