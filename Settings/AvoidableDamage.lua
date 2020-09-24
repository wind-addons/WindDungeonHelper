local W, F, L, P, O = unpack(select(2, ...))

P.avoidableDamage = {
    enable = true,
    notification = {
        enable = true,
        compatible = true,
        outputmode = "party",
        threshold = 30,
        unit = "western",
        accuracy = 1
    },
    rank = {
        enable = true,
        worst = false,
        customWorst = L["Need improve"]
    },
    custom = {
        enable = false,
        warningMessage = L["%name% got hit by %spell%."],
        stacksMessage = L["%name% got hit by %spell%. %stack% Stacks."],
        spellMessage = L["%name% got hit by %spell% for %damage% (%percent%)."]
    }
}