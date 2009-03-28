-------------------------------------------------------------------------
-- Rockwell, Papyrus, Skia
-- Copyright 2009 Matthew Gallant
-- http://gangles.ca/
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License (COPYING) for more details.
-------------------------------------------------------------------------

function load()
	fonts = {"Courier", "Futura", "Helvetica", "Lucida", "Palatino", "Times", "Verdana"}
	
	rock_font = {}
	paper_font = {}
	scissors_font = {}
	fox_font = {}
	name_font = {}
	
	for i=1,#fonts do
		rock_font[i] = love.graphics.newImage( "gfx/"..fonts[i].."/rock.png" )
		paper_font[i] = love.graphics.newImage( "gfx/"..fonts[i].."/paper.png" )
		scissors_font[i] = love.graphics.newImage( "gfx/"..fonts[i].."/scissors.png" )
		fox_font[i] = love.graphics.newImage( "gfx/"..fonts[i].."/fox.png" )
		name_font[i] = love.graphics.newImage( "gfx/"..fonts[i].."/name.png" )
	end
	
	title = love.graphics.newImage( "gfx/rps.png" )
	instructions = love.graphics.newImage( "gfx/instructions.png" )
	font_background = love.graphics.newImage( "gfx/background.png" )
	
	result_graphic = {}
	result_graphic[1] = love.graphics.newImage( "gfx/wrong.png" )
	result_graphic[2] = love.graphics.newImage( "gfx/right.png" )
	
	sound_type = love.audio.newSound( "audio/Typewriter.wav" )
	sound_return = love.audio.newSound( "audio/Typewriter_Return.ogg" )
	sound_yank = love.audio.newSound( "audio/Typewriter_Yank.wav" )
	
	game_state = 0
	game_score = 0
	game_result = 1
	
	r_font = 1
	p_font = 2
	s_font = 3
	font_selection = {1,2,3}
	
	-- Wait times for sound effects
	type1_accumulator = -0.7
	type2_accumulator = -0.7
	type3_accumulator = -0.7
	wait_accumulator = 1.2
	
	-- The positions of graphic elements
	button_x = 300
	button_top_y = 150
	button_bot_y = 350
	button_h = 90
	button_w = 390
	rps_y = 250
	rock_x = 150
	paper_x = 280
	scissors_x = 430
	
	-- The x/y limits of the two buttons
	low_x = button_x - 0.5 * button_w
	hig_x = button_x + 0.5 * button_w
	top_low_y = button_top_y - 0.5 * button_h
	top_hig_y = button_top_y + 0.5 * button_h
	bot_low_y = button_bot_y - 0.5 * button_h
	bot_hig_y = button_bot_y + 0.5 * button_h
	
	love.graphics.setBackgroundColor( 255, 255, 255 ) 
	love.graphics.setFont(love.graphics.newFont(love.default_font, 20))
end

function update( dt )
	if game_state == 1 then
		type1_accumulator = type1_accumulator + dt
		type2_accumulator = type2_accumulator + dt
		type3_accumulator = type3_accumulator + dt
	
		if type1_accumulator > 1 then
			love.audio.play( sound_type )
			type1_accumulator = 0
		end
		if type2_accumulator > 1.4 then
			love.audio.play( sound_type )
			type2_accumulator = 0
		end
		if type3_accumulator > 3.3 then
			love.audio.play( sound_type )
			type3_accumulator = 0
		end
	elseif (game_state == 0 or game_state == 2) and wait_accumulator > 0 then
		wait_accumulator = wait_accumulator - dt
	end
end

function mousepressed(x, y, button)
	-- Ignore right and center clicks
	if button ~= love.mouse_left then
		return
	end
	
	if game_state == 0 then
		if wait_accumulator <= 0 then
			love.audio.play( sound_return )
			new_throw()
		end
		
	elseif game_state == 1 then	
		-- See if the mouse press is inside a button
		if x > low_x and x < hig_x then
			if y > top_low_y and y < top_hig_y then
				select_button(1, 2)
			elseif y > bot_low_y and y < bot_hig_y then
				select_button(2, 1)
			end
		end
		
	elseif game_state == 2 then
		if wait_accumulator <= 0 then
			new_throw()
		end
	end
end

function select_button(choice, other)
	if font_selection[choice] == r_font then
		if font_selection[other] == p_font then
			end_throw(1)
		else
			end_throw(2)
		end
	elseif font_selection[choice] == p_font then
		if font_selection[other] == s_font then
			end_throw(1)
		else
			end_throw(2)
		end
	elseif font_selection[choice] == s_font then
		if font_selection[other] == r_font then
			end_throw(1)
		else
			end_throw(2)
		end
	end
end
	
function end_throw(result)
	love.audio.stop()
	game_state = 2
	game_result = result
	wait_accumulator = 1.1
	
	if result == 2 then
		love.audio.play( sound_return )
		game_score = game_score + 1
	else
		love.audio.play( sound_yank )
		game_score = 0
	end
end


function new_throw()
	game_state = 1
	
	-- Initialize values to an indicator value
	r_font = -1
	p_font = -1
	s_font = -1
	
	-- A silly way to get decent randomness
	math.randomseed( os.time() )
	for i = 1, math.random(10) do
    	math.random()
	end
	
	-- The Rock font is always initially unique
	r_font = math.random(1,#fonts)
	
	-- Iterate until Paper font is unique
	repeat
		p_font = math.random(1,#fonts)
	until (p_font ~= r_font)
	
	-- Iterate until Scissors font is unique
	repeat
		s_font = math.random(1,#fonts)
	until (s_font ~= p_font) and (s_font ~= r_font)
	
	-- Choose random fonts from the three
	font_selection = {p_font, r_font, s_font}
	shuffle(font_selection)
end

function draw()
	love.graphics.draw(title, 350, 100)
	
	if game_state == 0 then
		love.graphics.draw(instructions, 300, 300)
		
	elseif game_state == 1 then
		love.graphics.draw(font_background, button_x, button_top_y)
		love.graphics.draw(fox_font[font_selection[1]], button_x, button_top_y)
		draw_rps()
		love.graphics.draw(font_background, button_x, button_bot_y)
		love.graphics.draw(fox_font[font_selection[2]], button_x, button_bot_y)
		
	elseif game_state == 2 then
		love.graphics.draw(name_font[font_selection[1]], button_x, button_top_y)
		draw_rps()
		love.graphics.draw(name_font[font_selection[2]], button_x, button_bot_y)
		
		if font_selection[1] == r_font then
			draw_line( rock_x, button_top_y, 1 )
		elseif font_selection[1] == p_font then
			draw_line( paper_x, button_top_y, 1 )
		else
			draw_line( scissors_x, button_top_y, 1 )
		end
		
		if font_selection[2] == r_font then
			draw_line( rock_x, button_bot_y, -1 )
		elseif font_selection[2] == p_font then
			draw_line( paper_x, button_bot_y, -1 )
		else
			draw_line( scissors_x, button_bot_y, -1 )
		end
		
		love.graphics.draw(result_graphic[game_result], button_x, 470)
		love.graphics.draw("Streak: "..game_score, 460, 495)
	end
end

function draw_rps()
	love.graphics.draw(rock_font[r_font], rock_x, rps_y)
	love.graphics.draw(paper_font[p_font], paper_x, rps_y)
	love.graphics.draw(scissors_font[s_font], scissors_x, rps_y)
end

function draw_line( x, y, dir )
	love.graphics.setLineWidth( 5 )
	love.graphics.setColor( 0,0,0 )
	love.graphics.setLineStipple( 52428 ) -- Dotted line
	love.graphics.line( x, rps_y - dir * 20, x, y + dir * 20 )
end

function shuffle(table)
	for i=1,#table do
		j = math.random(1,#table)
		temp = table[j]
		table[j] = table[i]
		table[i] = temp
	end
end