-- crystal: live GitHub Release crawl (ported from vcollector gh/lans/crystal.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "crystal"
sdk_name = "crystal"
plugin_version = "0.1"
homepage = "https://crystal-lang.org/"

ic = C.installer({
    flag_files = {
        windows = { "lib", "crystal.exe" },
        darwin = { "bin", "src" },
        linux = { "bin", "lib" },
    },
    binary_dirs = {
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

function crawl()
    return C.github({
        repo = "crystal-lang/crystal",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = {
            suffix = { ".pkg", "-linux-x86_64.tar.gz", ".exe", ".docs.tar.gz" },
        },
        os = {
            { "darwin", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "x86_64", "amd64" },
            { "universal", "any" },
            { "aarch64", "arm64" },
            { "arm64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
