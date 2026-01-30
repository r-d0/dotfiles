
-- Set Node (nvm) in PATH so Mason can find npm
local nvm_node = os.getenv("HOME") .. "/.nvm/versions/node/v24.13.0/bin"
vim.env.PATH = nvm_node .. ":" .. vim.env.PATH

require("ruadhan.core")
require("ruadhan.lsp")
require("ruadhan.lazy")
