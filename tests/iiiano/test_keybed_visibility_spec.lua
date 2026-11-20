local loader = require("tests.helpers.load_iiiano")

describe("keybed visibility", function()
    it("toggles chromatic notes while preserving scale highlights and playable notes", function()
        local env, state = loader.new_context()
        assert.are.equal(10, state.grid_state[1][8]) -- C, the root
        assert.are.equal(0, state.grid_state[2][8]) -- C#, outside C major
        assert.are.equal(4, state.grid_state[3][8]) -- D, in C major
        env.event_grid(14,1,1)
        assert.are.equal(4, state.grid_state[16][8])
        env.event_grid(16,8,1)
        env.event_grid(16,8,0)
        assert.are.equal(15, state.grid_state[16][8])
        assert.are.equal(4, state.grid_state[2][8])
        assert.are.equal(4, state.grid_state[3][8])
        state.clear_logs()
        env.event_grid(2,8,1)
        assert.are.equal(26, state.midi_calls[1].note)
        assert.is_true(state.grid_state[2][8] > 0)
        env.event_grid(2,8,0)
        assert.are.equal(4, state.grid_state[2][8])
        env.event_grid(16,8,1)
        env.event_grid(16,8,0)
        assert.are.equal(4, state.grid_state[16][8])
        assert.are.equal(0, state.grid_state[2][8])
        state.clear_logs()
        env.event_grid(2,8,1)
        assert.are.equal(25, state.midi_calls[1].note)
        assert.is_true(state.grid_state[2][8] > 0)
        env.event_grid(2,8,0)
        assert.are.equal(0, state.grid_state[2][8])
    end)

    it("updates visibility when the root or scale changes", function()
        local env, state = loader.new_context()
        env.event_grid(14,1,1)
        env.event_grid(16,8,1); env.event_grid(16,8,0)
        env.event_grid(15,2,1); env.event_grid(15,2,0) -- C phrygian
        assert.are.equal(4, state.grid_state[2][8]) -- C# is now in scale
        env.event_grid(15,5,1); env.event_grid(15,5,0) -- D root
        assert.are.equal(10, state.grid_state[1][8])
        assert.are.equal(4, state.grid_state[2][8]) -- D# is in D phrygian
        assert.are.equal(4, state.grid_state[3][8]) -- F is the next scale degree
    end)
end)
