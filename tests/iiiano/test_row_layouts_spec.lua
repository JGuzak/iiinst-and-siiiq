local loader=require("tests.helpers.load_iiiano")

describe("Push-style row layouts",function()
    for _,height in ipairs({8,16}) do
        it("uses thirds and fourths in both note modes on a "..height.."-row grid",function()
            local env=loader.new_context({grid_size_y=height})
            local function control(col,row)
                if height==8 then
                    env.event_grid(14,1,1)
                    env.event_grid(12+col,row+1,1); env.event_grid(12+col,row+1,0)
                else
                    env.event_grid(6+col,row,1); env.event_grid(6+col,row,0)
                end
            end
            control(1,7) -- octave
            assert.are.equal(36,env.calc_midi_note(1,7))
            control(2,7) -- thirds, chromatic C to E
            assert.are.equal(28,env.calc_midi_note(1,7))
            control(3,7) -- fourths, chromatic C to F
            assert.are.equal(29,env.calc_midi_note(1,7))
            control(4,7) -- in-key
            control(2,7) -- thirds, C major C to E
            assert.are.equal(28,env.calc_midi_note(1,7))
            control(3,7) -- fourths, C major C to F
            assert.are.equal(29,env.calc_midi_note(1,7))
            control(2,2) -- C minor
            control(2,7) -- thirds, C minor C to E flat
            assert.are.equal(27,env.calc_midi_note(1,7))
            control(3,7) -- fourths, C minor C to F
            assert.are.equal(29,env.calc_midi_note(1,7))
        end)
    end
end)
