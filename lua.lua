--[[
    Lua from Conda.
--]]

-- global variables
sdk_name = "lua"
plugin_name = "lua"
plugin_version = "0.1"
prequisite = "conda"
homepage = "https://www.lua.org/"

-- installer config
ic = newInstallerConfig()
ic = addBinaryDirs(ic, "windows", {"Library", "bin"})
ic = addBinaryDirs(ic, "linux", {"bin"})
ic = addBinaryDirs(ic, "darwin", {"bin"})

-- spider
function crawl()
    local vl = newVersionList()
    local result = searchByConda(vl, "lua")
    return result
end
