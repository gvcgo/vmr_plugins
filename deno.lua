-- deno: live GitHub Release crawl (ported from vcollector gh/lans/deno.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "deno"
sdk_name = "deno"
plugin_version = "0.1"
homepage = "https://deno.com/"

ic = C.installer({
    flag_files = {
        windows = { "deno.exe" },
        darwin = { "deno" },
        linux = { "deno" },
    },
})

function crawl()
    return C.github({
        repo = "denoland/deno",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        exclude = {
            contains = { "denort-" },
            suffix = { "src.tar.gz", ".deno.d.ts", ".sha256sum" },
        },
        os = {
            { "darwin", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "-x86_64", "amd64" },
            { "-aarch64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
