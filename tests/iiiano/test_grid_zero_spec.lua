local loader = require("tests.helpers.load_iiiano")

describe("16 by 16 grid", function()
    it("shows the three panels and plays notes across the full bottom half", function()
        local env, state = loader.new_context({grid_size_y=16})
        assert.are.equal(8, state.grid_state[3][2]) -- velocity mode
        assert.are.equal(15, state.grid_state[7][1]) -- major scale
        assert.are.equal(15, state.grid_state[12][4]) -- MIDI channel 1
        assert.are.equal(10, state.grid_state[1][16])
        assert.are.equal(0, state.grid_state[16][16])
        assert.are.equal(0, state.grid_state[11][1])
        for x=1,16 do assert.are.equal(0, state.grid_state[x][8]) end
        for y=1,7 do
            for _,x in ipairs({1,6,11,16}) do
                assert.are.equal(0, state.grid_state[x][y])
                env.event_grid(x,y,1); env.event_grid(x,y,0)
            end
        end
        assert.are.equal(0,#state.midi_calls)
        env.event_grid(2,8,1)
        assert.are.equal(8, state.grid_state[3][2])
        env.event_grid(16,16,1); env.event_grid(16,16,0)
        assert.are.equal(39, state.midi_calls[1].note)
        assert.are.equal("note_off", state.midi_calls[2].type)
    end)

    it("applies all three panels without layer switching and preserves octave spacing", function()
        local env, state = loader.new_context({grid_size_y=16})
        env.event_grid(7,7,1); env.event_grid(7,7,0) -- octave layout
        env.event_grid(1,9,1); env.event_grid(1,9,0)
        assert.are.equal(108, state.midi_calls[1].note)
        env.event_grid(13,4,1); env.event_grid(13,4,0) -- channel 2
        env.event_grid(1,16,1); env.event_grid(1,16,0)
        assert.are.equal(2, state.midi_calls[3].channel)
        env.event_grid(3,2,1) -- random velocity mode
        assert.are.equal(15, state.grid_state[3][2])
        env.event_grid(4,2,1); env.event_grid(3,7,1); env.event_grid(4,2,0)
        assert.are.equal(1, state.grid_state[4][2])
        assert.are.equal(1, state.grid_state[4][3])
    end)

    it("centers sprites on the bottom keybed and restores its edges", function()
        local env, state = loader.new_context({grid_size_y=16})
        local left, right = state.grid_state[1][16], state.grid_state[16][16]
        env.event_grid(7,4,1) -- root C
        assert.are.equal(0, state.grid_state[1][16])
        assert.are.equal(0, state.grid_state[16][16])
        assert.are.equal(15, state.grid_state[8][9])
        env.event_grid(7,4,0)
        assert.are.equal(left,state.grid_state[1][16])
        assert.are.equal(right,state.grid_state[16][16])
        assert.are.equal(15,state.grid_state[7][4])
    end)
end)
