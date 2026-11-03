--[[
    Thrift compiler from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "thrift-compiler"
plugin_name = "thrift-compiler"
plugin_version = "0.1"
homepage = "https://thrift.apache.org/"

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
    return C.pixi("thrift-compiler")
end
