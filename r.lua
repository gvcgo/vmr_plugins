--[[
    R from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "r"
plugin_name = "r"
plugin_version = "0.1"
homepage = "https://www.r-project.org/"

-- installer config
ic = C.installer({
    binary_dirs = {
        windows = { { "Scripts" }, { "Library", "bin" } },
        darwin = { { "bin" }, { "sbin" } },
        linux = { { "bin" }, { "sbin" } },
    },
})

-- spider
function crawl()
    return C.pixi("r")
end
