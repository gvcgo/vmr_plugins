-- dotnet: live HTML crawl of the .NET download pages and their per-release detail pages
-- (ported from vcollector official/dotnet.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "dotnet"
sdk_name = "dotnet"
plugin_version = "0.1"
homepage = "https://dotnet.microsoft.com/"

ic = C.installer({
    flag_files = {
        windows = { "shared", "sdk", "host" },
        darwin = { "shared", "sdk", "host" },
        linux = { "shared", "sdk", "host" },
    },
    additional_envs = {
        { name = "DOTNET_ROOT", value = {}, version = "" },
    },
})

local DOWNLOAD_URL = "https://dotnet.microsoft.com/download/dotnet"
local HOST = "https://dotnet.microsoft.com"

local EXCLUDE_LIST = { "alpine", "installer", "winget", "arm32", "install", "scripts" }

local function filter_url(vurl)
    if vurl == "" then
        return false
    end
    for _, item in ipairs(EXCLUDE_LIST) do
        if vmrContains(vurl, item) then
            return false
        end
    end
    return true
end

local function parse_arch(vurl)
    if vmrContains(vurl, "arm64") then
        return "arm64"
    end
    if vmrContains(vurl, "-x64") then
        return "amd64"
    end
    return ""
end

local function parse_os(vurl)
    if vmrContains(vurl, "linux") then
        return "linux"
    end
    if vmrContains(vurl, "-win-") then
        return "windows"
    end
    if vmrContains(vurl, "osx") then
        return "darwin"
    end
    return ""
end

local function fetch_version(vl, vurl, vstr)
    local resp = vmrGetResponse(vurl, 180, {})
    local link = vmrAttr(vmrInitSelection(resp, "a#directLink"), "href")
    local sha = vmrAttr(vmrInitSelection(resp, "input#checksum"), "value")

    local arch = parse_arch(link)
    local os_name = parse_os(link)
    if arch == "" or os_name == "" then
        return
    end

    vmrAddItem(vl, vstr, {
        url = link,
        arch = arch,
        os = os_name,
        sum = sha,
        sum_type = (sha ~= "") and "sha512" or "",
        size = 0,
        installer = vmrInstallerUnarchiver,
        lts = "",
        extra = "",
    })
end

function crawl()
    local vl = vmrNewVersionList()

    local resp = vmrGetResponse(DOWNLOAD_URL, 180, {})
    local version_urls = {}
    vmrEach(vmrInitSelection(resp, "div#supported-versions-table table a"), function(_, anchor)
        local vurl = vmrAttr(anchor, "href")
        if vurl ~= "" then
            if not vmrContains(vurl, HOST) then
                vurl = vmrUrlJoin(HOST, vurl)
            end
            table.insert(version_urls, vurl)
        end
    end)

    for _, vurl in ipairs(version_urls) do
        local page = vmrGetResponse(vurl, 180, {})
        vmrEach(vmrInitSelection(page, "div.download-panel div table"), function(_, table_sel)
            local info = vmrAttr(vmrFind(table_sel, "caption"), "id")
            local parts, n = vmrSplit(info, "-sdk-")
            if n >= 2 then
                local vstr = parts[n]
                vmrEach(vmrFind(table_sel, "a"), function(_, anchor)
                    local link = vmrAttr(anchor, "href")
                    if filter_url(link) then
                        if not vmrContains(link, HOST) then
                            link = vmrUrlJoin(HOST, link)
                        end
                        fetch_version(vl, link, vstr)
                    end
                end)
            end
        end)
    end

    return vl
end
