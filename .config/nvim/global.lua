package.unload = function(prefix)
   local prefix_with_dot = prefix .. '.'
   for key, value in pairs(package.loaded) do
      if key == prefix or key:sub(1, #prefix_with_dot) == prefix_with_dot then
         package.loaded[key] = nil
      end
   end
end

function vim.source(name)
   local path = os.getenv('NVIM_DIR') .. '/config/' .. name .. '.vim'
   vim.cmd('source ' .. path)
end

function package.path_add(str)
   local path = string.format("%s/?.lua;", str);
   package.path = path .. package.path
end

function string.split(inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t = {}
   for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
      table.insert(t, str)
   end
   return t
end

function table.contains(table, element)
   for _, value in pairs(table) do
      if value == element then
         return true
      end
   end
end