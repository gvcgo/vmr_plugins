-- groovy: live HTML crawl of the Apache Groovy distribution archive
-- (ported from vcollector official/groovy.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "groovy"
sdk_name = "groovy"
plugin_version = "0.1"
homepage = "http://www.groovy-lang.org/"

ic = C.installer({
    flag_files = {
        windows = { "bin" },
        darwin = { "bin" },
        linux = { "bin" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local DOWNLOAD_URL = "https://archive.apache.org/dist/groovy/"
local VERSION_REGEX = "\\d+(.\\d+){2}"

local function response_text(resp)
    return vmrText(vmrInitSelection(resp, "body"))
end

local function get_sha256(sdk_url)
    return response_text(vmrGetResponse(sdk_url .. ".sha256", 120, {}))
end

local function get_version(vl, vhref)
    local vname = vmrTrim(vhref, "/")
    local durl = vmrSprintf("https://archive.apache.org/dist/groovy/%s/distribution/", { vname })
    local resp = vmrGetResponse(durl, 180, {})

    local sdk_url = ""
    local sha_text = ""
    vmrEach(vmrInitSelection(resp, "a"), function(_, anchor)
        local href = vmrAttr(anchor, "href")
        if vmrContains(href, "-sdk-") and vmrHasSuffix(href, ".zip") then
            sdk_url = vmrUrlJoin(durl, href)
            sha_text = get_sha256(sdk_url)
        end
    end)

    if sdk_url == "" or sha_text == "" then
        return
    end

    local sum = vmrTrimSpace(sha_text)
    local sum_type = "sha256"
    if vmrContains(sum, "apache-groovy-sdk") then
        local parts = vmrSplit(sum, "apache-groovy-sdk")
        sum = vmrTrimSpace(parts[1] or "")
        sum_type = "md5"
    end

    vmrAddItem(vl, vname, {
        url = sdk_url,
        arch = "any",
        os = "any",
        sum = sum,
        sum_type = sum_type,
        size = 0,
        installer = vmrInstallerUnarchiver,
        lts = "",
        extra = "",
    })
end

function crawl()
    local vl = vmrNewVersionList()
    local resp = vmrGetResponse(DOWNLOAD_URL, 180, {})
    vmrEach(vmrInitSelection(resp, "a"), function(_, anchor)
        local href = vmrAttr(anchor, "href")
        if href ~= "" and vmrRegexpFindString(VERSION_REGEX, href) ~= "" then
            get_version(vl, href)
        end
    end)
    return vl
end
