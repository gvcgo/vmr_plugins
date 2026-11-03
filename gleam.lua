-- gleam: live GitHub Release crawl (ported from vcollector gh/lans/gleam.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "gleam"
sdk_name = "gleam"
plugin_version = "0.1"
homepage = "https://gleam.run/"

ic = C.installer({
    flag_files = {
        windows = { "gleam.exe" },
        darwin = { "gleam" },
        linux = { "gleam" },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "gleam-lang/gleam",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        exclude = {
            contains = { "-browser" },
            suffix = { ".sha256", ".sha512" },
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
