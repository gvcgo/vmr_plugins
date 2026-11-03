-- flutter: live crawl of the per-platform Flutter release manifests
-- (ported from vcollector official/flutter.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "flutter"
sdk_name = "flutter"
plugin_version = "0.1"
homepage = "https://flutter.dev/"

ic = C.installer({
    flag_files = {
        windows = { "README.md", "LICENSE", "CODEOWNERS" },
        darwin = { "README.md", "LICENSE", "CODEOWNERS" },
        linux = { "README.md", "LICENSE", "CODEOWNERS" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local RELEASES_URL = "https://storage.googleapis.com/flutter_infra_release/releases/releases_%s.json"
local PLATFORMS = {
    { "linux", "linux" },
    { "macos", "darwin" },
    { "windows", "windows" },
}
local ARCH_MAP = { x64 = "amd64", arm64 = "arm64" }

function crawl()
    local vl = vmrNewVersionList()

    for _, platform in ipairs(PLATFORMS) do
        local resp = vmrGetResponse(vmrSprintf(RELEASES_URL, { platform[1] }), 300, {})
        local root = vmrInitGJson(resp)
        local base = vmrGetString(root, "base_url")

        vmrSliceEach(root, "releases", function(_, release)
            local arch = ARCH_MAP[vmrGetString(release, "dart_sdk_arch")]
            if arch then
                local sum = vmrGetString(release, "sha256")
                vmrAddItem(vl, vmrGetString(release, "version"), {
                    url = vmrUrlJoin(base, vmrGetString(release, "archive")),
                    arch = arch,
                    os = platform[2],
                    sum = sum,
                    sum_type = (sum ~= "") and "sha256" or "",
                    size = 0,
                    installer = vmrInstallerUnarchiver,
                    lts = "",
                    extra = "",
                })
            end
        end)
    end

    return vl
end
