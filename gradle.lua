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
    local headings = vmrInitSelection(resp, "h3.u-text-with-icon")
    -- The checksum list is the next sibling <ul> of each heading; both document-level lists keep
    -- the same order, so heading i pairs with list i.
    local lists = vmrInitSelection(resp, "h3.u-text-with-icon + ul")

    vmrEach(headings, function(index, heading)
        local vstr = vmrTrimSpace(vmrText(vmrEq(vmrFind(heading, "span"), 1)))
        -- Upstream used to publish "vX.Y.Z"; the checksum page now lists the bare version.
        if vmrHasPrefix(vstr, "v") then
            vstr = vmrTrimPrefix(vstr, "v")
        end
        if vstr ~= "" and vstr ~= "0.7" then
            local checksum = vmrTrimSpace(
                vmrText(vmrFind(vmrEq(vmrFind(vmrEq(lists, index), "li"), 1), "code"))
            )
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
