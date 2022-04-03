local M = {}

local function exec(command)
  local handle = io.popen(command)

  local raw = handle:read()
  handle:close()

  local trim_whitespace_sub = "^%s*(.-)%s*$"
  return string.gsub(raw, trim_whitespace_sub, "%1")
end

local function git_session_path()
  local repo_name = exec('basename $(git remote get-url origin) .git')
  local branch_name = exec('git branch --show-current')

  local dir = os.getenv('NVIM_DIR') .. '/sessions'
  return string.format("%s/%s/%s.vim", dir, repo_name, branch_name)
end

M['git_sesh_save'] = function()
  local path = git_session_path()

  local dir = exec('dirname ' .. path)
  os.execute('mkdir -p ' .. dir)
  os.execute('touch ' .. path)

  vim.cmd("mksession! " .. path)
end

M['git_sesh_load'] = function()
  vim.cmd("source " .. git_session_path())
end

return M
