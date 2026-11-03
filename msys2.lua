--[[
    MSYS2 for VMR.
    The upstream installer is published as a rolling nightly "latest" build.
    https://www.msys2.org/
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "msys2"
sdk_name = "msys2"
plugin_version = "0.1"
homepage = "https://www.msys2.org/"

-- installer config
ic = C.installer({
    flag_files = {
        windows = { "msys2-x86_64-latest.exe" },
        linux = { "msys2-x86_64-latest.exe" },
        darwin = { "msys2-x86_64-latest.exe" },
    },
    binary_rename = {
        name_flag = "msys2-x86_64-latest",
        rename_to = "msys2-installer",
    },
})

-- spider
local INSTALLER_URL =
"https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-x86_64-latest.exe"

function crawl()
    local vl = vmrNewVersionList()

    local item = {}
    item["url"] = INSTALLER_URL
    item["arch"] = "amd64"
    item["os"] = "windows"
    item["installer"] = vmrInstallerExecutable
    item["size"] = 0
    item["lts"] = ""

    vmrAddItem(vl, "latest", item)
    return vl
end
