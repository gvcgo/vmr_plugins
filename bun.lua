-- bun: live GitHub Release crawl (ported from vcollector gh/lans/bun.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "bun"
sdk_name = "bun"
plugin_version = "0.1"
homepage = "https://bun.sh/"

ic = C.installer({
    flag_files = {
        windows = { "bun.exe" },
        darwin = { "bun" },
        linux = { "bun" },
    },
    flag_dir_excepted = true,
})

function crawl()
    local has_avx2 = vmrHasAvx2 and vmrHasAvx2()
    return C.github({
        repo = "oven-sh/bun",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        file_filter = function(name)
            if vmrContains(name, "-x64") then
                if has_avx2 then
                    return name == "bun-darwin-x64.zip" or name == "bun-linux-x64.zip" or name == "bun-windows-x64.zip"
                end
                return name == "bun-darwin-x64-baseline.zip" or name == "bun-linux-x64-baseline.zip" or name == "bun-windows-x64-baseline.zip"
            end
            return name == "bun-darwin-aarch64.zip" or name == "bun-linux-aarch64.zip" or name == "bun-windows-aarch64.zip"
        end,
        os = {
            { "darwin", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "-x64", "amd64" },
            { "-aarch64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end

function postInstall(path, version, item, archive)
    if item.os == "windows" then
        return true
    end
    local bun = vmrFindFile(path, "bun", 3)
    assert(bun ~= "", "bun executable not found")
    assert(vmrChmodExecutable(bun), "failed to make bun executable")
    local bunx = bun .. "x"
    if not vmrFileExists(bunx) then
        assert(vmrSymlink("bun", bunx), "failed to link bunx")
    end
    return true
end
