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

local DOWNLOAD_URL = "https://ziglang.org/download/index.json"
local PLATFORMS = {
    ["x86_64-windows"] = { "windows", "amd64" },
    ["aarch64-windows"] = { "windows", "arm64" },
    ["x86_64-linux"] = { "linux", "amd64" },
    ["aarch64-linux"] = { "linux", "arm64" },
    ["x86_64-macos"] = { "darwin", "amd64" },
    ["aarch64-macos"] = { "darwin", "arm64" },
}

function crawl()
    local vl = vmrNewVersionList()
    local resp = vmrGetResponse(DOWNLOAD_URL, 180, {})
    vmrMapEach(vmrInitGJson(resp), "", function(version, release)
        if version == "master" then
            version = vmrGetString(release, "version")
        end
        vmrMapEach(release, "", function(platform, item)
            local target = PLATFORMS[platform]
            if not target then
                return
            end
            local url = vmrGetString(item, "tarball")
            if url == "" then
                return
            end
            local sum = vmrGetString(item, "shasum")
            vmrAddItem(vl, version, {
                url = url,
                arch = target[2],
                os = target[1],
                sum = sum,
                sum_type = sum ~= "" and "sha256" or "",
                size = vmrGetInt(item, "size"),
                installer = vmrInstallerUnarchiver,
                lts = "",
                extra = "",
            })
        end)
    end)

    return vl
end

function postInstall(path, version, item, archive)
    if item.os ~= "windows" then
        local executable = vmrFindFile(path, "zig", 3)
        assert(executable ~= "", "zig executable not found")
        assert(vmrChmodExecutable(executable), "failed to make zig executable")
    end
    return true
end
