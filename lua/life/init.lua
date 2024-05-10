local M = {}

---@param win window
---@param fps integer
---@return Animation
local function create_animation(win, fps)
	local w = vim.api.nvim_win_get_width(win)
	local h = vim.api.nvim_win_get_height(win)

	local anim = require('life.animation')

	local frame = anim.Frame:new(w, h)
	frame:fill_randomly()

	return anim.Animation:new(frame, fps)
end

---@param frame Frame
local function update_frame(frame)
	require('life.life').next_generation(frame)
end

---@param buf buffer
---@param ns_id integer
---@param extmark_id integer
local build_draw_function = function(buf, ns_id, extmark_id)
	return function(frame)
		if not vim.api.nvim_buf_is_valid(buf) then
			return
		end
		vim.api.nvim_buf_set_extmark(buf, ns_id, 0, 0, {
			id = extmark_id,
			virt_lines = frame:get_lines(),
			virt_text_pos = 'overlay',
		})
	end
end

M.setup = function(opts)
	if vim.fn.argc() > 0 then
		return
	end

	opts = opts or {}

	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_win_get_buf(win)

	local ns = vim.api.nvim_create_namespace("")
	local extmark = vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, { virt_text_pos = 'overlay' })

	local animation = create_animation(win, opts.fps or 24)

	local group = vim.api.nvim_create_augroup("NvimLife", { clear = true })
	vim.api.nvim_create_autocmd('VimEnter', {
		group = group,
		callback = vim.schedule_wrap(function(autocmd)
			animation:run(update_frame, build_draw_function(buf, ns, extmark))
			vim.api.nvim_del_autocmd(autocmd.id)

			vim.api.nvim_create_autocmd({ 'WinResized', 'CmdlineEnter', 'ModeChanged', 'TextChanged' }, {
				group = group,
				callback = function(inner_autocmd)
					animation:stop()

					vim.api.nvim_buf_del_extmark(buf, ns, extmark)
					vim.api.nvim_del_autocmd(inner_autocmd.id)
				end
			})
		end)
	})
end

return M

