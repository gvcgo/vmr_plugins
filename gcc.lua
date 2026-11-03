--[[
    GCC from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "gcc"
plugin_name = "gcc"
plugin_version = "0.1"
homepage = "https://gcc.gnu.org/"

-- installer config
ic = C.installer({
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

-- spider
function crawl()
    return C.pixi("gcc")
end
