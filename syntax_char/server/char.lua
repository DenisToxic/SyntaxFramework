-- resources/[syntax]/syntax_char/server/char.lua

Syntax = Syntax or {}
Syntax.Char = {} -- This table MUST be defined for init.lua to work

-- DB Helpers
local function DB_Query(sql, params, cb) exports.syntax_core:DB_Query(sql, params, cb) end
local function DB_Scalar(sql, params, cb) exports.syntax_core:DB_Scalar(sql, params, cb) end

-------------------------------------------------
-- API Methods (Used by init.lua)
-------------------------------------------------

--- Load the most recent character for an account
function Syntax.Char.LoadCharacter(accountId, cb)
    -- We select the one with the highest ID (latest created) or add a 'last_played' column later
    local query = "SELECT * FROM syntax_characters WHERE account_id = ? AND is_deleted = 0 ORDER BY id DESC LIMIT 1"
    
    DB_Query(query, { accountId }, function(rows)
        if rows and rows[1] then
            -- Parse JSON fields for convenience
            if rows[1].position and type(rows[1].position) == "string" then
                rows[1].position = json.decode(rows[1].position)
            end
            cb(rows[1])
        else
            cb(nil)
        end
    end)
end

--- Create a new character
function Syntax.Char.CreateCharacter(accountId, data, cb)
    local query = [[
        INSERT INTO syntax_characters 
        (account_id, first_name, last_name, dob, gender, position) 
        VALUES (?, ?, ?, ?, ?, ?)
    ]]
    
    local defaultPos = json.encode({x = -1037.74, y = -2738.04, z = 20.169, h = 0.0})

    exports.oxmysql:insert(query, {
        accountId,
        data.first_name,
        data.last_name,
        data.dob,
        data.gender,
        defaultPos
    }, function(insertId)
        if insertId then
            -- Return the constructed character object
            local newChar = {
                id = insertId,
                account_id = accountId,
                first_name = data.first_name,
                last_name = data.last_name,
                dob = data.dob,
                gender = data.gender,
                position = json.decode(defaultPos)
            }
            cb(newChar, nil)
        else
            cb(nil, "database_error")
        end
    end)
end

--- Save character position
function Syntax.Char.SavePosition(charId, coords)
    local posJson = json.encode(coords)
    local query = "UPDATE syntax_characters SET position = ? WHERE id = ?"
    
    -- Fire and forget (no callback needed usually)
    exports.syntax_core:DB_Query(query, { posJson, charId })
end