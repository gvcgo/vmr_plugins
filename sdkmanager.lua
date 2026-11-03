--[[
    Android SDK command-line tools (sdkmanager) for VMR.
    Crawled live from the Android Studio download page.
    https://developer.android.com/studio
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "sdkmanager"
sdk_name = "sdkmanager"
plugin_version = "0.1"
homepage = "https://developer.android.com/studio"

-- installer config
ic = C.installer({
    flag_files = {
        windows = { "bin", "lib" },
        linux = { "bin", "lib" },
        darwin = { "bin", "lib" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        linux = { { "bin" } },
        darwin = { { "bin" } },
    },
})

-- spider
local DOWNLOAD_URL = "https://developer.android.com/studio?hl=en"
local HOST = "https://dl.google.com/android/repository"

local OS_MAP = {
    windows = "windows",
    linux = "linux",
    mac = "darwin",
}

local function parseOs(platform)
    local osStr = OS_MAP[platform]
    if osStr then
        return osStr
    end
    -- The download table labels Apple rows "Mac (Intel)" / "Mac (ARM)".
    if vmrHasPrefix(platform, "mac") then
        return "darwin"
    end
    return ""
end

function crawl()
    local vl = vmrNewVersionList()

    -- A browser User-Agent makes developer.android.com redirect into an OAuth flow; the page is
    -- served directly for a plain client (this matches the upstream Go crawler's default UA).
    local resp = vmrGetResponse(DOWNLOAD_URL, 600, {})

    -- The command-line tools table is the second `table.download` on the page.
    local tableSel = vmrEq(vmrInitSelection(resp, "table.download"), 1)
    local rows = vmrFind(tableSel, "tr")

    vmrEach(rows, function(idx, ss)
        if idx == 0 then
            return
        end

        local tds = vmrFind(ss, "td")
        local platform = vmrToLower(vmrTrimSpace(vmrText(vmrEq(tds, 0))))
        local fName = vmrTrimSpace(vmrText(vmrFind(vmrEq(tds, 1), "button")))
        if platform == "" or fName == "" then
            return
        end

        -- File names look like `commandlinetools-win-15859902_latest.zip` or
        -- `commandlinetools-mac_x86_64-15859902_latest.zip`; the build number is the numeric
        -- part of the last dash-separated segment (a bare first-digit regexp would match the
        -- "86"/"64" inside "x86_64").
        local parts, nParts = vmrSplit(fName, "-")
        local tail = fName
        if nParts > 0 then
            tail = parts[nParts]
        end
        local versionName = vmrRegexpFindString("(\\d+)", tail)
        if versionName == "" then
            return
        end

        local sum = vmrTrimSpace(vmrText(vmrEq(tds, 3)))

        local item = {}
        item["url"] = vmrUrlJoin(HOST, fName)
        item["arch"] = "any"
        item["os"] = parseOs(platform)
        item["sum"] = sum
        if sum ~= "" then
            item["sum_type"] = "sha256"
        end
        item["installer"] = vmrInstallerUnarchiver
        item["size"] = 0
        item["lts"] = ""

        vmrAddItem(vl, versionName, item)
    end)

    return vl
end
