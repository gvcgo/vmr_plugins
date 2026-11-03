--[[
    Cygwin for VMR.
    The upstream setup program is a rolling "latest" download.
    https://cygwin.com/
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "cygwin"
sdk_name = "cygwin"
plugin_version = "0.1"
homepage = "https://cygwin.com/"

-- installer config
ic = C.installer({
    flag_files = {
        windows = { "setup-x86_64.exe" },
        linux = { "setup-x86_64.exe" },
        darwin = { "setup-x86_64.exe" },
    },
    binary_rename = {
        name_flag = "setup-x86_64",
        rename_to = "cygwin-installer",
    },
})

-- spider
local SETUP_URL = "https://cygwin.com/setup-x86_64.exe"

function crawl()
    local vl = vmrNewVersionList()

    local item = {}
    item["url"] = SETUP_URL
    item["arch"] = "amd64"
    item["os"] = "windows"
    item["installer"] = vmrInstallerExecutable
    item["size"] = 0
    item["lts"] = ""

    vmrAddItem(vl, "latest", item)
    return vl
end
