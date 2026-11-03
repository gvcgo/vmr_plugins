--[[
    PyPy from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "pypy"
plugin_name = "pypy"
plugin_version = "0.1"
homepage = "https://www.pypy.org/"

-- installer config
ic = C.installer({
    binary_dirs = {
        windows = { { "" }, { "Scripts" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

-- spider
function crawl()
    return C.pixi("pypy")
end
