local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {429, 430}

AD:AddData("Temple of the Jade Serpent", mistakes, mapIds)
