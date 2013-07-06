local map = {}, tileSize
local walkedMap = {}, steps
local done
local px, py
local speeds, speedIndex
local shouldDrawMap, shouldDrawWalked

function love.load()
	tileSize = 10
	steps = 0
	done = false

	px = 5
	py = 5

	speeds = { 0, 0.05, 0.25, 0.5, 1 }
	speedIndex = 1

	shouldDrawMap = true
	shouldDrawWalked = false

	genMap()
end

-- Clears and fills map
function clearMap()
	for y = 0, love.graphics.getHeight(), tileSize do
		local xTiles = {}
		for x = 0, love.graphics.getWidth(), tileSize do
			xTiles[x] = 0
		end
		map[y] = xTiles
		walkTiles[y] = xTiles
	end
end

-- Generates a random map
function genMap()
	for y = 0, love.graphics.getHeight(), tileSize do
		local xTiles = {}
		local walkTiles = {}
		for x = 0, love.graphics.getWidth(), tileSize do
			local choices = {0, 0, 1}
			xTiles[x] = choices[math.random(1, #choices)]
			walkTiles[x] = 0
		end
		map[y] = xTiles
		walkedMap[y] = walkTiles
	end
end

function isTileEmpty(x, y)
	if map[y * tileSize][x * tileSize] ~= 1 then return true
	else return false end
end

function getTileScore(x, y)
	local score = 0
	if map[y * tileSize][x * tileSize] == 1 then return 10 end
	score = score + walkedMap[y * tileSize][x * tileSize]
	return score
end

-- Chooses the best possible tile from a table of options, returns the index
function chooseBestTile(options)
	local lowest = 10, index
	for i = 1, #options do
		if options[i] < lowest then
			lowest = options[i]
			index = i
		end
	end
	for i = 1, #options do print("t "..options[i]) end
	return index
end

function love.update(dt)
	if(not done) then
		if px * tileSize >= (love.graphics.getWidth() - tileSize) or py * tileSize >= (love.graphics.getHeight() - tileSize) or px * tileSize < tileSize or py * tileSize <= tileSize then
			done = true
			return
		end

		local npx = px
		local npy = py

		local options = {} -- R, B, L, T
		options[1] = getTileScore(px + 1, py)
		options[2] = getTileScore(px, py + 1)
		options[3] = getTileScore(px - 1, py)
		options[4] = getTileScore(px, py - 1)
		for i = 1, #options do print(options[i]) end
		
		local allFull = true
		for i = 1, #options do
			if options[i] ~= 10 then
				allFull = false
				break
			end
		end
		if allFull then
			done = true
			return
		end

		local best = chooseBestTile(options)
		if best == 1 then npx = px + 1
		elseif best == 2 then npy = py + 1
		elseif best == 3 then npx = px - 1
		elseif best == 4 then npy = py - 1
		end

		if isTileEmpty(npx, npy) then
			px = npx
			py = npy

			walkedMap[py * tileSize][px * tileSize] = walkedMap[py * tileSize][px * tileSize] + 1
			steps = steps + 1
		end

		love.timer.sleep(speeds[speedIndex])
	end
end

function love.draw()
	if done then
		for y = 0, love.graphics.getHeight(), tileSize do
			for x = 0, love.graphics.getWidth(), tileSize do
				love.graphics.setColor(255, 255, 255)
				love.graphics.rectangle("line", x, y, tileSize, tileSize)
				
				local val = walkedMap[y][x]
				if val == 0 then love.graphics.setColor(0, 0, 0)
				elseif val == 1 then love.graphics.setColor(0, 255, 0)
				elseif val == 2 then love.graphics.setColor(0, 0, 255)
				elseif val == 3 then love.graphics.setColor(255, 0, 0)
				else love.graphics.setColor(255, 255, 255)
				end
				love.graphics.rectangle("fill", x, y, tileSize, tileSize)
			end
		end
	else
		-- Draw Map
		if shouldDrawMap then
			for y = 0, love.graphics.getHeight(), tileSize do
				for x = 0, love.graphics.getWidth(), tileSize do
					local val = map[y][x]
					if val == 0 then love.graphics.setColor(0, 0, 0)
					elseif val == 1 then love.graphics.setColor(255, 255, 255)
					else love.graphics.setColor(0, 0, 0)
					end

					love.graphics.rectangle("fill", x, y, tileSize, tileSize)
				end
			end
		elseif shouldDrawWalked then
			for y = 0, love.graphics.getHeight(), tileSize do
				for x = 0, love.graphics.getWidth(), tileSize do
					love.graphics.setColor(255, 255, 255)
					love.graphics.rectangle("line", x, y, tileSize, tileSize)
					
					local val = walkedMap[y][x]
					if val == 0 then love.graphics.setColor(0, 0, 0)
					elseif val == 1 then love.graphics.setColor(0, 255, 0)
					elseif val == 2 then love.graphics.setColor(0, 0, 255)
					elseif val == 3 then love.graphics.setColor(255, 0, 0)
					else love.graphics.setColor(255, 255, 255)
					end
					love.graphics.rectangle("fill", x, y, tileSize, tileSize)
				end
			end
		end
	end

	-- Draw Player
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("line", px * tileSize, py * tileSize, tileSize, tileSize)

	-- Draw Stats
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth() - 100, 0, 100, 40)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", love.graphics.getWidth() - 100, 0, 100, 40)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Speed: "..2 - speeds[speedIndex], love.graphics.getWidth() - 95, 5)
	love.graphics.print("Steps: "..steps, love.graphics.getWidth() - 95, 20)
end

function love.keypressed(key)
	if key == "r" then love.load() end
	if key == "s" then
		if speedIndex < #speeds then speedIndex = speedIndex + 1
		else speedIndex = 1 end
	end
	if key == "d" then
		shouldDrawMap = not shouldDrawMap
		shouldDrawWalked = not shouldDrawWalked
	end
end