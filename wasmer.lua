-- wasmer: live GitHub Release crawl (ported from vcollector gh/tools/wasmer.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "wasmer"
sdk_name = "wasmer"
plugin_version = "0.1"
homepage = "https://wasmer.io/"

ic = C.installer({
    flag_files = { windows = { "bin" }, linux = { "bin" }, darwin = { "bin" } },
    binary_dirs = { windows = { { "bin" } }, linux = { { "bin" } }, darwin = { { "bin" } } },
})

function crawl()
    return C.github({
        repo = "wasmerio/wasmer",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { contains = { "-musl", "-gnu64" }, suffix = { ".exe" } },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = {
            { "-x86_64", "amd64" },
            { "-amd64", "amd64" },
            { "-aarch64", "arm64" },
            { "-arm64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
