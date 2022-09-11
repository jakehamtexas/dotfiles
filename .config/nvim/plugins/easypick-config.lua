local easypick = require("easypick")


local change_files = function(base_branch) 
	local with_origin = "origin/" .. base_branch
	return {
		name = "changed_files_" .. base_branch,
		command = "git diff --name-only $(git merge-base HEAD " .. with_origin .. " )",
		previewer = easypick.previewers.branch_diff({ base_branch = with_origin }) 
	}
end

easypick.setup({
	pickers = {
		-- diff current branch with base_branch and show files that changed with respective diffs in preview 
		change_files("develop"),
		change_files("main"),

		-- list files that have conflicts with diffs in preview
		{
			name = "conflicts",
			command = "git diff --name-only --diff-filter=U --relative",
			previewer = easypick.previewers.file_diff()
		},
	}
})
