-- node: live crawl of https://nodejs.org/dist/index.json (ported from vcollector official/node.go).
--
-- vcollector downloaded every release's SHASUMS256.txt to discover asset names. That is fine for
-- a batch job but far too slow for an interactive version manager. The index already advertises
-- the files present for each release (`files`), so we build the same canonical URLs directly and
-- leave checksums empty (they are optional for installation).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "node"
sdk_name = "node"
plugin_version = "0.1"
homepage = "https://nodejs.org/en"

ic = C.installer({
    flag_files = {
        windows = { "LICENSE", "README.md" },
        darwin = { "LICENSE", "README.md" },
        linux = { "LICENSE", "README.md" },
    },
    binary_dirs = {
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local DOWNLOAD_URL = "https://nodejs.org/download/release"

local function filter_year(date)
    local parts = vmrSplit(date, "-")
    local year = tonumber(parts[1] or "") or 0
    return year > 2017
end

local function add_item(vl, vname, fname, os_name, arch, is_lts)
    vmrAddItem(vl, vmrTrimPrefix(vname, "v"), {
        url = DOWNLOAD_URL .. "/" .. vname .. "/" .. fname,
        arch = arch,
        os = os_name,
        sum = "",
        sum_type = "",
        size = 0,
        installer = vmrInstallerUnarchiver,
        lts = is_lts and "1" or "",
        extra = "",
    })
end

-- Adds the assets that the upstream crawler would discover in SHASUMS256.txt.
local function add_release(vl, vname, files, is_lts)
    local vstr = vmrTrimPrefix(vname, "v")

    for _, f in ipairs(files) do
        local prefix = "node-" .. vname .. "-"
        if f == "linux-x64" then
            add_item(vl, vname, prefix .. "linux-x64.tar.gz", "linux", "amd64", is_lts)
        elseif f == "linux-arm64" then
            add_item(vl, vname, prefix .. "linux-arm64.tar.gz", "linux", "arm64", is_lts)
        elseif f == "osx-x64-tar" then
            add_item(vl, vname, prefix .. "darwin-x64.tar.gz", "darwin", "amd64", is_lts)
        elseif f == "osx-arm64-tar" then
            add_item(vl, vname, prefix .. "darwin-arm64.tar.gz", "darwin", "arm64", is_lts)
        elseif f == "win-x64-zip" then
            add_item(vl, vname, prefix .. "win-x64.zip", "windows", "amd64", is_lts)
        elseif f == "win-arm64-zip" then
            add_item(vl, vname, prefix .. "win-arm64.zip", "windows", "arm64", is_lts)
        end
    end
end

function crawl()
    local vl = vmrNewVersionList()
    local resp = vmrGetResponse("https://nodejs.org/dist/index.json", 120, {})
    vmrSliceEach(vmrInitGJson(resp), "", function(_, entry)
        local vname = vmrGetString(entry, "version")
        local date = vmrGetString(entry, "date")
        if vname == "" or not filter_year(date) then
            return
        end
        local lts_raw = vmrGetString(entry, "lts")
        local is_lts = lts_raw == "true" or (lts_raw ~= "" and lts_raw ~= "false")

        -- `files` is a JSON array; iterate it through the gjson slice binding.
        local files = {}
        vmrSliceEach(entry, "files", function(_, f)
            files[#files + 1] = vmrGetString(f, "")
        end)
        add_release(vl, vname, files, is_lts)
    end)
    return vl
end
