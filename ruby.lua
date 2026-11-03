--[[
    Ruby from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "ruby"
plugin_name = "ruby"
plugin_version = "0.1"
homepage = "https://www.ruby-lang.org/en/"

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
    return C.pixi("ruby")
end
