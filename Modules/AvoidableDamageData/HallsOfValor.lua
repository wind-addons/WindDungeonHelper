local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {703, 704, 705}

AD:AddData("Halls of Valor", mistakes, mapIds)
