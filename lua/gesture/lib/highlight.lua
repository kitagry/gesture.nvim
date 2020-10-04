local M = {}

M.default = function(name, attributes)
  local attr = ""
  for key, v in pairs(attributes) do
    local value
    if type(v) == "table" then
      local hl_group, attr_key, mode, default = unpack(v)
      local id = vim.api.nvim_get_hl_id_by_name(hl_group)
      local attr_value = vim.fn.synIDattr(id, attr_key, mode)
      if attr_value ~= "" then
        value = attr_value
      else
        value = default
      end
    else
      value = v
    end
    attr = attr .. (" %s=%s"):format(key, value)
  end

  local cmd = ("highlight default %s %s"):format(name, attr)
  vim.api.nvim_command(cmd)
end

return M
