local M = {}

local function copy_math_with_random(state)
    local m = {}
    for k, v in pairs(math) do
        m[k] = v
    end

    m.random = function(min, max)
        state.random_ranges[#state.random_ranges + 1] = {min, max}
        local next_val = table.remove(state.random_queue, 1)
        if next_val == nil then
            if min ~= nil and max ~= nil then
                return min
            end
            return 0
        end
        return next_val
    end

    return m
end

function M.create(opts)
    opts = opts or {}
    local max_y = opts.grid_size_y or 8

    local state = {
        grid_state = {},
        grid_calls = {},
        midi_calls = {},
        metro_calls = {},
        metros = {},
        next_metro_id = 0,
        time_ms = opts.time_ms or 0,
        random_queue = {},
        random_ranges = {},
    }

    for x = 1, 16 do
        state.grid_state[x] = {}
        for y = 1, max_y do
            state.grid_state[x][y] = 0
        end
    end

    function state.clear_logs()
        state.grid_calls = {}
        state.midi_calls = {}
        state.metro_calls = {}
    end

    function state.set_time(ms)
        state.time_ms = ms
    end

    function state.set_random_queue(values)
        state.random_queue = {}
        for i = 1, #values do
            state.random_queue[i] = values[i]
        end
    end

    local env = {}
    setmetatable(env, { __index = _G })

    env.math = copy_math_with_random(state)

    env.grid_size_x = function()
        return 16
    end

    env.grid_size_y = function()
        return max_y
    end

    env.grid_led = function(x, y, brightness)
        if state.grid_state[x] == nil then
            state.grid_state[x] = {}
        end
        state.grid_state[x][y] = brightness
        state.grid_calls[#state.grid_calls + 1] = {
            type = "grid_led",
            x = x,
            y = y,
            brightness = brightness,
        }
    end

    env.grid_led_all = function(brightness)
        for x = 1, 16 do
            for y = 1, max_y do
                state.grid_state[x][y] = brightness
            end
        end
        state.grid_calls[#state.grid_calls + 1] = {
            type = "grid_led_all",
            brightness = brightness,
        }
    end

    env.grid_refresh = function()
        state.grid_calls[#state.grid_calls + 1] = { type = "grid_refresh" }
    end

    env.grid_led_get = function(x, y)
        return state.grid_state[x][y] or 0
    end

    env.midi_note_on = function(note, velocity, channel)
        state.midi_calls[#state.midi_calls + 1] = {
            type = "note_on",
            note = note,
            velocity = velocity,
            channel = channel,
        }
    end

    env.midi_note_off = function(note, velocity, channel)
        state.midi_calls[#state.midi_calls + 1] = {
            type = "note_off",
            note = note,
            velocity = velocity,
            channel = channel,
        }
    end

    env.midi_cc = function(cc, value, channel)
        state.midi_calls[#state.midi_calls + 1] = {
            type = "cc",
            cc = cc,
            value = value,
            channel = channel,
        }
    end

    env.metro = {
        init = function(callback, interval)
            state.next_metro_id = state.next_metro_id + 1
            local timer = { id = state.next_metro_id, callback = callback, interval = interval }
            state.metros[timer.id] = timer
            state.metro_calls[#state.metro_calls + 1] = { type = "new", id = timer.id, interval = interval }
            function timer:start()
                self.running = true
                state.metro_calls[#state.metro_calls + 1] = { type = "start", id = self.id }
            end
            function timer:stop()
                self.running = false
                state.metro_calls[#state.metro_calls + 1] = { type = "stop", id = self.id }
            end
            return timer
        end,
    }

    env.linlin = function(value, in_min, in_max, out_min, out_max)
        return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)
    end

    env.round = function(value, precision)
        return math.floor(value / precision + 0.5) * precision
    end

    env.clamp = function(value, min, max)
        return math.max(min, math.min(max, value))
    end

    env.get_time = function()
        return state.time_ms / 1000
    end

    return env, state
end

return M
