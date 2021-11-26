local execute = vim.api.nvim_command
local fn = vim.fn

local packer_install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(packer_install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', packer_install_path})
  execute 'packadd packer.nvim'
  execute 'PackerInstall'
end
