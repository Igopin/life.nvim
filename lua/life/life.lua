local M = {}

local anim = require('life.animation')
--local Frame = require('life.animation').Frame

---@param frame Frame
---@param x integer
---@param y integer
---@param pixel string?
local count_neighbours = function(frame, x, y, pixel)
	pixel = pixel or anim.PIXEL
	local dirs = {
		{ -1, 1 }, { 0, 1 }, { 1, 1 },
		{ -1, 0 }, { 1, 0 },
		{ -1, -1 }, { 0, -1 }, { 1, -1 },
	}

	local sum = 0
	for _, dir in ipairs(dirs) do
		local nx, ny = x + dir[1], y + dir[2]
		if frame:get_pixel(nx, ny) == pixel then
			sum = sum + 1
		end
	end

	return sum
end

---@param frame Frame
M.next_generation = function(frame)
	local frame_copy = frame:copy()

	for y = 1, frame.height do
		for x = 1, frame.width do
			local n = count_neighbours(frame_copy, x, y)
			local alive = (frame_copy:get_pixel(x, y) == anim.PIXEL)

			if alive then
				if n < 2 or n > 3 then
					frame:put_pixel(x, y, anim.EMPTY_PIXEL)
				end
			else
				if n == 3 then
					frame:put_pixel(x, y, anim.PIXEL)
				end
			end
		end
	end
end

return M
