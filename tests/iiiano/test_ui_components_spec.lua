package.path = table.concat({
    package.path,
    "./?.lua",
    "./?/init.lua",
}, ";")
local loader = require("tests.helpers.load_iiiano")

describe("test_ui_components", function()
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

    it("utility_decode_helpers", function()
        local env = new_context()

        local row = env.decomp_rle({ 3, 1, 2, 0, 1, 5 })
        assert.are.equal(6, #row)
        assert.are.equal(1, row[1])
        assert.are.equal(0, row[4])
        assert.are.equal(5, row[6])

        local sprite = env.render_sprite({
            { 2, 7, 1, 0 },
            { 1, 2, 2, 1 },
        })
        assert.are.equal(2, #sprite)
        assert.are.equal(7, sprite[1][1])
        assert.are.equal(0, sprite[1][3])
        assert.are.equal(1, sprite[2][3])
    end)

    it("dirty_leds_batch_and_refresh_once", function()
        local env, state = new_context()
        state.clear_logs()

        env.set_led(1, 1, 5)
        env.apply_dirty_leds()
        assert.are.equal(1, count_calls(state.grid_calls, "grid_led"))
        assert.are.equal(1, count_calls(state.grid_calls, "grid_refresh"))
        assert.are.equal(5, state.grid_state[1][1])

        state.clear_logs()
        env.set_led(1, 1, 5)
        env.apply_dirty_leds()
        assert.are.equal(0, #state.grid_calls)
    end)

    it("mark_region_dirty_applies_only_in_bounds", function()
        local env, state = new_context()
        state.clear_logs()

        env.mark_region_dirty(0, 0, 2, 2)
        env.apply_dirty_leds()

        assert.are.equal(4, count_calls(state.grid_calls, "grid_led"))
        assert.are.equal(1, count_calls(state.grid_calls, "grid_refresh"))
    end)

    it("scale_and_root_selection_change_mapping", function()
        local env = new_context()

        env.event_grid(14, 1, 1)
        env.event_grid(16, 5, 1)
        assert.are.equal(27, env.calc_midi_note(1, 8))

        env.event_grid(15, 2, 1)
        assert.is_true(env.is_note_in_scale(25), "C# should be in selected phrygian scale")
    end)

    it("note_class_rendering_shows_dim_shared_class", function()
        local env, state = new_context()
        state.clear_logs()

        env.event_grid(1, 8, 1)

        assert.are.equal(13, state.grid_state[1][8])
        assert.are.equal(12, state.grid_state[8][7])
    end)

    it("performance_layer_brightness_branches", function()
        local env = new_context()

        assert.are.equal(10, env.get_performance_layer_b(13, 3, 1))
        assert.are.equal(2, env.get_performance_layer_b(13, 2, 1))

        env.handle_trans_sel(13, 2)
        assert.are.equal(10, env.get_performance_layer_b(13, 2, 1))

        assert.are.equal(4, env.get_performance_layer_b(13, 2, 7))
        env.handle_note_hold_mode_press(13, 2, 1, 7)
        assert.are.equal(15, env.get_performance_layer_b(13, 2, 7))
    end)

    it("keybed_layer_brightness_branches", function()
        local env = new_context()

        env.handle_root_note_sel(13, 5)
        assert.are.equal(15, env.get_keybed_layer_b(13, 5, 1))
        assert.are.equal(1, env.get_keybed_layer_b(14, 5, 1))

        env.handle_keybed_off_sel(13, 8)
        assert.are.equal(8, env.get_keybed_layer_b(13, 8, 2))
        assert.are.equal(2, env.get_keybed_layer_b(14, 8, 2))

        env.handle_scale_sel(14, 2)
        assert.are.equal(15, env.get_keybed_layer_b(14, 2, 3))
        assert.are.equal(1, env.get_keybed_layer_b(13, 2, 3))
    end)

    it("midi_layer_channel_select_and_panic_release", function()
        local env, state = new_context()
        state.clear_logs()

        env.event_grid(15, 1, 1)
        env.event_grid(16, 5, 1)
        env.event_grid(1, 8, 1)
        assert.are.equal("note_on", state.midi_calls[#state.midi_calls].type)
        assert.are.equal(4, state.midi_calls[#state.midi_calls].channel)

        env.handle_midi_layer_press(13, 2, 1, 2)
        assert.are.equal(15, env.get_midi_layer_b(13, 2, 2))
        env.handle_midi_layer_press(13, 2, 0, 2)
        assert.are.equal(7, env.get_midi_layer_b(13, 2, 2))
    end)

    it("layer_select_entering_perf_restarts_metro", function()
        local env, state = new_context()
        local base_new = count_calls(state.metro_calls, "new")

        env.event_grid(14, 1, 1)
        env.event_grid(13, 1, 1)

        assert.are.equal(base_new, count_calls(state.metro_calls, "new"))
        assert.are.equal(2, count_calls(state.metro_calls, "start"))
        assert.is_true(count_calls(state.metro_calls, "stop") >= 1)
    end)

    it("layer_select_leaving_perf_clears_metro_timer", function()
        local env, state = new_context()
        local base_new = count_calls(state.metro_calls, "new")
        local base_stop = count_calls(state.metro_calls, "stop")

        env.event_grid(14, 1, 1)

        assert.are.equal(base_new, count_calls(state.metro_calls, "new"))
        assert.are.equal(base_stop + 1, count_calls(state.metro_calls, "stop"))
    end)

    it("layer_select_perf_timer_restarts_on_reenter_and_reselect", function()
        local env, state = new_context()
        local base_new = count_calls(state.metro_calls, "new")
        local base_stop = count_calls(state.metro_calls, "stop")

        env.event_grid(14, 1, 1)
        assert.are.equal(base_new, count_calls(state.metro_calls, "new"))
        assert.are.equal(base_stop + 1, count_calls(state.metro_calls, "stop"))

        env.event_grid(13, 1, 1)
        assert.are.equal(base_new, count_calls(state.metro_calls, "new"))
        assert.are.equal(base_stop + 2, count_calls(state.metro_calls, "stop"))

        env.event_grid(13, 1, 1)
        assert.are.equal(base_new, count_calls(state.metro_calls, "new"))
        assert.are.equal(base_stop + 3, count_calls(state.metro_calls, "stop"))
    end)

    it("grid_dispatch_zone2_invalid_layer_index_no_change", function()
        local env, state = new_context()
        local new_count = count_calls(state.metro_calls, "new")
        local stop_count = count_calls(state.metro_calls, "stop")

        env.event_grid(16, 1, 1)

        assert.are.equal(new_count, count_calls(state.metro_calls, "new"))
        assert.are.equal(stop_count, count_calls(state.metro_calls, "stop"))
    end)

    it("velocity_index_helpers_and_selection", function()
        local env = new_context()

        local x, y = env.get_v_pos_from_i(1)
        assert.are.equal(13, x)
        assert.are.equal(8, y)

        local x2, y2 = env.get_v_pos_from_i(16)
        assert.are.equal(16, x2)
        assert.are.equal(5, y2)

        assert.are.equal(10, env.get_v_from_vi(1))
        assert.are.equal(127, env.get_v_from_vi(16))
        assert.are.equal(1, env.get_vi_from_v(10))
        assert.are.equal(16, env.get_vi_from_v(127))

        env.h_vel_select(16, 5)
        assert.are.equal(2, env.get_performance_layer_b(16, 5, 2))
        assert.are.equal(0, env.get_performance_layer_b(13, 8, 2))
    end)

    it("root_and_scale_index_position_helpers", function()
        local env = new_context()

        assert.are.equal(1, env.get_rn_from_pos(13, 5))
        assert.are.equal(6, env.get_rn_from_pos(14, 6))
        assert.are.equal(11, env.get_rn_from_pos(15, 7))

        assert.are.equal(1, env.get_si_from_pos(13, 2))
        assert.are.equal(6, env.get_si_from_pos(14, 3))
        assert.are.equal(10, env.get_si_from_pos(14, 4))
    end)

    it("in_key_toggle_and_zone4_keybed_press_path", function()
        local env, state = new_context()
        state.clear_logs()

        env.handle_in_key_sel(13, 8)

        env.handle_keybed_layer_press(16, 8, 1, 4)
        assert.are.equal(0, #state.midi_calls)
    end)

    it("render_keybed_offset_selector_leds", function()
        local env, state = new_context()
        state.clear_logs()

        env.render_keybed_off_sel(15, 8)
        env.render_keybed_off_sel(13, 8)

        assert.are.equal(8, state.grid_state[15][8])
        assert.are.equal(2, state.grid_state[13][8])
    end)

    it("is_root_note_tracks_selected_root", function()
        local env = new_context()

        assert.is_true(env.is_root_note(24))
        assert.is_false(env.is_root_note(25))

        env.handle_root_note_sel(14, 5)
        assert.is_true(env.is_root_note(25))
    end)

    it("keybed_render_and_update_functions_apply_led_changes", function()
        local env, state = new_context()
        state.clear_logs()

        env.handle_scale_sel(14, 2)
        env.render_keybed()
        env.apply_dirty_leds()
        assert.is_true(count_calls(state.grid_calls, "grid_led") > 0)

        env.handle_keybed_press(1, 8, 1)
        env.h_vel_select(16, 5)

        state.clear_logs()
        env.update_keybed_key(8, 7)
        env.apply_dirty_leds()
        assert.is_true(count_calls(state.grid_calls, "grid_led") > 0)

        state.clear_logs()
        env.update_keybed_note_class(0)
        env.apply_dirty_leds()
        assert.is_true(count_calls(state.grid_calls, "grid_led") > 0)
    end)

    it("direct_midi_panic_press_emits_all_channels", function()
        local env, state = new_context()
        state.clear_logs()

        env.handle_midi_panic_press(13, 2)
        assert.are.equal(16, #state.midi_calls)
        assert.are.equal("cc", state.midi_calls[1].type)
        assert.are.equal(1, state.midi_calls[1].channel)
        assert.are.equal(16, state.midi_calls[16].channel)
    end)

    it("direct_perf_layer_press_handles_transpose_and_hold_paths", function()
        local env, state = new_context()
        state.clear_logs()

        env.handle_perf_layer_press(13, 2, 1, 1)
        assert.are.equal(36, env.calc_midi_note(1, 8))

        env.handle_keybed_press(1, 8, 1)
        state.clear_logs()

        env.handle_perf_layer_press(13, 2, 1, 5)
        assert.are.equal(0, #state.midi_calls)

        env.handle_perf_layer_press(13, 2, 1, 5)
        assert.are.equal(1, #state.midi_calls)
        assert.are.equal("note_off", state.midi_calls[1].type)
    end)

    it("direct_layer_select_and_layer_press_dispatch", function()
        local env, state = new_context()
        state.clear_logs()

        env.handle_layer_select_press(15, 1, 1)
        env.handle_layer_press(13, 2, 1)
        assert.are.equal(16, #state.midi_calls)

        state.clear_logs()
        env.handle_layer_press(12, 2, 1)
        assert.are.equal(0, #state.midi_calls)
        assert.are.equal(0, #state.grid_calls)
    end)

    it("layer_render_and_zone_update_helpers", function()
        local env, state = new_context()
        state.clear_logs()

        env.render_layer_select(13, 1)
        env.render_layer_select(14, 1)
        env.apply_dirty_leds()
        assert.are.equal(15, state.grid_state[13][1])
        assert.are.equal(2, state.grid_state[14][1])

        env.handle_trans_sel(13, 4)
        state.clear_logs()
        env.update_layer_zone(1)
        env.apply_dirty_leds()
        assert.is_true(count_calls(state.grid_calls, "grid_led") > 0)

        state.clear_logs()
        env.update_all_layer_zones()
        assert.is_true(count_calls(state.grid_calls, "grid_led") > 0)
        assert.is_true(count_calls(state.grid_calls, "grid_refresh") >= 1)
    end)

    it("update_keybed_leds_renders_after_scale_change", function()
        local env, state = new_context()
        env.handle_scale_sel(14, 2)
        state.clear_logs()

        env.update_keybed_leds()
        assert.is_true(count_calls(state.grid_calls, "grid_led") > 0)
        assert.are.equal("grid_refresh", state.grid_calls[#state.grid_calls].type)
    end)
end)
