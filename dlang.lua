-- dlang: live HTML crawl of the D release archive
-- (ported from vcollector official/dlang.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "dlang"
sdk_name = "dlang"
plugin_version = "0.1"
homepage = "https://dlang.org/"

ic = C.installer({
    flag_files = {
        windows = { "windows" },
        darwin = { "osx" },
        linux = { "linux" },
    },
    binary_dirs = {
        windows = { { "windows", "bin" } },
        darwin = { { "osx", "bin" } },
        linux = { { "linux", "bin64" } },
    },
})

local HOST = "https://downloads.dlang.org"
local DOWNLOAD_URL = "https://downloads.dlang.org/releases/2.x/"

local function get_version(vl, vname, vhref)
    local durl = vmrUrlJoin(HOST, vhref)
    local resp = vmrGetResponse(durl, 180, {})

    local assets = {}
    vmrEach(vmrInitSelection(resp, "div#content li a"), function(_, anchor)
        local href = vmrAttr(anchor, "href")
        local os_name, priority = "", 0
        if vmrHasSuffix(href, ".windows.zip") then
            os_name, priority = "windows", 2
        elseif vmrHasSuffix(href, ".windows.7z") then
            os_name, priority = "windows", 1
        elseif vmrHasSuffix(href, ".osx.zip") then
            os_name, priority = "darwin", 2
        elseif vmrHasSuffix(href, ".osx.tar.xz") then
            os_name, priority = "darwin", 1
        elseif vmrHasSuffix(href, ".linux.zip") then
            os_name, priority = "linux", 2
        elseif vmrHasSuffix(href, ".linux.tar.xz") then
            os_name, priority = "linux", 1
        end
        if os_name ~= "" and (not assets[os_name] or priority > assets[os_name].priority) then
            assets[os_name] = { url = vmrUrlJoin(HOST, href), priority = priority }
        end
    end)

    for os_name, asset in pairs(assets) do
        vmrAddItem(vl, vname, {
            url = asset.url,
            arch = "amd64",
            os = os_name,
            sum = "",
            sum_type = "",
            size = 0,
            installer = vmrInstallerUnarchiver,
            lts = "",
            extra = "",
        })
    end
end

function crawl()
    local vl = vmrNewVersionList()
    local resp = vmrGetResponse(DOWNLOAD_URL, 180, {})

    vmrEach(vmrInitSelection(resp, "div#content li a"), function(_, anchor)
        local vname = vmrText(anchor)
        local vhref = vmrAttr(anchor, "href")
        if vhref == "" then
            return
        end

        local parts, n = vmrSplit(vname, ".")
        if n < 3 then
            return
        end

        -- Only releases newer than 2.065.0 are published as archives with this layout.
        local minor = tonumber(parts[2] or "") or 0
        if minor < 65 then
            return
        end

        get_version(vl, vname, vhref)
    end)

    return vl
end
