-- syntax_char/shared/config.lua

SyntaxCharConfig = {
    enableCharacterCreation = true,   -- if false, you could auto-generate chars

    maxCharacters = 1,                -- single character mode

    name = {
        minLength = 2,
        maxLength = 16,
        allowedPattern = "^[A-Za-z]+$"  -- letters only
    },

    allowedGenders = { "m", "f", "x" }
}
