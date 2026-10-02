local M = {}
-- Remap only the text component: devicons, folder icons and Git symbols keep
-- their existing highlights. Other colorschemes retain the original renderer.
local names = {
  NeoTreeGitAdded = 'SoulflyExplorerAdded',
  NeoTreeGitUntracked = 'SoulflyExplorerAdded',
  NeoTreeGitModified = 'SoulflyExplorerModified',
  NeoTreeGitUnstaged = 'SoulflyExplorerModified',
  NeoTreeGitStaged = 'SoulflyExplorerAdded',
  NeoTreeGitDeleted = 'SoulflyExplorerDeleted',
  NeoTreeGitConflict = 'SoulflyExplorerModified',
  NeoTreeGitRenamed = 'SoulflyExplorerRenamed',
  NeoTreeGitIgnored = 'SoulflyExplorerIgnored',
  NeoTreeIgnored = 'SoulflyExplorerIgnored',
  NeoTreeDotfile = 'SoulflyExplorerMuted',
  NeoTreeHiddenByName = 'SoulflyExplorerMuted',
  NeoTreeWindowsHidden = 'SoulflyExplorerMuted',
}
function M.wrap(renderer)
  return function(config, node, state)
    local result = renderer(config, node, state)
    if vim.g.colors_name == 'soulfly' and result then
      result.highlight = names[result.highlight] or 'SoulflyExplorerName'
    end
    return result
  end
end
return M
