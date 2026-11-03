-- zig: live HTML crawl of https://ziglang.org/download/
-- (ported from vcollector official/zig.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "zig"
sdk_name = "zig"
plugin_version = "0.1"
homepage = "https://ziglang.org/"

ic = C.installer({
    flag_files = {
        windows = { "LICENSE" },
        darwin = { "LICENSE" },
        linux = { "LICENSE" },
    },
})

local DOWNLOAD_URL = "https://ziglang.org/download/"

local function parse_arch(url)
    if vmrContains(url, "x86_64") then
        return "amd64"
    end
    if vmrContains(url, "aarch64") then
        return "arm64"
    end
    return ""
end

local function parse_os(url)
    if vmrContains(url, "windows") then
        return "windows"
    end
    if vmrContains(url, "linux") then
        return "linux"
    end
    if vmrContains(url, "macos") then
        return "darwin"
    end
    return ""
end

function crawl()
    local vl = vmrNewVersionList()
    local resp = vmrGetResponse(DOWNLOAD_URL, 180, {})
    local headings = vmrInitSelection(resp, "h2")
    local tables = vmrInitSelection(resp, "table")

    vmrEach(headings, function(index, heading)
        -- The page labels sections ("Latest Stable Version (X.Y.Z)") rather than listing bare
        -- version headings; fall back to the whole heading text when no version is present.
        local heading_text = vmrTrimSpace(vmrText(heading))
        local vname = vmrRegexpFindString("\\d+(\\.\\d+){1,2}", heading_text)
        if vname == "" then
            vname = heading_text
        end

        local table_sel = vmrEq(tables, index)
        vmrEach(vmrFind(table_sel, "tr"), function(_, row)
            local th = vmrToLower(vmrTrimSpace(vmrText(vmrFind(row, "th"))))
            local cells = vmrFind(row, "td")
            local cell_count = 0
            vmrEach(cells, function()
                cell_count = cell_count + 1
            end)

            if th == "os" or cell_count < 4 then
                return
            end

            local url = vmrAttr(vmrFind(vmrEq(cells, 1), "a"), "href")
            if url == "" then
                return
            end

            local arch = parse_arch(url)
            local os_name = parse_os(url)
            if arch == "" or os_name == "" then
                return
            end

            vmrAddItem(vl, vname, {
                url = url,
                arch = arch,
                os = os_name,
                sum = "",
                sum_type = "",
                size = 0,
                installer = vmrInstallerUnarchiver,
                lts = "",
                extra = "",
            })
        end)
    end)

    return vl
end
