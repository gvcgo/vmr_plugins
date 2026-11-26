-- gradle: live crawl of https://gradle.org/release-checksums/
-- (ported from vcollector official/gradle.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "gradle"
sdk_name = "gradle"
plugin_version = "0.1"
homepage = "https://gradle.org/"

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

local DOWNLOAD_URL = "https://gradle.org/release-checksums/"
local DIST_URL = "https://services.gradle.org/distributions/gradle-%s-all.zip"

function crawl()
    local vl = vmrNewVersionList()
    local resp = vmrGetResponse(DOWNLOAD_URL, 300, {})
    vmrEach(vmrInitSelection(resp, "div.checksum-row"), function(_, row)
        local vstr = vmrTrimSpace(vmrAttr(row, "data-version"))
        if vstr ~= "" and vstr ~= "0.7" then
            local checksum = ""
            vmrEach(vmrFind(row, "dl.checksum-row__hashes div"), function(_, entry)
                if vmrContains(vmrText(vmrFind(entry, "dt")), "Complete (-all)") then
                    checksum = vmrTrimSpace(vmrText(vmrFind(entry, "dd code")))
                end
            end)
            if checksum == "" then
                return
            end
            vmrAddItem(vl, vstr, {
                url = vmrSprintf(DIST_URL, { vstr }),
                arch = "any",
                os = "any",
                sum = checksum,
                sum_type = "sha256",
                size = 0,
                installer = vmrInstallerUnarchiver,
                lts = "",
                extra = "",
            })
        end
    end)

    return vl
end
