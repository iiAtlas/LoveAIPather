local map = {}, tileSize
local tileSizes = {}
local tileSizeIndex = 1
local done
local px, py
local speeds, speedIndex
local shouldDrawMap, shouldDrawWalked
local pather1, pather2
local shouldShowMap, dPresses

function love.load()
	tileSizes = { 10, 15, 20, 5 }
	tileSize = tileSizes[tileSizeIndex]

	done = false
	shouldShowMap = false
	dPresses = 1

	speeds = { 0, 0.05, 0.25, 0.5, 1 }
	speedIndex = 1

	pather1 = AIPather.create(5, 5)
	pather1.color = { 255, 0, 0 }

	pather2 = AIPather.create(5, 25)
	pather2.color = { 0, 255, 0 }

	shouldDrawMap = true
	shouldDrawWalked = false

	genMap()
end

-- Generates a random map
function genMap()
	for y = 0, love.graphics.getHeight(), tileSize do
		local xTiles = {}
		for x = 0, love.graphics.getWidth(), tileSize do
			if y == 0 or x == 0 or y == love.graphics.getHeight() - tileSize then xTiles[x] = 1
			else
				local choices = {0, 0, 1}
				xTiles[x] = choices[math.random(1, #choices)]
			end
		end
		map[y] = xTiles
	end
end

function isTileEmpty(x, y)
	if map[y * tileSize][x * tileSize] ~= 1 then return true
	else return false end
end

-- Returns the computed "score" of a tile from 0 (good) to 10 (bad)
function getTileScore(pather, x, y)
	local score = 0
	if map[y * tileSize][x * tileSize] == 1 then return 10 end
	score = score + pather.walkedMap[y * tileSize][x * tileSize]
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
	return index
end

function love.update(dt)
	if not done then
		pather1:update()
		pather2:update()

		love.timer.sleep(speeds[speedIndex])
	end
end

function love.draw()
	if done then
		drawPaths(false)
		pather1:draw()
		pather2:draw()
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
			drawPaths(shouldShowMap)
		end
	end

	-- Draw Player
	pather1:draw()
	pather2:draw()

	-- Draw Stats
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth() - 100, 0, 100, 38)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", love.graphics.getWidth() - 100, 0, 100, 38)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Speed: "..2 - speeds[speedIndex], love.graphics.getWidth() - 95, 5)
	love.graphics.print("Steps: "..pather1.steps, love.graphics.getWidth() - 95, 20)
end

-- Combine player paths into one table and draw them (optionally with the map overlayed)
function drawPaths(withMap)
	local combinedPaths = {}
	for y = 0, love.graphics.getHeight(), tileSize do
		local xTiles = {}
		for x = 0, love.graphics.getWidth(), tileSize do
			xTiles[x] = pather1.walkedMap[y][x] + pather2.walkedMap[y][x] + (withMap and map[y][x] * 10 or 0)
		end
		combinedPaths[y] = xTiles
	end

	for y = 0, love.graphics.getHeight(), tileSize do
		for x = 0, love.graphics.getWidth(), tileSize do
			
			local val = combinedPaths[y][x]
			if val == 0 then love.graphics.setColor(0, 0, 0)
			elseif val == 1 then love.graphics.setColor(0, 255, 0)
			elseif val == 2 then love.graphics.setColor(0, 0, 255)
			elseif val == 3 then love.graphics.setColor(255, 0, 0)
			elseif val == 4 then love.graphics.setColor(255, 0, 255)
			elseif val == 5 then love.graphics.setColor(0, 255, 255)
			elseif val == 10 then love.graphics.setColor(255, 255, 255)
			else love.graphics.setColor(255, 255, 0)
			end

			love.graphics.rectangle("fill", x, y, tileSize, tileSize)
		end
	end
end

function love.keypressed(key)
	if key == "r" then love.load() end
	if key == "s" then
		if speedIndex < #speeds then speedIndex = speedIndex + 1
		else speedIndex = 1 end
	end
	if key == "d" then
		if dPresses < 3 then dPresses = dPresses + 1 else dPresses = 1 end
		if dPresses == 1 then
			shouldDrawMap = true
			shouldShowMap = false
			shouldDrawWalked = false
		elseif dPresses == 2 then
			shouldDrawMap = false
			shouldShowMap = false
			shouldDrawWalked = true
		elseif dPresses == 3 then
			shouldDrawMap = false
			shouldShowMap = true
			shouldDrawWalked = true
		end
	end
	if key == "t" then
		if tileSizeIndex < #tileSizes then tileSizeIndex = tileSizeIndex + 1
		else tileSizeIndex = 1 end
		love.load()
	end
end

-- AI Pather
AIPather = {}
AIPather.__index = AIPather

function AIPather.create(px, py)
	local walked = {}
	for iy = 0, love.graphics.getHeight(), tileSize do
		local xTiles = {}
		for ix = 0, love.graphics.getWidth(), tileSize do
			xTiles[ix] = 0
		end
		walked[iy] = xTiles
	end

	return setmetatable({
		x = px or 10,
		y = py or 10,
		color = { 255, 255, 255 },
		walkedMap = walked,
		steps = 0
	}, AIPather)
end

function AIPather:update()
	if self.x * tileSize >= (love.graphics.getWidth() - tileSize) or self.y * tileSize >= (love.graphics.getHeight() - tileSize) or self.x * tileSize < tileSize or self.y * tileSize < tileSize then
		done = true
		return
	end

	local npx = self.x
	local npy = self.y

	local options = {} -- R, B, L, T
	options[1] = getTileScore(self, self.x + 1, self.y)
	options[2] = getTileScore(self, self.x, self.y + 1)
	options[3] = getTileScore(self, self.x - 1, self.y)
	options[4] = getTileScore(self, self.x, self.y - 1)
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
	if best == 1 then npx = self.x + 1
	elseif best == 2 then npy = self.y + 1
	elseif best == 3 then npx = self.x - 1
	elseif best == 4 then npy = self.y - 1
	end

	if isTileEmpty(npx, npy) then
		self.x = npx
		self.y = npy

		self.walkedMap[self.y * tileSize][self.x * tileSize] = self.walkedMap[self.y * tileSize][self.x * tileSize] + 1
		self.steps = self.steps + 1
	end
end

function AIPather:draw()
	love.graphics.setColor(self.color[1], self.color[2], self.color[3])
	love.graphics.rectangle("line", self.x * tileSize, self.y * tileSize, tileSize, tileSize)
end