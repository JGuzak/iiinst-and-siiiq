function decomp_rle(d)
	local r={}
	for i=1,#d,2 do
		local c,v=d[i],d[i+1]
		for j=1,c do
			table.insert(r,v)
		end
	end
	return r
end
function render_sprite(rows)
	local s={}
	for i,r in ipairs(rows) do
		s[i]=decomp_rle(r)
	end
	return s
end
-- Twelve-column, eight-row bitmaps; scale names use three-letter abbreviations.
local SPRITES={
	["C"]="060080080080080080060000", -- C
	["C#"]="32842847c42847c428328000", -- C#
	["D"]="0c00a00a00a00a00a00c0000", -- D
	["D#"]="62852857c52857c528628000", -- D#
	["E"]="0e00800800c00800800e0000", -- E
	["F"]="0e00800800c0080080080000", -- F
	["F#"]="72842847c62847c428428000", -- F#
	["G"]="0600800800a00a00a0060000", -- G
	["G#"]="32842847c52857c528328000", -- G#
	["A"]="0400a00a00e00a00a00a0000", -- A
	["A#"]="22852857c72857c528528000", -- A#
	["B"]="0c00a00a00c00a00a00c0000", -- B
	["oct"]="46ea84a84a84a84a84464000", -- OCT
	["3rds"]="ccc2aa2aa4ca2ca2aacac000", -- 3RD
	["4ths"]="aeaa4aa4ae4e24a24a24a000", -- 4TH
	["chromatic"]="6ac8aa8aa8ec8ac8aa6aa000", -- CHR
	["in_key"]="aeaa8ac8a8c4c84a84ae4000", -- KEY
	["major"]="a42ea2ea2ae2aaaaaaaa4000", -- MAJ
	["dorian"]="c4caaaaaaaacaacaaac4a000", -- DOR
	["phrygian"]="cacaaaaaacec8ac8aa8aa000", -- PHR
	["lydian"]="8ac8aa8aa84a84a84ae4c000", -- LYD
	["mixolydian"]="aeae4ae4aa44a4aa4aaea000", -- MIX
	["minor"]="ae9e4de4da4ba4ba49ae9000", -- MIN
	["locrian"]="8468a88a88a88a88a8e46000", -- LOC
	["natural_minor"]="927d52d52b72b52952952000", -- NAT
	["harmonic_minor"]="a4caaaaaaeecaacaaaaaa000", -- HAR
	["melodic_minor"]="ae8e88e88ac8a88a88aee000", -- MEL
	["panic"]="444444444444444000444000", -- !!!
	["1"]="0400c00400400400400e0000", -- 1
	["2"]="0e00200200e00800800e0000", -- 2
	["3"]="0e00200200e00200200e0000", -- 3
	["4"]="0a00a00a00e0020020020000", -- 4
	["5"]="0e00800800e00200200e0000", -- 5
	["6"]="0e00800800e00a00a00e0000", -- 6
	["7"]="0e0020020040040040040000", -- 7
	["8"]="0e00a00a00e00a00a00e0000", -- 8
	["9"]="0e00a00a00e00200200e0000", -- 9
	["10"]="1383281281281281283b8000", -- 10
	["11"]="1103301101101101103b8000", -- 11
	["12"]="1383081081381201203b8000", -- 12
	["13"]="1383081081381081083b8000", -- 13
	["14"]="128328128138108108388000", -- 14
	["15"]="1383201201381081083b8000", -- 15
	["16"]="1383201201381281283b8000", -- 16
}
local KEYBED_OFFSET_MODES={"oct","3rds","4ths"}
local NOTE_NAMES={"C","C#","D","D#","E","F","F#","G","G#","A","A#","B"}
local SCALES={
	major={1,0,1,0,1,1,0,1,0,1,0,1},
	dorian={1,0,1,1,0,1,0,1,0,1,1,0},
	phrygian={1,1,0,1,0,1,0,1,1,0,1,0},
	lydian={1,0,1,0,1,0,1,1,0,1,0,1},
	mixolydian={1,0,1,0,1,1,0,1,0,1,1,0},
	minor={1,0,1,1,0,1,0,1,1,0,1,0},
	locrian={1,1,0,1,0,1,1,0,1,0,1,0},
	natural_minor={1,0,1,1,0,1,0,1,1,0,1,0},
	harmonic_minor={1,0,1,1,0,1,0,1,1,0,0,1},
	melodic_minor={1,0,1,1,0,1,0,1,0,1,0,1},
}
local SCALE_ORD={"major","dorian","phrygian","lydian","mixolydian","minor","locrian","natural_minor","harmonic_minor","melodic_minor"}
local ZONES={
	{0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,-1},
	{0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1},
	{0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1}
}
local LAYERS={
	[""]={},
	["perf"]={{1,5,6,7},{1,8,4,3},{1,8,4,3},{2,2,2,2},{2,2,2,2},{2,2,2,2},{2,2,2,2}},
	["keybed"]={{3,3,3,3},{3,3,3,3},{3,3,0,0},{1,1,1,1},{1,1,1,1},{1,1,1,1},{2,2,2,4}},
	["midi"]={{2,2,2,2},{2,2,2,2},{0,0,0,0},{1,1,1,1},{1,1,1,1},{1,1,1,1},{1,1,1,1}}
}
local MAX_LAYER_ZONES = 8
local LAYER_ORD={"perf","keybed","midi"}
local MAX_X=grid_size_x()
local MAX_Y=grid_size_y()
local IS_ZERO=MAX_Y==16 and MAX_X==16
local KEYBED_W=IS_ZERO and 16 or 12
local KEYBED_H=8
local KEYBED_Y_OFFSET=IS_ZERO and 8 or 0
local CONTROL_OFFSET=12
local MAX_B=15
local INACTIVE_B=2
local VEL_METRO_RATE=0.25
local ACTIVE_B=10
local NOTE_IN_SCALE_B=ACTIVE_B-6
local KEYBED_OFFSET_ACTIVE_B=8
local MIN_VEL=1
local MAX_VEL=127
local cur_scale="major"
local root_note=1
local global_transpose=0
local note_hold_damper_id=nil
local note_hold_damper=false
local note_hold=false
local static_vel_metro_id=nil
local static_vel=104
local vel_mode="static"
local rand_vel_min=10
local rand_vel_max=MAX_VEL
local velocity_select_held={}
local velocity_select_order={}
local keybed_row_off="4ths"
local in_key_mode=false
local sprite_a=false
local cur_sprite=nil
local sprite_owner=nil
local pressed_keys={}
local trans_cache={}
local scale_degrees={}
local layer=LAYERS[LAYER_ORD[1]]
local midi_ch=1
local midi_pnc_hld=false
local led_state={}
local dirty={}
local refresh_pending=false
function set_led(x,y,b)
	if led_state[x][y]~=b then
		led_state[x][y]=b
		dirty[x][y]=true
		refresh_pending=true
	end
end
function control_x(x, panel)
	if not IS_ZERO then return x end
	local index=panel==LAYERS["perf"] and 0 or (panel==LAYERS["keybed"] and 1 or 2)
	return x-CONTROL_OFFSET+1+index*5
end
function control_y(y)
	return IS_ZERO and y-1 or y
end
function mark_control_dirty(x1,y1,x2,y2,panel)
	mark_region_dirty(control_x(x1,panel),control_y(y1),control_x(x2,panel),control_y(y2))
end
function sprite_key_id(x,y)
	if not IS_ZERO then return get_key_id(x,y) end
	return control_x(x,layer)*100+y
end
function apply_dirty_leds()
	if not refresh_pending then
		return
	end
	for x=1,MAX_X do
		for y=1,MAX_Y do
			if dirty[x][y] then
				local b=led_state[x][y]
				if sprite_a and y>KEYBED_Y_OFFSET and y<=KEYBED_Y_OFFSET+KEYBED_H and x<=KEYBED_W then
					local sprite=SPRITES[cur_sprite]
					if sprite then
						local sx=x-(IS_ZERO and 2 or 0)
						local sy=y-KEYBED_Y_OFFSET
						b=0
						if sx>=1 and sx<=12 then
							local bits=tonumber(string.sub(sprite,(sy-1)*3+1,sy*3),16)
							b=math.floor(bits / 2^(12-sx))%2*MAX_B
						end
					end
				end
				grid_led(x,y,b)
				dirty[x][y]=false
			end
		end
	end
	refresh_pending=false
	grid_refresh()
end
function mark_region_dirty(x1,y1,x2,y2)
	for x=x1,x2 do
		for y=y1,y2 do
			if x>=1 and x<=MAX_X and y>=1 and y<=MAX_Y then
				dirty[x][y]=true
				refresh_pending=true
			end
		end
	end
end
function get_key_id(x,y)
	return x*100+y
end
function get_note_name(root_i)
	if root_i<0 or root_i>12 then
		return "C"
	end
	return NOTE_NAMES[root_i]
end
function is_root_note(midi_note)
	return ((midi_note%12)+1)==root_note
end
function update_scale_degrees()
	scale_degrees={}
	for semitone=0,11 do
		if trans_cache[semitone+1]==1 then scale_degrees[#scale_degrees+1]=semitone end
	end
end
function calc_midi_note(x,y)
	local base_note=24+root_note-1+(global_transpose*12)
	if in_key_mode then
		local count=#scale_degrees
		local row_steps=keybed_row_off=="oct" and count or (keybed_row_off=="3rds" and 2 or 3)
		local degree=(8-y)*row_steps+(x-1)
		return base_note+math.floor(degree/count)*12+scale_degrees[degree%count+1]
	end
	local row_off=0
	if keybed_row_off=="oct" then
		row_off=(8-y)*12
	elseif keybed_row_off=="3rds" then
		row_off=(8-y)*4
	elseif keybed_row_off=="4ths" then
		row_off=(8-y)*5
	end
	return base_note+row_off+(x-1)
end
function is_note_in_scale(midi_note)
	return trans_cache[(midi_note%12)+1]==1
end
function render_keybed()
	for x=1,KEYBED_W do
		for y=1,KEYBED_H do
			update_keybed_key(x,y)
		end
	end
end
function update_keybed_key(x,y)
	if x<1 or x>KEYBED_W or y<1 or y>KEYBED_H then
		return
	end
	local pressed_note_classes={}
	for id,data in pairs(pressed_keys) do
		if data.sounding~=false then
			local note_class=data.note%12
			pressed_note_classes[note_class]=true
		end
	end
	local midi_note=calc_midi_note(x,y)
	if in_key_mode and (midi_note<0 or midi_note>127) then
		set_led(x,y+KEYBED_Y_OFFSET,0)
		return
	end
	local note_class=midi_note%12
	local b=0
	local pressed_key=pressed_keys[get_key_id(x,y)]
	if pressed_key then
		b=get_vi_from_v(pressed_key.vel)
	elseif pressed_note_classes[note_class] then
		b=clamp(get_vi_from_v(static_vel)-1,1,16)
	else
		if is_note_in_scale(midi_note-(root_note-1)) then
			b=NOTE_IN_SCALE_B
			if is_root_note(midi_note) then b=ACTIVE_B
			end
		end
	end
	set_led(x,y+KEYBED_Y_OFFSET,b)
end
function update_keybed_note_class(note_class)
	for x=1,KEYBED_W do
		for y=1,KEYBED_H do
			if calc_midi_note(x,y)%12==note_class then
				update_keybed_key(x,y)
			end
		end
	end
end
function handle_keybed_press(x,y,z)
	local id=get_key_id(x,y)
	if z==1 then
		local midi_note=calc_midi_note(x,y)
		local note_vel=static_vel
		if vel_mode == "rand" then
			note_vel=math.random(math.min(rand_vel_min,rand_vel_max),math.max(rand_vel_min,rand_vel_max))
		end
		if pressed_keys[id]~=nil and pressed_keys[id].sounding~=false then
			midi_note_off(pressed_keys[id].note,0,pressed_keys[id].channel)
		end
		local sounding=not in_key_mode or (midi_note>=0 and midi_note<=127)
		if sounding then midi_note_on(midi_note,note_vel,midi_ch) end
		pressed_keys[id]={x=x,y=y,note=midi_note,vel=note_vel,channel=midi_ch,sounding=sounding}
		update_keybed_key(x,y)
		update_keybed_note_class(midi_note%12)
	elseif pressed_keys[id] then
		if note_hold==false then
			local old_note=pressed_keys[id].note
			if pressed_keys[id].sounding~=false then
				midi_note_off(pressed_keys[id].note,0,pressed_keys[id].channel)
			end
			pressed_keys[id]=nil
			update_keybed_key(x,y)
			update_keybed_note_class(old_note%12)
		end
	end
	apply_dirty_leds()
end
function get_vel_i(x,y)
	local i=1
	if y==8 and x>=13 and x<=16 then i=x-12
	elseif y==7 and x>=13 and x<=16 then i=x-8
	elseif y==6 and x>=13 and x<=16 then i=x-4
	elseif y==5 and x>=13 and x<=16 then i=x end
	return i
end
function get_v_pos_from_i(i)
	local x,y=0,0
	if i>=1 and i<=4 then x,y=i+12,8
	elseif i<=8 then x,y=i-4+12,7
	elseif i<=12 then x,y=i-8+12,6
	elseif i<=16 then x,y=i-12+12,5 end
	return x,y
end
function get_v_from_vi(i)
	return round(linlin(i,1,16,10,127),1)
end
function get_vi_from_v(v)
	return clamp(round(linlin(v,10,127,1,16),1),0,16)
end
function render_selected_vel()
	if not IS_ZERO and layer~=LAYERS["perf"] then return end
	local b=get_time()%(VEL_METRO_RATE*2)<VEL_METRO_RATE and MAX_B or INACTIVE_B
	if vel_mode=="static" then
		local x,y=get_v_pos_from_i(get_vi_from_v(static_vel))
		grid_led(control_x(x,LAYERS["perf"]),control_y(y),b)
	else
		grid_led(control_x(14,LAYERS["perf"]),control_y(3),b)
		grid_led(control_x(14,LAYERS["perf"]),control_y(4),b)
	end
	local min_held,max_held=false,false
	for _,kind in pairs(velocity_select_held) do
		if kind=="min" then min_held=true else max_held=true end
	end
	if min_held or max_held then
		local phase=get_time()%2
		if phase>1 then phase=2-phase end
		local pulse=math.floor(INACTIVE_B+(MAX_B-INACTIVE_B)*phase+0.5)
		if min_held then
			grid_led(control_x(15,LAYERS["perf"]),control_y(3),pulse)
			grid_led(control_x(15,LAYERS["perf"]),control_y(4),pulse)
		end
		if max_held then
			grid_led(control_x(16,LAYERS["perf"]),control_y(3),pulse)
			grid_led(control_x(16,LAYERS["perf"]),control_y(4),pulse)
		end
	end
	grid_refresh()
end
function h_vel_select(x,y)
	local value=get_v_from_vi(get_vel_i(x,y))
	local active=velocity_select_order[#velocity_select_order]
	if active then
		if velocity_select_held[active]=="min" then rand_vel_min=value
		else rand_vel_max=value end
	elseif vel_mode=="static" then
		static_vel=value
	end
end
function handle_velocity_modifier(x,y,z,kind)
	local id=get_key_id(x,y)
	if z==1 and not velocity_select_held[id] then
		velocity_select_held[id]=kind
		table.insert(velocity_select_order,id)
	elseif z==0 and velocity_select_held[id] then
		velocity_select_held[id]=nil
		for i=#velocity_select_order,1,-1 do
			if velocity_select_order[i]==id then table.remove(velocity_select_order,i) end
		end
	end
end
function get_rn_from_pos(x,y)
	local i=0
	if y==5 then i=x-CONTROL_OFFSET
	elseif y==6 then i=x-8
	elseif y==7 then i=x-4 end
	return i
end
function retune_held_notes()
	if not in_key_mode then return end
	local changed={}
	for _,note in pairs(pressed_keys) do
		local new_note=calc_midi_note(note.x,note.y)
		local sounding=new_note>=0 and new_note<=127
		if new_note~=note.note or sounding~=(note.sounding~=false) then
			changed[#changed+1]={held=note,pitch=new_note,sounding=sounding}
			if note.sounding~=false then midi_note_off(note.note,0,note.channel) end
		end
	end
	for _,change in ipairs(changed) do
		change.held.note=change.pitch
		change.held.sounding=change.sounding
		if change.sounding then midi_note_on(change.pitch,change.held.vel,change.held.channel) end
	end
end
function handle_root_note_sel(x,y)
	root_note=get_rn_from_pos(x,y)
	retune_held_notes()
	cur_sprite=get_note_name(root_note)
end
function get_si_from_pos(x,y)
	local i=0
	if y==2 then i=x-CONTROL_OFFSET
	elseif y==3 then i=x-8
	elseif y==4 and x<=14 then i=x-4 end
	return i
end
function handle_scale_sel(x,y)
	cur_scale=SCALE_ORD[get_si_from_pos(x,y)]
	trans_cache={}
	trans_cache=SCALES[cur_scale]
	update_scale_degrees()
	retune_held_notes()
	cur_sprite=cur_scale
end
function render_keybed_off_sel(x,y)
	local button_index=x-CONTROL_OFFSET
	if KEYBED_OFFSET_MODES[button_index]==keybed_row_off then
		if sprite_a then
			grid_led(x,y,clamp(KEYBED_OFFSET_ACTIVE_B+2,0,15))
		else
			grid_led(x,y,KEYBED_OFFSET_ACTIVE_B)
		end
	else
		grid_led(x,y,INACTIVE_B)
	end
end
function handle_keybed_off_sel(x,y)
	local offset_mode=KEYBED_OFFSET_MODES[x-CONTROL_OFFSET]
	keybed_row_off=offset_mode
	cur_sprite=offset_mode
end
function handle_in_key_sel(x,y)
	in_key_mode=not in_key_mode
	cur_sprite=in_key_mode and "in_key" or "chromatic"
end
function handle_note_hold_mode_press(x,y,z,zone)
	if zone==7 and z==1 then
		note_hold_damper=not note_hold_damper
		if not note_hold_damper then note_hold=false end
	else
		if note_hold_damper then
			if zone ~=7 and z==1 then note_hold=false end
		else
			if zone==5 and z==1 then note_hold=not note_hold
			elseif zone==6 then note_hold=z==1 and true or false
			end
		end
	end

	if not note_hold then
		for k,v in pairs(pressed_keys) do
			if v.sounding~=false then midi_note_off(v.note,0,v.channel) end
			pressed_keys[k]=nil
		end
		update_keybed_leds()
	end

	if note_hold_damper and z==1 then note_hold=true end
end
function handle_trans_sel(x,y)
	if y==4 then global_transpose=clamp(global_transpose-1,-2,2)
	elseif y==2 then global_transpose=clamp(global_transpose+1,-2,2)
	else global_transpose=0 end
end
function update_layer_zone(zone_id)
	for x=13,16 do
		for y=2,8 do
			local current_zone=layer[y-1][x-CONTROL_OFFSET]
			if current_zone==zone_id then
				local b=0
				if layer==LAYERS["perf"] then b=get_performance_layer_b(x,y,current_zone)
				elseif layer==LAYERS["keybed"] then b=get_keybed_layer_b(x,y,current_zone)
				elseif layer==LAYERS["midi"] then b=get_midi_layer_b(x,y,current_zone) end
				set_led(control_x(x,layer),control_y(y),b)
			end
		end
	end
end
function get_performance_layer_b(x,y,zone)
	if zone==1 then
		if y==4 and global_transpose<=-1 then
			return ACTIVE_B
		elseif y==2 and global_transpose>=1 then
			return ACTIVE_B
		elseif y==3 and (global_transpose==0 or global_transpose==1 or global_transpose==-1) then
			return ACTIVE_B
		else
			return INACTIVE_B
		end
	elseif zone==2 then
		local velocity_index=get_vel_i(x,y)
		if vel_mode=="static" and get_vi_from_v(static_vel)==velocity_index then
			return INACTIVE_B
		end
		return velocity_index-1
	elseif zone==3 then
		return get_vi_from_v(rand_vel_max)-1
	elseif zone==4 then
		return get_vi_from_v(rand_vel_min)-1
	elseif zone==8 then
		return vel_mode=="rand" and MAX_B or 8
	elseif zone>=5 and zone<=6 then
		if not note_hold_damper then
			if note_hold==true then
				return MAX_B
			else
				return 3
			end
		else
			if note_hold==true then
				return MAX_B
			else
				return 3
			end
		end
	elseif zone==7 then
		if note_hold_damper then return MAX_B end
		return 4
	end
	return 0
end
function get_keybed_layer_b(x,y,zone)
	if zone==1 then
		local root_note_i=get_rn_from_pos(x,y)
		if root_note_i==root_note then
			return MAX_B
		else
			return 1
		end
	elseif zone==2 then
		local i=x-CONTROL_OFFSET
		if KEYBED_OFFSET_MODES[i]==keybed_row_off then
			if sprite_a then
				return clamp(KEYBED_OFFSET_ACTIVE_B+2,0,15)
			else
				return KEYBED_OFFSET_ACTIVE_B
			end
		else
			return INACTIVE_B
		end
	elseif zone==3 then
		if cur_scale==SCALE_ORD[get_si_from_pos(x,y)] then
			return MAX_B
		else
			return 1
		end
	elseif zone==4 then
		if in_key_mode then return MAX_B end
		return 4
	end
	return 0
end
function get_midi_layer_b(x,y,z)
	if z==1 then
		if midi_ch==get_midi_ch_from_pos(x,y) then
			return MAX_B
		else
			return 2
		end
	elseif z==2 then
		if midi_pnc_hld then
			return MAX_B
		else
			return 7
		end
	end
	return 0
end
function handle_perf_layer_press(x,y,z,zone)
	if zone>=5 and zone<=7 then
		handle_note_hold_mode_press(x,y,z,zone)
		update_layer_zone(5)
		update_layer_zone(6)
		update_layer_zone(7)
		apply_dirty_leds()
	elseif z==1 then
		if zone==1 then
			handle_trans_sel(x,y)
			update_layer_zone(1)
		elseif zone==2 then
			h_vel_select(x,y)
			update_layer_zone(2)
			update_layer_zone(3)
			update_layer_zone(4)
		elseif zone==8 then
			vel_mode=vel_mode=="static" and "rand" or "static"
			update_layer_zone(2)
			update_layer_zone(8)
			mark_control_dirty(14,3,14,4,layer)
		end
		if zone==2 or zone==8 then mark_control_dirty(13,5,16,8,layer) end
		apply_dirty_leds()
		if zone==2 and #velocity_select_order>0 then render_selected_vel() end
	end
	if zone==3 or zone==4 then
		handle_velocity_modifier(x,y,z,zone==4 and "min" or "max")
		update_layer_zone(zone)
		mark_control_dirty(x,3,x,4,layer)
		apply_dirty_leds()
		if #velocity_select_order>0 then render_selected_vel() end
	end
end
function handle_keybed_layer_press(x,y,z,zone)
	if z==1 then
		sprite_a=true
		sprite_owner=sprite_key_id(x,y)
		if zone==1 then
			handle_root_note_sel(x,y)
			update_layer_zone(1)
			render_keybed()
		elseif zone==2 then
			handle_keybed_off_sel(x,y)
			update_layer_zone(2)
			render_keybed()
		elseif zone==3 then
			handle_scale_sel(x,y)
			update_layer_zone(3)
			render_keybed()
		elseif zone==4 then
			handle_in_key_sel(x,y)
			update_layer_zone(4)
			render_keybed()
		end
	elseif sprite_owner==sprite_key_id(x,y) then
		sprite_a=false
		sprite_owner=nil
	end
	mark_region_dirty(1,1+KEYBED_Y_OFFSET,KEYBED_W,KEYBED_H+KEYBED_Y_OFFSET)
	apply_dirty_leds()
end
function get_midi_ch_from_pos(x,y)
	local channel=((y-5)*4)+(x-CONTROL_OFFSET)
	return channel
end
function handle_midi_panic_press(x,y)
	for channel=1,16 do
		midi_cc(123,127,channel)
	end
end
function handle_midi_layer_press(x,y,z,zone)
	if zone==1 then
		if z==1 then
			midi_ch=get_midi_ch_from_pos(x,y)
			cur_sprite=tostring(midi_ch)
			sprite_a=true
			sprite_owner=sprite_key_id(x,y)
			update_layer_zone(1)
		elseif sprite_owner==sprite_key_id(x,y) then
			sprite_a=false
			sprite_owner=nil
		end
	elseif zone==2 then
		if z==1 then
			midi_pnc_hld=true
			handle_midi_panic_press(x,y)
			cur_sprite="panic"
			sprite_a=true
			sprite_owner=sprite_key_id(x,y)
			update_layer_zone(2)
		else midi_pnc_hld=false
			if sprite_owner==sprite_key_id(x,y) then
				sprite_a=false
				sprite_owner=nil
			end
			update_layer_zone(2)
		end
	end
	mark_region_dirty(1,1+KEYBED_Y_OFFSET,KEYBED_W,KEYBED_H+KEYBED_Y_OFFSET)
	apply_dirty_leds()
end
function get_layer_index(x,y)
	if y==1 then
		return x-CONTROL_OFFSET
	end
end
function render_layer_select(x,y)
	local z=ZONES[y][x]

	if z==2 then
		local layer_index=get_layer_index(x,y)
		if LAYERS[LAYER_ORD[layer_index]]==layer then
			set_led(x,y,MAX_B)
		else
			set_led(x,y,INACTIVE_B)
		end
	end
end
function handle_layer_press(x,y,z)
	local y_1=y-1
	local x_1=x-CONTROL_OFFSET
	if y_1>=1 and y_1<=#layer and
	x_1>=1 and x_1<=#layer[y_1] then
		local zone=layer[y_1][x_1]
		if zone==0 then return end
		if layer==LAYERS["perf"] then handle_perf_layer_press(x,y,z,zone)
		elseif layer==LAYERS["keybed"] then handle_keybed_layer_press(x,y,z,zone)
		elseif layer==LAYERS["midi"] then handle_midi_layer_press(x,y,z,zone)
		else
		end
	end
end
function handle_layer_select_press(x,y,z)
	if z==1 then
		local layer_index=get_layer_index(x,y)
		if layer_index>#LAYER_ORD then
			return
		end
		velocity_select_held={}
		velocity_select_order={}
		if sprite_a then
			sprite_a=false
			sprite_owner=nil
			mark_region_dirty(1,1+KEYBED_Y_OFFSET,KEYBED_W,KEYBED_H+KEYBED_Y_OFFSET)
		end
		layer=LAYERS[LAYER_ORD[layer_index]]
		if LAYER_ORD[layer_index]=="perf" then
			if static_vel_metro_id~=nil then
				static_vel_metro_id:stop()
			end
			static_vel_metro_id:start()
		elseif LAYER_ORD[layer_index]=="keybed" then
		end
		if LAYER_ORD[layer_index]~="perf" then
			if static_vel_metro_id~=nil then
				static_vel_metro_id:stop()
			end
		end
		update_all_layer_zones()
		apply_dirty_leds()
	end
end
function event_grid(x,y,z)
	if IS_ZERO then
		if y>8 then
			handle_keybed_press(x,y-8,z)
		elseif y<=7 and x>=2 and x<=15 then
			local panel=math.floor((x-2)/5)+1
			local column=(x-2)%5
			if panel<=3 and column<4 then
				local previous=layer
				layer=LAYERS[LAYER_ORD[panel]]
				handle_layer_press(column+13,y+1,z)
				layer=previous
			end
		end
		return
	end
	local zone=ZONES[y][x]
	if zone==0 then handle_keybed_press(x,y,z)
	elseif zone==1 then handle_layer_press(x,y,z)
	elseif zone==2 then handle_layer_select_press(x,y,z)
	end
end
function update_keybed_leds()
	render_keybed()
	apply_dirty_leds()
end
function update_all_layer_zones()
	if IS_ZERO then
		local previous=layer
		for _,name in ipairs(LAYER_ORD) do
			layer=LAYERS[name]
			for i=0,MAX_LAYER_ZONES do update_layer_zone(i) end
		end
		layer=previous
		mark_region_dirty(1,1,16,8)
	else
		for x=CONTROL_OFFSET+1,MAX_X do render_layer_select(x,1) end
		for i=0,MAX_LAYER_ZONES do update_layer_zone(i) end
		mark_region_dirty(CONTROL_OFFSET+1,1,MAX_X,MAX_Y)
	end
	apply_dirty_leds()
end
-- Init
for x=1,MAX_X do
	led_state[x]={}
	dirty[x]={}
	for y=1,MAX_Y do
		led_state[x][y]=0
		dirty[x][y]=false
	end
end
trans_cache=SCALES[cur_scale]
update_scale_degrees()
static_vel_metro_id=metro.init(render_selected_vel,VEL_METRO_RATE)
static_vel_metro_id:start()
grid_led_all(0)
update_keybed_leds()
update_all_layer_zones()
grid_refresh()