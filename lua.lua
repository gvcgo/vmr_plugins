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
ic = vmrNewInstallerConfig()
ic = vmrAddBinaryDirs(ic, "windows", { "Library", "bin" })
ic = vmrAddBinaryDirs(ic, "linux", { "bin" })
ic = vmrAddBinaryDirs(ic, "darwin", { "bin" })

-- spider
function crawl()
    local vl = vmrNewVersionList()
    local result = vmrSearchByConda(vl, "lua")
    return result
end
