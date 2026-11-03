-- typst-lsp: live GitHub Release crawl (ported from vcollector gh/lsp/typst.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "typst-lsp"
sdk_name = "typst-lsp"
plugin_version = "0.1"
homepage = "https://github.com/nvarner/typst-lsp"

ic = C.installer({
    flag_files = {
        windows = { "typst-lsp.exe" },
        darwin = { "typst-lsp" },
        linux = { "typst-lsp" },
    },
    flag_dir_excepted = true,
    binary_rename = { name_flag = "typst-lsp", rename_to = "typst-lsp" },
})

function crawl()
    return C.github({
        repo = "nvarner/typst-lsp",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_regex = "v\\d+(\\.\\d+){2}",
        version_prefix = "v",
        exclude = {
            suffix = { "linux-gnu", "-linux-gnueabihf", ".toml", ".png", ".md", ".vsix" },
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
        installer = vmrInstallerExecutable,
    })
end
