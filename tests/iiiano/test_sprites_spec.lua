local loader = require("tests.helpers.load_iiiano")

local function keybed(state)
    local values = {}
    for y = 1, 8 do
        for x = 1, 12 do values[#values + 1] = state.grid_state[x][y] end
    end
    return table.concat(values, ",")
end

describe("sprite feedback", function()
    it("shows root, scale, layout and MIDI sprites while held, then restores the keybed", function()
        local env, state = loader.new_context()
        env.event_grid(14, 1, 1)
        local baseline = keybed(state)
        for _, button in ipairs({{13, 5}, {13, 2}, {13, 8}}) do
            env.event_grid(button[1], button[2], 1)
            local image = keybed(state)
            assert.is_true(image ~= baseline)
            for y = 1, 8 do for x = 1, 12 do
                local b = state.grid_state[x][y]
                assert.is_true(b == 0 or b == 15)
            end end
            env.event_grid(button[1], button[2], 0)
            assert.is_true(keybed(state) ~= image)
            baseline = keybed(state)
        end
        env.event_grid(15, 1, 1)
        for _, button in ipairs({{13, 5}, {13, 2}}) do
            local before = keybed(state)
            env.event_grid(button[1], button[2], 1)
            assert.is_true(keybed(state) ~= before)
            env.event_grid(button[1], button[2], 0)
            assert.are.equal(before, keybed(state))
        end
    end)

    it("keeps the latest sprite visible when an earlier button is released", function()
        local env, state = loader.new_context()
        env.event_grid(14, 1, 1)
        env.event_grid(13, 5, 1)
        env.event_grid(13, 2, 1)
        local image = keybed(state)
        env.event_grid(13, 5, 0)
        assert.are.equal(image, keybed(state))
        env.event_grid(13, 2, 0)
        assert.is_true(image ~= keybed(state))
    end)
    it("ignores unassigned scale buttons on both grid sizes", function()
        for _,height in ipairs({8,16}) do
            local env, state = loader.new_context({grid_size_y=height})
            local sx, sy, blank_x, blank_y, offset, width
            if height==8 then
                env.event_grid(14,1,1)
                sx,sy,blank_x,blank_y,offset,width=13,2,15,4,0,12
            else
                sx,sy,blank_x,blank_y,offset,width=7,1,9,3,8,16
            end
            local function snapshot()
                local values={}
                for y=1+offset,8+offset do for x=1,width do
                    values[#values+1]=state.grid_state[x][y]
                end end
                return table.concat(values,",")
            end
            env.event_grid(sx,sy,1); env.event_grid(sx,sy,0)
            local normal=snapshot()
            for x=blank_x,blank_x+1 do
                env.event_grid(x,blank_y,1)
                assert.are.equal(normal,snapshot())
                env.event_grid(x,blank_y,0)
                assert.are.equal(normal,snapshot())
            end
            env.event_grid(sx,sy,1)
            local held=snapshot()
            env.event_grid(blank_x,blank_y,1); env.event_grid(blank_x,blank_y,0)
            assert.are.equal(held,snapshot())
            env.event_grid(sx,sy,0)
            assert.are.equal(normal,snapshot())
        end
    end)
end)
