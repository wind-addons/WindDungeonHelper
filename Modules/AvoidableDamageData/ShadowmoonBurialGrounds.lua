local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {574, 575, 576}

AD:AddData("Shadowmoon Burial Grounds", mistakes, mapIds)
