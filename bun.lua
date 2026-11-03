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
    return C.github({
        repo = "oven-sh/bun",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        exclude = {
            contains = { "profile", "baseline" },
            suffix = { ".txt", ".txt.asc" },
        },
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
