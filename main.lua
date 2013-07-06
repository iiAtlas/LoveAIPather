local map = {}, tileSize
local walkedMap = {}
local px, py
local speeds, speedIndex
local shouldDrawMap, shouldDrawWalked

function love.load()
	tileSize = 10

	px = 5
	py = 5

	speeds = { 0.05, 0.25, 0.5, 1 }
	speedIndex = #speeds

	shouldDrawMap = true
	shouldDrawWalked = false

	genMap()
end

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

function genRoom(x, y, width, height)
	y = y * tileSize
	x = x * tileSize
	width = width * tileSize
	height = height * tileSize
	for yy = y, y + height, tileSize do
		local xTiles = {}
		for xx = 0, love.graphics.getWidth(), tileSize do
			if xx < x or xx > x + width then xTiles[xx] = map[yy][xx]
			else xTiles[xx] = 1 end

			if (xx >= x + tileSize and xx <= (x - tileSize) + width) and (yy >= y + tileSize and yy <= (y - tileSize) + height) then xTiles[xx] = 0 end
		end
		map[yy] = xTiles
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
	print("ts "..score)
	return score
end

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
	local npx = px
	local npy = py

	local options = {} -- R, BR, B, BL, L, TL, T, TR
	options[1] = getTileScore(px + 1, py)
	options[2] = getTileScore(px + 1, py + 1)
	options[3] = getTileScore(px, py + 1)
	options[4] = getTileScore(px - 1, py + 1)
	options[5] = getTileScore(px - 1, py)
	options[6] = getTileScore(px - 1, py - 1)
	options[7] = getTileScore(px, py - 1)
	options[8] = getTileScore(px + 1, py - 1)
	for i = 1, #options do print(options[i]) end

	local best = chooseBestTile(options)
	if best == 1 then
		npx = px + 1
		npy = py
	elseif best == 2 then
		npx = px + 1
		npy = py + 1
	elseif best == 3 then
		npx = px
		npy = py + 1
	elseif best == 4 then
		npx = px - 1
		npy = py + 1
	elseif best == 5 then
		npx = px - 1
		npy = py
	elseif best == 6 then
		npx = px - 1
		npy = py - 1
	elseif best == 7 then
		npx = px
		npy = py - 1
	elseif best == 8 then
		npx = px + 1
		npy = py - 1
	end

	if isTileEmpty(npx, npy) then
		px = npx
		py = npy

		walkedMap[py * tileSize][px * tileSize] = walkedMap[py * tileSize][px * tileSize] + 1
	end

	love.timer.sleep(speeds[speedIndex])
end

function love.draw()
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

	-- Draw Player
	love.graphics.setColor(255, 0, 0)
	love.graphics.rectangle("line", px * tileSize, py * tileSize, tileSize, tileSize)

	-- Draw Front
	love.graphics.setColor(0, 255, 0)
	love.graphics.rectangle("line", (px + 1) * tileSize, py * tileSize, tileSize, tileSize)

	-- Draw Stats
	love.graphics.setColor(0, 0, 0)
	love.graphics.rectangle("fill", love.graphics.getWidth() - 100, 0, 100, 50)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", love.graphics.getWidth() - 100, 0, 100, 50)
	love.graphics.setColor(255, 0, 0)
	love.graphics.print("Speed: "..2 - speeds[speedIndex], love.graphics.getWidth() - 95, 15)
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