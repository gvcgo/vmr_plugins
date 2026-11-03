-- tree-sitter: live GitHub Release crawl (ported from vcollector gh/tools/tree_sitter.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "tree-sitter"
sdk_name = "tree-sitter"
plugin_version = "0.1"
homepage = "https://tree-sitter.github.io/tree-sitter/"

ic = C.installer({
    flag_files = {
        windows = { "tree-sitter.exe" },
        linux = { "tree-sitter" },
        darwin = { "tree-sitter" },
    },
    flag_dir_excepted = true,
    binary_rename = { name_flag = "tree-sitter", rename_to = "tree-sitter" },
})

function crawl()
    return C.github({
        repo = "tree-sitter/tree-sitter",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".wasm", ".js" } },
        os = { { "macos", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "-x64", "amd64" }, { "-arm64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
