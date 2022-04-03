nnoremap <leader>ff <CMD>Telescope find_files<CR>
nnoremap <leader>fg :lua require("telescope").extensions.live_grep_raw.live_grep_raw()<CR>
nnoremap <leader>fb <CMD>Telescope buffers<CR>
nnoremap <leader>fl <CMD> :lua require'telescope.builtin'.builtin()<CR>
nnoremap <leader>fgs <CMD> :lua require'telescope.builtin'.git_status()<CR>
nnoremap <leader>fgl <CMD> :lua require'telescope.builtin'.git_commits()<CR>
nnoremap <leader>fgb <CMD> :lua require'telescope.builtin'.git_bcommits()<CR>
