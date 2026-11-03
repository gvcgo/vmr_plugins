-- wasmedge: live GitHub Release crawl (ported from vcollector gh/tools/wasmedge.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "wasmedge"
sdk_name = "wasmedge"
plugin_version = "0.1"
homepage = "https://wasmedge.org/"

ic = C.installer({
    flag_files = { windows = { "bin" }, linux = { "bin" }, darwin = { "bin" } },
    binary_dirs = { windows = { { "bin" } }, linux = { { "bin" } }, darwin = { { "bin" } } },
})

function crawl()
    return C.github({
        repo = "WasmEdge/WasmEdge",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = {
            prefix = { "sbom" },
            contains = { "-manylinux2014", "-manylinux2010", "-msvc", "-plugin-", "-runtime-only-" },
            suffix = { "static.tar.gz", ".exe", ".rpm", ".tar.xz", ".src.tar.gz", ".msi" },
        },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = {
            { "x86_64", "amd64" },
            { "windows", "amd64" },
            { "amd64", "amd64" },
            { "aarch64", "arm64" },
            { "arm64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
