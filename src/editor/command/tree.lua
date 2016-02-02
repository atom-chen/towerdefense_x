local M = class("command.tree", function()
    return {}
end)

function M:create( ... )
	-- body
end
function M:execute( treenode , params)
	self.treenode = treenode
	print("execute",params)
end
function M:unexecute( treenode , params)
	if self.treenode then
		print("unexecute")
	end
end
return M