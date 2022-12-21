local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {2073, 2074, 2075, 2076, 2077}

AD:AddData("The Azure Vault", mistakes, mapIds)
