-- goplus: live GitHub Release crawl (ported from vcollector gh/lans/goplus.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "goplus"
sdk_name = "goplus"
plugin_version = "0.1"
homepage = "https://goplus.org/"

ic = C.installer({
    flag_files = {
        windows = { "bin" },
        darwin = { "bin" },
        linux = { "bin" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

function crawl()
    return C.github({
        repo = "goplus/gop",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        exclude = {
            suffix = { ".txt", ".deb", ".rpm" },
        },
        os = {
            { "darwin", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "-amd64", "amd64" },
            { "-arm64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
