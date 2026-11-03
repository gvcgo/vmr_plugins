-- codon: live GitHub Release crawl (ported from vcollector gh/lans/codon.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "codon"
sdk_name = "codon"
plugin_version = "0.1"
homepage = "https://github.com/exaloop/codon"

ic = C.installer({
    flag_files = {
        windows = { "bin", "lib" },
        darwin = { "bin", "lib" },
        linux = { "bin", "lib" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

function crawl()
    return C.github({
        repo = "exaloop/codon",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        os = {
            { "darwin", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "-x86_64", "amd64" },
            { "arm64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
