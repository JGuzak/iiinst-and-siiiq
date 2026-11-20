package.path = table.concat({
    package.path,
    "./?.lua",
    "./?/init.lua",
}, ";")

local loader = require("tests.helpers.load_iiiano")

describe("test_utility_components", function()
    local function count_calls(calls, call_type)
        local n = 0
        for i = 1, #calls do
            if calls[i].type == call_type then
                n = n + 1
            end
        end
        return n
    end

    local function new_context(opts)
        opts = opts or {}
        if opts.grid_size_y == nil then
            opts.grid_size_y = 8
        end
        return loader.new_context(opts)
    end

    it("init_calls_expected_system_paths", function()
        local _, state = new_context()
        assert.is_true(#state.grid_calls > 0, "init should touch grid")
        assert.are.equal(1, count_calls(state.metro_calls, "new"))
        assert.is_true(count_calls(state.grid_calls, "grid_led_all") >= 1, "init should clear grid")
    end)

    it("calc_midi_note_defaults", function()
        local env = new_context()

        assert.are.equal(24, env.calc_midi_note(1, 8))
        assert.are.equal(29, env.calc_midi_note(1, 7))
        assert.are.equal(25, env.calc_midi_note(2, 8))
    end)

    it("keybed_offset_mode_changes_note_layout", function()
        local env = new_context()

        env.event_grid(14, 1, 1)
        env.event_grid(13, 8, 1)
        assert.are.equal(108, env.calc_midi_note(1, 1), "oct mode should use 12 semitone row steps")

        env.event_grid(15, 8, 1)
        assert.are.equal(59, env.calc_midi_note(1, 1), "4ths mode should use 5 semitone row steps")
    end)

    it("key_press_release_sends_midi_on_off", function()
        local env, state = new_context()
        state.clear_logs()

        env.event_grid(1, 8, 1)
        env.event_grid(1, 8, 0)

        assert.are.equal(2, #state.midi_calls)
        assert.are.equal("note_on", state.midi_calls[1].type)
        assert.are.equal(24, state.midi_calls[1].note)
        assert.are.equal(104, state.midi_calls[1].velocity)
        assert.are.equal("note_off", state.midi_calls[2].type)
    end)

    it("repress_same_key_sends_note_off_before_new_on", function()
        local env, state = new_context()
        state.clear_logs()

        env.event_grid(1, 8, 1)
        env.event_grid(1, 8, 1)

        assert.are.equal(3, #state.midi_calls)
        assert.are.equal("note_on", state.midi_calls[1].type)
        assert.are.equal("note_off", state.midi_calls[2].type)
        assert.are.equal("note_on", state.midi_calls[3].type)
    end)

    it("note_hold_toggle_prevents_immediate_release", function()
        local env, state = new_context()
        state.clear_logs()

        env.event_grid(1, 8, 1)
        env.event_grid(14, 2, 1)

        state.midi_calls = {}
        env.event_grid(1, 8, 0)
        assert.are.equal(0, #state.midi_calls, "release should not emit note_off while held")

        env.event_grid(14, 2, 1)
        assert.are.equal(1, #state.midi_calls)
        assert.are.equal("note_off", state.midi_calls[1].type)
    end)

    it("transpose_changes_note_output_and_clamps", function()
        local env, state = new_context()
        state.clear_logs()

        env.event_grid(13, 2, 1)
        env.event_grid(1, 8, 1)
        assert.are.equal(36, state.midi_calls[#state.midi_calls].note)

        env.event_grid(13, 2, 1)
        env.event_grid(13, 2, 1)
        env.event_grid(1, 8, 1)
        assert.are.equal(48, state.midi_calls[#state.midi_calls].note)
    end)

    it("switching_layers_stops_perf_metro", function()
        local env, state = new_context()
        assert.are.equal(1, count_calls(state.metro_calls, "new"))
        assert.are.equal(0, count_calls(state.metro_calls, "stop"))

        env.event_grid(14, 1, 1)
        assert.is_true(count_calls(state.metro_calls, "stop") >= 1, "leaving perf should stop metro")
    end)

    it("midi_panic_sends_all_notes_off_cc_to_all_channels", function()
        local env, state = new_context()
        state.clear_logs()

        env.event_grid(15, 1, 1)
        env.event_grid(13, 2, 1)

        assert.are.equal(16, #state.midi_calls)
        for i = 1, 16 do
            assert.are.equal("cc", state.midi_calls[i].type)
            assert.are.equal(123, state.midi_calls[i].cc)
            assert.are.equal(127, state.midi_calls[i].value)
            assert.are.equal(i, state.midi_calls[i].channel)
        end
    end)

    it("utility_mappings", function()
        local env = new_context()

        assert.are.equal(101, env.get_key_id(1, 1))
        assert.are.equal("C", env.get_note_name(1))
        assert.are.equal("C#", env.get_note_name(2))
        assert.are.equal("C", env.get_note_name(15))
        assert.are.equal(1, env.get_vel_i(13, 8))
        assert.are.equal(16, env.get_vel_i(16, 5))
        assert.are.equal(1, env.get_midi_ch_from_pos(13, 5))
        assert.are.equal(3, env.get_layer_index(15, 1))
    end)

    it("render_selected_vel_blinks_by_time", function()
        local env, state = new_context({ time_ms = 0 })
        state.clear_logs()

        env.render_selected_vel()
        assert.is_true(count_calls(state.grid_calls, "grid_led") >= 1)
        assert.are.equal("grid_refresh", state.grid_calls[#state.grid_calls].type)

        state.clear_logs()
        state.set_time(300)
        env.render_selected_vel()
        assert.is_true(count_calls(state.grid_calls, "grid_led") >= 1)
        assert.are.equal("grid_refresh", state.grid_calls[#state.grid_calls].type)
    end)
end)
