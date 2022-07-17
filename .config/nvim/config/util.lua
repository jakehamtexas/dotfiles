local M = {}

M['unload_lua_namespace'] = function(prefix)
  local prefix_with_dot = prefix .. '.'
  for key, value in pairs(package.loaded) do
    if key == prefix or key:sub(1, #prefix_with_dot) == prefix_with_dot then
      package.loaded[key] = nil
    end
  end
end

M['dump'] = function(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. M.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

return M
