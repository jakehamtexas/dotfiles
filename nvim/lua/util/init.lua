local M = {}

M.tbl_some = function(pred, table)
  return not vim.tbl_isempty(vim.tbl_filter(pred, table))
end

return M
