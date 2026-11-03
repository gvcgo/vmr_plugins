--[[
    MongoDB from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "mongodb"
plugin_name = "mongodb"
plugin_version = "0.1"
homepage = "https://www.mongodb.com/"

-- installer config
ic = C.installer({
    binary_dirs = {
        windows = { { "Library", "bin" } },
        darwin = { { "bin" }, { "sbin" } },
        linux = { { "bin" }, { "sbin" } },
    },
})

-- spider
function crawl()
    return C.pixi("mongodb")
end
