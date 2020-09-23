local W, F, L, P, O = unpack(select(2, ...))

P = {
    enable = true,
    minimapIcon = {
        hide = false,
    }
}

function W:BuildDatabase()
    self.Database = LibStub("AceDB-3.0"):New("WindDungeonHelperDB", {profile = P})
    self.db = self.Database.profile
end