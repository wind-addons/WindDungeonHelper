local W, F, L = unpack(select(2, ...))

local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo

W.MythicPlusMapData = {
	-- https://wago.tools/db2/MapChallengeMode
	-- https://wago.tools/db2/GroupFinderActivityGrp
	[247] = { abbr = L["[ABBR] The MOTHERLODE!!"], activityID = 140, timers = { 1188, 1584, 1980 } },
	[370] = { abbr = L["[ABBR] Operation: Mechagon - Workshop"], activityID = 257, timers = { 1118, 1536, 1920 } },
	[382] = { abbr = L["[ABBR] Theater of Pain"], activityID = 266, timers = { 1224, 1632, 2040 } },
	[499] = { abbr = L["[ABBR] Priory of the Sacred Flame"], activityID = 324, timers = { 1170, 1560, 1950 } },
	[500] = { abbr = L["[ABBR] The Rookery"], activityID = 325, timers = { 1044, 1392, 1740 } },
	[504] = { abbr = L["[ABBR] Darkflame Cleft"], activityID = 322, timers = { 1116, 1488, 1860 } },
	[506] = { abbr = L["[ABBR] Cinderbrew Meadery"], activityID = 327, timers = { 1188, 1584, 1980 } },
	[525] = { abbr = L["[ABBR] Operation: Floodgate"], activityID = 371, timers = { 1188, 1584, 1980 } },
}

function W:InitializeMetadata()
	for id in pairs(W.MythicPlusMapData) do
		local name, _, timeLimit, tex = C_ChallengeMode_GetMapUIInfo(id)
		W.MythicPlusMapData[id].name = name
		W.MythicPlusMapData[id].tex = tex
		W.MythicPlusMapData[id].idString = tostring(id)
		W.MythicPlusMapData[id].timeLimit = timeLimit
		if W.MythicPlusMapData[id].timers then
			W.MythicPlusMapData[id].timers[#W.MythicPlusMapData[id].timers] = timeLimit
		end
	end
end