# life.nvim
A simple plugin that replaces Neovim start screen with John Conway's Game of Life.

## Installation
Install the plugin with your preferred package manager, for example:

### [lazy](https://github.com/folke/lazy.nvim)
```lua
return {
    "igopin/life.nvim",
    lazy = false,
    opts = {
        fps = 60
    }
}
```
