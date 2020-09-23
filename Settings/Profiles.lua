local W, F, L, P, O = unpack(select(2, ...))

P = {
    enable = true,
    minimap = true
}

function W:BuildDatabase()
    self.db = LibStub("AceDB-3.0"):New("WindDungeonHelperDB", {profile = P})
end