local mock_iii = require("tests.helpers.mock_iii")

local M = {}

local function load_with_env(script_path, env)
    if _VERSION == "Lua 5.1" and setfenv then
        local chunk, err = loadfile(script_path)
        if not chunk then
            error(err)
        end
        setfenv(chunk, env)
        chunk()
        return
    end

    local chunk, err = loadfile(script_path, "t", env)
    if not chunk then
        error(err)
    end
    chunk()
end

function M.new_context(opts)
    local env, state = mock_iii.create(opts)
    load_with_env("src/grid/iiiano.lua", env)
    return env, state
end

return M
