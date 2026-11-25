--[[
    Visual Studio Code for VMR.
    Crawled live from https://code.visualstudio.com/sha?build=stable
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "vscode"
sdk_name = "vscode"
plugin_version = "0.1"
homepage = "https://code.visualstudio.com/"

ic = C.installer({
    flag_files = {
        windows = { "bin", "resources" },
        linux = { "bin", "resources" },
        darwin = { "Contents" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        linux = { { "bin" } },
        darwin = { { "Contents", "Resources", "app", "bin" } },
    },
})

-- spider
local DOWNLOAD_URL = "https://code.visualstudio.com/sha?build=stable"

local function fileFilter(dUrl)
    if vmrContains(dUrl, "_cli") or vmrContains(dUrl, "armhf") or vmrContains(dUrl, "armv7hl") then
        return false
    end
    return vmrHasSuffix(dUrl, ".tar.gz") or vmrHasSuffix(dUrl, ".zip")
        or (vmrContains(dUrl, "darwin") and vmrHasSuffix(dUrl, ".dmg"))
end

local function parseArch(platformOs)
    if vmrContains(platformOs, "-x64") then
        return "amd64"
    end
    if vmrContains(platformOs, "-arm64") then
        return "arm64"
    end
    if platformOs == "darwin" then
        return "amd64"
    end
    if vmrContains(platformOs, "-universal") then
        return "any"
    end
    return ""
end

local function parseOs(platformOs)
    if vmrContains(platformOs, "win32") then
        return "windows"
    end
    if vmrContains(platformOs, "darwin") then
        return "darwin"
    end
    if vmrContains(platformOs, "linux") then
        return "linux"
    end
    return ""
end


function crawl()
    local vl = vmrNewVersionList()

    local headers = {}
    headers["User-Agent"] =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    local resp = vmrGetResponse(DOWNLOAD_URL, 600, headers)
    local result = vmrInitGJson(resp)

    vmrSliceEach(result, "products", function(_, vItem)
        local dUrl = vmrGetString(vItem, "url")
        if not fileFilter(dUrl) then
            return
        end

        local platformOs = vmrGetString(vItem, "platform.os")
        local archStr = parseArch(platformOs)
        local osStr = parseOs(platformOs)
        if archStr == "" or osStr == "" then
            return
        end

        local versionStr = vmrGetString(vItem, "name")
        if versionStr == "" then
            return
        end

        local item = {}
        item["url"] = dUrl
        item["arch"] = archStr
        item["os"] = osStr
        item["sum"] = vmrGetString(vItem, "sha256hash")
        if item["sum"] ~= "" then
            item["sum_type"] = "sha256"
        end
        item["installer"] = vmrInstallerUnarchiver
        item["size"] = 0
        item["lts"] = ""

        vmrAddItem(vl, versionStr, item)
    end)

    return vl
end
