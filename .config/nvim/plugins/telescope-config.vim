
nnoremap <leader>ff <CMD>Telescope find_files hidden=true<CR>
nnoremap <leader>fg <CMD>:lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>
nnoremap <leader>fcg <CMD>Telescope grep_string hidden=true<CR>

nnoremap <leader>fb <CMD>Telescope buffers<CR>

nnoremap <leader>fGs <CMD>Telescope git_status<CR>
nnoremap <leader>fGc <CMD>Telescope git_commits<CR>
nnoremap <leader>fGb <CMD>Telescope git_bcommits<CR>

nnoremap <leader>fGfd <CMD>:Picker changed_files_develop<CR>
nnoremap <leader>fGfm <CMD>:Picker changed_files_main<CR>

nnoremap <leader>fGG <CMD>:PickPicker<CR>

nnoremap <leader>fl <CMD>Telescope builtin<CR>
nnoremap <leader>fd <CMD>Telescope diagnostics<CR>
nnoremap <leader>fqf <CMD>Telescope quickfix<CR>
nnoremap <leader>fh <CMD>Telescope search_history<CR>
