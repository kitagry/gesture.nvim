local M = {}

--- Draw a gesture line.
function M.draw()
  require("gesture.command").draw()
end

--- Finish the gesture and execute matched action.
function M.finish()
  return require("gesture.command").finish()
end

--- Cancel the gesture.
function M.cancel()
  require("gesture.command").cancel()
end

--- Register a gesture.
--- @param info table: |gesture.nvim-gesture-info|
function M.register(info)
  require("gesture.command").register(info)
end

--- Clear the registered gestures.
function M.clear()
  require("gesture.command").clear()
end

--- Up input
--- @param opts table|nil: |gesture.nvim-input-opts|
--- @return table: used as an element of |gesture.nvim-gesture-info|'s inputs
function M.up(opts)
  return require("gesture.model.direction").up(opts)
end

--- Down input
--- @param opts table|nil: |gesture.nvim-input-opts|
--- @return table: used as an element of |gesture.nvim-gesture-info|'s inputs
function M.down(opts)
  return require("gesture.model.direction").down(opts)
end

--- Right input
--- @param opts table|nil: |gesture.nvim-input-opts|
--- @return table: used as an element of |gesture.nvim-gesture-info|'s inputs
function M.right(opts)
  return require("gesture.model.direction").right(opts)
end

--- Left input
--- @param opts table|nil: |gesture.nvim-input-opts|
--- @return table: used as an element of |gesture.nvim-gesture-info|'s inputs
function M.left(opts)
  return require("gesture.model.direction").left(opts)
end

return M
