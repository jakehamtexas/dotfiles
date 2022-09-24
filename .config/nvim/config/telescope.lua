local telescope = function(vimp)
      vimp.nnoremap('<leader>ff', '<CMD>Telescope find_files hidden=true<CR>')
      vimp.nnoremap('<leader>fg', function()
            require('telescope').extensions.live_grep_args.live_grep_args()
      end)
      vimp.nnoremap('<leader>fcg', '<CMD>Telescope grep_string hidden=true<CR>')

      vimp.nnoremap('<leader>fb', '<CMD>Telescope buffers<CR>')

      vimp.nnoremap('<leader>fGs', '<CMD>Telescope git_status<CR>')
      vimp.nnoremap('<leader>fGc', '<CMD>Telescope git_commits<CR>')
      vimp.nnoremap('<leader>fGb', '<CMD>Telescope git_bcommits<CR>')

      vimp.nnoremap('<leader>fGfd', '<CMD>:Picker changed_files_develop<CR>')
      vimp.nnoremap('<leader>fGfm', '<CMD>:Picker changed_files_main<CR>')

      vimp.nnoremap('<leader>fGG', '<CMD>:PickPicker<CR>')

      vimp.nnoremap('<leader>fl', '<CMD>Telescope builtin<CR>')
      vimp.nnoremap('<leader>fd', '<CMD>Telescope diagnostics<CR>')
      vimp.nnoremap('<leader>fqf', '<CMD>Telescope quickfix<CR>')
      vimp.nnoremap('<leader>fh', '<CMD>Telescope search_history<CR>')
end
