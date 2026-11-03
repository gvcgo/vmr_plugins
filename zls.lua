-- zls: live GitHub Release crawl (ported from vcollector gh/lsp/zig.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "zls"
sdk_name = "zls"
plugin_version = "0.1"
homepage = "https://github.com/zigtools/zls"

ic = C.installer({
    flag_files = {
        windows = { "README.md" },
        darwin = { "README.md" },
        linux = { "README.md" },
    },
    binary_dirs = {
        windows = { {}, { "bin" } },
        darwin = { {}, { "bin" } },
        linux = { {}, { "bin" } },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "zigtools/zls",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = {
            contains = { "-wasm32", "-x86-" },
            suffix = { ".minisig" },
        },
        os = {
            { "macos", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "x86_64", "amd64" },
            { "aarch64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
