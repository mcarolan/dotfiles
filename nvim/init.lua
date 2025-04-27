require("config.lazy")

require("mason").setup()

require("mason-lspconfig").setup()

require("lspconfig").lua_ls.setup({
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" }, -- Ignore 'vim' as undefined
      },
      format = {
        enable = true, -- Enable formatting
      },
    },
  },
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("neo-tree.command").execute({ action = "show" })
  end,
})

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local path = vim.api.nvim_buf_get_name(0)

    -- Skip if it's not a normal file
    if path == "" or vim.bo.buftype ~= "" or vim.fn.filereadable(path) == 0 then
      return
    end

    -- Change cwd to the file's directory
    local dir = vim.fn.fnamemodify(path, ":p:h")
    if vim.fn.isdirectory(dir) == 1 then
      vim.cmd("cd " .. dir)
    end

    -- Reveal in Neo-tree
    local ok, neotree = pcall(require, "neo-tree.command")
    if ok then
      neotree.execute({ source = "filesystem", action = "show", reveal = true })
    end
  end,
})

vim.g.mapleader = " "
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

vim.keymap.set("n", "<leader>f", function()
  vim.lsp.buf.format()
end, { desc = "Format current buffer" })

vim.keymap.set("n", "<leader>x", function()
  local file = vim.fn.expand("%:p")
  if vim.fn.filereadable(file) == 1 then
    vim.cmd("split | terminal " .. file)
  else
    print("File is not readable: " .. file)
  end
end, { desc = "Execute file" })

-- Auto-save when leaving insert mode or changing text
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function()
    if vim.bo.modified and vim.fn.expand("%") ~= "" then
      vim.cmd("silent write")

      -- Show a message for 1 second
      vim.api.nvim_echo({ { "💾 Auto-saved", "None" } }, false, {})
      vim.defer_fn(function()
        vim.api.nvim_echo({}, false, {})
      end, 1000) -- 1000 ms = 1 second
    end
  end,
})

vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit window" })
vim.keymap.set("n", "<leader>Q", ":qa<CR>", { desc = "Quit all" })

vim.keymap.set({ "n", "v" }, "y", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "n", "v" }, "p", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set({ "n", "v" }, "d", '"+d', { desc = "Delete to system clipboard" })

