local listlib = require("gesture.lib.list")
local highlightlib = require("gesture.lib.highlight")
local vim = vim

local M = {}

local GestureBoard = {}
GestureBoard.__index = GestureBoard
M.GestureBoard = GestureBoard

local one_padding = 3
local both_padding = one_padding * 2
local round = function(x)
  return math.floor(x + 0.5)
end

function GestureBoard._new(range_map)
  local tbl = {range_map = range_map or {}}
  return setmetatable(tbl, GestureBoard)
end

function GestureBoard.create(inputs, gesture, has_forward_match)
  if inputs:is_empty() then
    return GestureBoard._new()
  end

  local editor_width = vim.o.columns
  local width = editor_width / 4

  local texts = listlib.wrap(inputs:values(), width - both_padding)
  local lines = {"", unpack(texts)}
  if gesture then
    table.insert(lines, gesture.name)
  else
    table.insert(lines, "")
  end

  local row = math.max(2, math.floor(vim.o.lines / 2 - round(#lines / 2) - 1))
  local center = round(editor_width / 2)
  local half_width = round(width / 2)
  local start_col = math.max(0, center - half_width)
  local end_col = math.min(center + half_width, editor_width)

  local hl_group = M._GestureInput()
  if not has_forward_match then
    hl_group = M._GestureInputNotMatched()
  end

  local height = vim.api.nvim_win_get_height(0)
  local range_map = {}
  local action_label_hl_group = M._GestureActionLabel()
  for i, line in ipairs(lines) do
    local y = row + i
    if y > height then
      break
    end

    local padding = math.floor((width - #line) / 2)
    local ranges = {
      {start_col, start_col + padding, hl_group},
      {start_col + padding + #line + 1, end_col, hl_group},
    }

    local hl
    if gesture and line == gesture.name then
      hl = action_label_hl_group
    elseif line ~= "" then
      hl = hl_group
    end
    if hl then
      table.insert(ranges, 2, {start_col + padding + 1, start_col + padding + #line, hl, line})
    end

    range_map[y] = ranges
  end

  return GestureBoard._new(range_map)
end

local blend = 0

M._GestureInput = highlightlib.Ensured.new("GestureInput", function(hl_group)
  return highlightlib.default(hl_group, {
    ctermfg = {"NormalFloat", 230},
    guifg = {"NormalFloat", "#fffeeb"},
    ctermbg = {"NormalFloat", 235},
    guibg = {"NormalFloat", "#3a4b5c"},
    blend = blend,
    gui = "bold",
  })
end)

M._GestureInputNotMatched = highlightlib.Ensured.new("GestureInputNotMatched", function(hl_group)
  return highlightlib.default(hl_group, {
    ctermfg = {"Comment", 103},
    guifg = {"Comment", "#8d9eb2"},
    ctermbg = {"NormalFloat", 235},
    guibg = {"NormalFloat", "#3a4b5c"},
    blend = blend,
  })
end)

M._GestureActionLabel = highlightlib.Ensured.new("GestureActionLabel", function(hl_group)
  return highlightlib.default(hl_group, {
    gui = "bold",
    ctermfg = {"Statement", 153},
    guifg = {"Statement", "#a8d2eb"},
    blend = blend,
  })
end)

M.hl_groups = {M._GestureInput(), M._GestureInputNotMatched(), M._GestureActionLabel()}

return M
