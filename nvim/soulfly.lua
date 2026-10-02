-- Optional LazyVim/Omarchy adapter; the colorscheme itself is independent.
local function active()
  local ok, lines = pcall(vim.fn.readfile, vim.fn.expand("~/.local/state/omarchy/current/theme.name"))
  return ok and lines[1] == "soulfly"
end

return {
  {
    name = "soulfly",
    dir = vim.fn.stdpath("data") .. "/site/pack/soulfly/start/soulfly",
    lazy = false,
    priority = 1000,
    config = function()
      -- Omarchy's hotreload selects its generated Aether scheme. Select our
      -- native scheme afterwards, also restoring surfaces after transparency.lua.
      local group = vim.api.nvim_create_augroup("SoulflyOmarchy", { clear = true })
      vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
        group = group,
        callback = function(event)
          if event.event == "ColorScheme" and event.match == "soulfly" then return end
          if active() then
            vim.schedule(function()
              if active() then vim.cmd.colorscheme("soulfly") end
            end)
          end
        end,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = function(_, opts)
      if active() then opts.colorscheme = "soulfly" end
    end,
  },
}
