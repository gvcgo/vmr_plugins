-- maven: live HTML crawl of the Apache Maven archive (maven-3 and maven-4 trees)
-- (ported from vcollector official/maven.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "maven"
sdk_name = "maven"
plugin_version = "0.1"
homepage = "https://maven.apache.org/"

ic = C.installer({
    flag_files = {
        windows = { "LICENSE" },
        darwin = { "LICENSE" },
        linux = { "LICENSE" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local DOWNLOAD_URL = "https://archive.apache.org/dist/maven"

local function response_text(resp)
    return vmrText(vmrInitSelection(resp, "body"))
end

local function get_sha(sha_url)
    return response_text(vmrGetResponse(sha_url, 120, {}))
end

local function get_versions(vl, durl)
    local resp = vmrGetResponse(durl, 180, {})
    vmrEach(vmrInitSelection(resp, "a"), function(_, anchor)
        local text = vmrText(anchor)
        if not (vmrContains(text, ".") and vmrHasSuffix(text, "/")) then
            return
        end

        local href = vmrAttr(anchor, "href")
        if href == "" then
            return
        end

        local vurl = vmrUrlJoin(vmrUrlJoin(durl, href), "/binaries/")
        local doc = vmrGetResponse(vurl, 180, {})
        vmrEach(vmrInitSelection(doc, "a"), function(_, bin)
            local name = vmrText(bin)
            if not vmrHasSuffix(name, "bin.tar.gz") then
                return
            end

            local bin_href = vmrAttr(bin, "href")
            if bin_href == "" then
                return
            end

            local tar_url = vmrUrlJoin(vurl, bin_href)
            local sum_type = "sha1"
            if vmrContains(durl, "/maven-4/") then
                sum_type = "sha512"
            end

            vmrAddItem(vl, vmrTrim(text, "/"), {
                url = tar_url,
                arch = "any",
                os = "any",
                sum = get_sha(tar_url .. "." .. sum_type),
                sum_type = sum_type,
                size = 0,
                installer = vmrInstallerUnarchiver,
                lts = "",
                extra = text,
            })
        end)
    end)
end

function crawl()
    local vl = vmrNewVersionList()
    get_versions(vl, vmrUrlJoin(DOWNLOAD_URL, "/maven-3/"))
    get_versions(vl, vmrUrlJoin(DOWNLOAD_URL, "/maven-4/"))
    return vl
end
