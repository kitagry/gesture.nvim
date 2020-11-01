local M = {}

local Inputs = {}
Inputs.__index = function(self, k)
  if type(k) == "number" then
    return self._inputs[k]
  end
  return Inputs[k]
end

function Inputs.new(inputs)
  vim.validate({inputs = {inputs, "table", true}})
  local tbl = {_inputs = inputs or {}}
  return setmetatable(tbl, Inputs)
end

function Inputs.add(self, input)
  local last = self._inputs[#self._inputs]
  if last == nil or last.value ~= input.value then
    table.insert(self._inputs, input)
    return
  end

  last.length = last.length + input.length
end

function Inputs.all(self)
  return ipairs(self._inputs)
end

function Inputs.is_empty(self)
  return #self._inputs == 0
end

function Inputs.identify(self)
  local ids = vim.tbl_map(function(input)
    return input.value
  end, self._inputs)
  return table.concat(ids, "-")
end

M.Inputs = Inputs

return M
