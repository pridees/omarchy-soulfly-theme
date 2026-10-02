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
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      local root = opts.sections and opts.sections.lualine_c and opts.sections.lualine_c[1]
      if type(root) == "table" then
        local original_color = root.color
        root.color = function()
          if vim.g.colors_name == "soulfly" then
            return { fg = require("soulfly.palette").accent }
          end
          return type(original_color) == "function" and original_color() or original_color
        end
      end
    end,
  },
  {
    "akinsho/bufferline.nvim",
    opts = function(_, opts)
      for _, offset in ipairs(opts.options and opts.options.offsets or {}) do
        if offset.filetype == "neo-tree" then
          offset.highlight = "NeoTreeTitleBar"
        end
      end
    end,
  },

}
