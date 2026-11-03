-- served: live GitHub Release crawl (ported from vcollector gh/lsp/dlang.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "served"
sdk_name = "served"
plugin_version = "0.1"
homepage = "https://github.com/Pure-D/serve-d"

ic = C.installer({
    flag_files = {
        windows = { "serve-d.exe" },
        darwin = { "serve-d" },
        linux = { "serve-d" },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "Pure-D/serve-d",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        exclude = {
            suffix = { ".tar.xz", "-x86.zip" },
        },
        os = {
            { "-osx", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "-x86_64", "amd64" },
            { "-arm64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
