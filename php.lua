--[[
    PHP support for VMR.
    Conda-forge packages plus the official Windows release archives.
    https://windows.php.net/downloads/releases/archives/
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "php"
sdk_name = "php"
plugin_version = "0.1"
homepage = "https://www.php.net/"

-- installer config
ic = C.installer({
    flag_files = {
        windows = { "php.exe", "lib" },
        linux = { "bin", "lib" },
        darwin = { "bin", "lib" },
    },
    binary_dirs = {
        linux = { { "bin" } },
        darwin = { { "bin" } },
    },
})

-- spider
local ARCHIVE_BASE = "https://windows.php.net/downloads/releases/archives"

local function parseVersion(dUrl)
    local v = vmrRegexpFindString("-\\d+(\\.\\d+){2}-", dUrl)
    return vmrTrim(v, "-")
end

local function fileFilter(text)
    if not vmrHasSuffix(text, "zip") then
        return false
    end
    if vmrContains(text, "-nts-") then
        return false
    end
    if not vmrContains(text, "x64") then
        return false
    end
    if vmrContains(text, "-devel-") or vmrContains(text, "-test-") or vmrContains(text, "-debug-") then
        return false
    end
    return true
end

function crawl()
    local vl = C.pixi("php")

    local headers = {}
    headers["User-Agent"] =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    local resp = vmrGetResponse(ARCHIVE_BASE .. "/", 600, headers)

    local anchors = vmrInitSelection(resp, "a")
    vmrEach(anchors, function(_, ss)
        local text = vmrTrimSpace(vmrText(ss))
        if not fileFilter(text) then
            return
        end

        local href = vmrAttr(ss, "href")
        if href == "" then
            return
        end

        local versionStr = parseVersion(href)
        if versionStr == "" or vmrHasPrefix(versionStr, "5.") then
            return
        end

        local item = {}
        if vmrHasPrefix(href, "http") then
            item["url"] = href
        else
            item["url"] = vmrUrlJoin(ARCHIVE_BASE, href)
        end
        item["arch"] = "amd64"
        item["os"] = "windows"
        item["installer"] = vmrInstallerUnarchiver
        item["size"] = 0
        item["lts"] = ""

        vmrAddItem(vl, versionStr, item)
    end)

    return vl
end
