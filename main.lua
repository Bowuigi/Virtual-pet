--Penguin Virtual pet
--Copyright (c) Bowuigi 2020
--GNU GPL v3 License

--Graphics credit:
--Z letter made by TheKingPhoenix on OpenGameArt and modified by me
--All the rest made and modified by me and my sister

--How to Modify the pet:
--Appearance:
--Change the sprites, but dont rename them
--Functions (requires begginer Lua/Love2D knowledge):
--Add states via pet.states table
--Add actions to new states (or to old ones) via the conditional in love.update() and via functions (to make code readable)

function love.load()
	--graphics
	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )
	graphics={1,love.graphics.newImage("pet-0.png"),love.graphics.newImage("pet-1.png"),love.graphics.newImage("water-drop.png"),love.graphics.newImage("Z.png")}
	--keybindings
	btn={0,1,2}
	--window dimensions
	width,height=love.graphics.getDimensions()
	--pet table, has all the information about the pet
	pet={
		states={"moving","sitting","sleeping","being_grabbed"},
		x=0,
		y=0,
		walk_speed=0.3,
		sleeptimer=0,
		movetimer=0,
		Xoffset=0,
	}
	--grab particle system settings
	grabparticle=love.graphics.newParticleSystem(graphics[4],20)
	grabparticle:setParticleLifetime(0.5,2.5)
	grabparticle:setSizeVariation(0.3)
	grabparticle:setSpeed(-96,94)
	grabparticle:setSpread(6.5)
	grabparticle:setLinearAcceleration(0, 98, 0, 98)
	grabparticle:setRelativeRotation(true)
	grabparticle:setColors(0.64, 1, 1, 1, 1, 1, 1, 0)
	grabparticle:setSizes(5,0.5)
	--sleeping particles settings
	sleepparticle=love.graphics.newParticleSystem(graphics[5],10)
	sleepparticle:setParticleLifetime(2,2)
	sleepparticle:setSizes(4,2.25)
	sleepparticle:setSpeed(50,50)
	sleepparticle:setDirection(5.5)
	sleepparticle:setColors(1,1,1,1,1,1,1,0)
	sleepparticle:setEmissionRate(1)
	--point handling variables
	current_state=pet.states[1]
	pointX,pointY=30,30
	distanceX,distanceY=pet.x-pointX,pet.y-pointY
	set_point()
	--Mouse handling
	mouseX,mouseY= love.mouse.getPosition()
	love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
end

function love.update(dt)
	--Get mouse coordinates
	mouseX,mouseY= love.mouse.getPosition()
	--Update timer
	pet.sleeptimer=pet.sleeptimer+dt
	--Update and move all particles
	grabparticle:moveTo(pet.x,pet.y)
	sleepparticle:moveTo(pet.x+50,pet.y-50)
	grabparticle:update(dt)
	sleepparticle:update(dt)

	if love.mouse.isDown(btn) then
		--Awake the pet on click
		pet.sleeptimer=0
		--Check if the user is hovering the pet
		if checkCircularCollision(mouseX,mouseY,20,pet.x,pet.y,30) or current_state=="being_grabbed" then current_state=pet.states[4] else current_state=pet.states[1] end
	elseif current_state=="being_grabbed" then
		current_state=pet.states[1]
	end

	--Simple State Machine
	if current_state=="moving" then
		--Change the pet sprite
		graphics[1]=1
		--Disable all particles
		grabparticle:setEmissionRate(0)
		sleepparticle:setEmissionRate(0)
		--Use timers to change states
		pet.movetimer=pet.movetimer+dt
		if pet.movetimer>3 then if pet.movetimer>5 then set_point() pet.movetimer=0 end else move_to_point(dt) end
		if pet.sleeptimer>10 then current_state=pet.states[2] end
	elseif current_state=="sitting" then
		--Same as previous state but without moving
		graphics[1]=1
		grabparticle:setEmissionRate(0)
		sleepparticle:setEmissionRate(0)
		--Make the pet sleep when 30 seconds have passed
		if pet.sleeptimer>30 then current_state=pet.states[3] end
	elseif current_state=="sleeping" then
		graphics[1]=2
		sleepparticle:setEmissionRate(1)
		grabparticle:setEmissionRate(0)
	elseif current_state=="being_grabbed" then
		graphics[1]=2
		pet.Xoffset=math.random(-1,1)
		pet.x=mouseX-pet.Xoffset
		pet.y=mouseY
		sleepparticle:setEmissionRate(0)
		grabparticle:setEmissionRate(3)
	end
	
end

--Draw the pet and the particles
function love.draw()
	love.graphics.setBackgroundColor(0.6,0.7,0.8)
	love.graphics.draw(graphics[graphics[1]+1],pet.x,pet.y,0,flipX*5,5,6,7)
	love.graphics.draw(grabparticle,0,0)
	love.graphics.draw(sleepparticle,0,0)
end

--Assign the location used later
function set_point()
	pointX,pointY=math.random(0,width),math.random(0,height)
	distanceX,distanceY=pet.x-pointX,pet.y-pointY
end

--Function used to make the pet move to a previously assigned location
function move_to_point(dt)
	pet.x=pet.x-(distanceX*pet.walk_speed)*dt
	pet.y=pet.y-(distanceY*pet.walk_speed)*dt
	distanceX,distanceY=pet.x-pointX,pet.y-pointY
	flipX=get_sign(distanceX)
end

--Update the width and height variables when the user resizes the window
function love.resize(w,h)
	width=w
	height=h
end

--Utility functions
function checkCircularCollision(ax,ay,ar,bx,by,br)
	local dx = bx - ax
	local dy = by - ay
	return dx^2 + dy^2 < (ar + br)^2
end

function get_sign(number)
	if number<=-1 then return -1
	elseif number>=1 then return 1
	else return 0 end
end
