--[[
    MoonBit for VMR.
    The MoonBit CLI is published as a rolling "latest" set of binaries; each platform archive
    carries the matching core library archive in `extra`.
    https://www.moonbitlang.com/
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "moonbit"
sdk_name = "moonbit"
plugin_version = "0.1"
homepage = "https://www.moonbitlang.com/"

-- installer config
ic = C.installer({
    flag_files = {
        windows = { "moon.exe", "moonc.exe" },
        linux = { "moon", "moonc" },
        darwin = { "moon", "moonc" },
    },
    flag_dir_excepted = true,
})

-- spider
local VERSIONS = { "latest" }

local CORE_URLS = {
    "https://cli.moonbitlang.com/binaries/%s/moonbit-darwin-x86_64.tar.gz",
    "https://cli.moonbitlang.com/binaries/%s/moonbit-darwin-aarch64.tar.gz",
    "https://cli.moonbitlang.com/binaries/%s/moonbit-linux-x86_64.tar.gz",
    "https://cli.moonbitlang.com/binaries/%s/moonbit-windows-x86_64.zip",
}

local CORE_LIB_URL = "https://cli.moonbitlang.com/cores/core-%s.tar.gz"

local function parseOs(dUrl)
    if vmrContains(dUrl, "darwin") then
        return "darwin"
    end
    if vmrContains(dUrl, "linux") then
        return "linux"
    end
    if vmrContains(dUrl, "windows") then
        return "windows"
    end
    return ""
end

local function parseArch(dUrl)
    if vmrContains(dUrl, "aarch64") then
        return "arm64"
    end
    if vmrContains(dUrl, "x86_64") then
        return "amd64"
    end
    return ""
end

function crawl()
    local vl = vmrNewVersionList()

    for _, versionStr in ipairs(VERSIONS) do
        for _, urlTemplate in ipairs(CORE_URLS) do
            local dUrl = vmrSprintf(urlTemplate, { versionStr })
            local osStr = parseOs(dUrl)
            local archStr = parseArch(dUrl)
            if osStr ~= "" and archStr ~= "" then
                local item = {}
                item["url"] = dUrl
                item["os"] = osStr
                item["arch"] = archStr
                item["installer"] = vmrInstallerUnarchiver
                item["extra"] = vmrSprintf(CORE_LIB_URL, { versionStr })
                item["size"] = 0
                item["lts"] = ""

                vmrAddItem(vl, versionStr, item)
            end
        end
    end

    return vl
end
