--[[
    Rust from conda-forge (pixi).
--]]

local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
sdk_name = "rust"
plugin_name = "rust"
plugin_version = "0.1"
homepage = "https://www.rust-lang.org/"

-- installer config
ic = C.installer({
    binary_dirs = {
        windows = { { "cargo", "bin" }, { "Library", "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

-- spider
function crawl()
    return C.pixi("rust")
end
