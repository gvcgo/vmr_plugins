--[[
    LFortran from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "lfortran"
plugin_name = "lfortran"
plugin_version = "0.1"
homepage = "https://lfortran.org/"

-- installer config
ic = C.installer({
    binary_dirs = {
        windows = { { "Library", "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

-- spider
function crawl()
    return C.pixi("lfortran")
end
