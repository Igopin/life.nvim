local M = {}

M.EMPTY_PIXEL = " "
M.PIXEL = "█"

---@class Frame
---@field width number
---@field height number
---@field field table
---@field empty_val string
M.Frame = {}
M.Frame.__index = M.Frame

function M.Frame:new(w, h)
	local f = {
		width = w,
		height = h,
		empty_val = M.EMPTY_PIXEL,
		field = {}
	}
	setmetatable(f, self)
	f:clear()

	return f
end

function M.Frame:fill_randomly()
	for i = 1, self.height do
		for j = 1, self.width do
			self.field[i][j] = math.random(0, 1) == 1 and M.PIXEL or M.EMPTY_PIXEL
		end
	end
end

function M.Frame:fill_figure()
	local coord = {
		{ 10, 10 },
		{ 9,  11 }, { 10, 11 }, { 11, 11 },
		{ 9,  12 }, { 11, 12 },
		{ 10, 13 }
	}
	for _, point in ipairs(coord) do
		local x, y = point[1], point[2]
		self:put_pixel(x, y, M.PIXEL)
	end
end

function M.Frame:put_pixel(x, y, pixel)
	pixel = pixel or M.PIXEL
	if x > 0 and y > 0 and x <= self.width and y <= self.height then
		self.field[y][x] = pixel
	end
end

function M.Frame:get_pixel(x, y)
	if x > 0 and y > 0 and x <= self.width and y <= self.height then
		return self.field[y][x]
	end
	return self.empty_val
end

function M.Frame:get_lines()
	local lines = {}
	for i = 1, self.height do
		table.insert(lines, { { table.concat(self.field[i], "") } })
	end
	return lines
end

function M.Frame:clear()
	for i = 1, self.height do
		self.field[i] = {}
		for j = 1, self.width do
			self.field[i][j] = self.empty_val
		end
	end
end

function M.Frame:copy()
	local copy = M.Frame:new(self.width, self.height)
	for i = 1, self.height do
		copy.field[i] = {}
		for j = 1, self.width do
			copy.field[i][j] = self.field[i][j]
		end
	end

	return copy
end

---@class Animation
---@field frame Frame
---@field fps integer
---@field is_run boolean
M.Animation = {}
M.Animation.__index = M.Animation

function M.Animation:new(frame, fps)
	return setmetatable({
		frame = frame,
		fps = fps,
		is_run = false,
	}, self)
end

function M.Animation:run(update_frame_func, draw_func)
	if self.timer then
		return
	end

	self.is_run = true

	self.timer = vim.loop.new_timer()
	self.timer:start(0, 1000 / self.fps, vim.schedule_wrap(function()
		-- I don't why but a timer callback is called after the timer is stopped.
		-- Variable `is_run` introduced to avoid render in such cases.
		if not self.is_run then
			return
		end

		draw_func(self.frame)
		update_frame_func(self.frame)
	end))
end

function M.Animation:stop()
	self.is_run = false
	if self.timer then
		self.timer:stop()
		self.timer = nil
	end
end

return M
