-- julia: live crawl of https://julialang-s3.julialang.org/bin/versions.json
-- (ported from vcollector official/julia.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "julia"
sdk_name = "julia"
plugin_version = "0.1"
homepage = "https://julialang.org/"

ic = C.installer({
    flag_files = {
        windows = { "LICENSE.md" },
        darwin = { "LICENSE.md" },
        linux = { "LICENSE.md" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local DOWNLOAD_URL = "https://julialang-s3.julialang.org/bin/versions.json"

local ARCH_MAP = { aarch64 = "arm64", x86_64 = "amd64" }
local OS_MAP = { linux = "linux", mac = "darwin", winnt = "windows" }

function crawl()
    local vl = vmrNewVersionList()
    local resp = vmrGetResponse(DOWNLOAD_URL, 300, {})
    local root = vmrInitGJson(resp)

    vmrMapEach(root, "", function(vstr, entry)
        vmrSliceEach(entry, "files", function(_, file)
            if vmrGetString(file, "kind") ~= "archive" then
                return
            end
            if not vmrContains(vmrGetString(file, "extension"), "tar.gz") then
                return
            end

            local arch = ARCH_MAP[vmrGetString(file, "arch")]
            local os_name = OS_MAP[vmrGetString(file, "os")]
            if not arch or not os_name then
                return
            end

            local sum = vmrGetString(file, "sha256")
            vmrAddItem(vl, vstr, {
                url = vmrGetString(file, "url"),
                arch = arch,
                os = os_name,
                sum = sum,
                sum_type = (sum ~= "") and "sha256" or "",
                size = 0,
                installer = vmrInstallerUnarchiver,
                lts = "",
                extra = "",
            })
        end)
    end)

    return vl
end
