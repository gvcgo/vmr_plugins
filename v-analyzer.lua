-- v-analyzer: live GitHub Release crawl (ported from vcollector gh/lsp/vlang.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "v-analyzer"
sdk_name = "v-analyzer"
plugin_version = "0.1"
homepage = "https://github.com/vlang/v-analyzer"

ic = C.installer({
    flag_files = {
        windows = { "v-analyzer.exe" },
        darwin = { "v-analyzer" },
        linux = { "v-analyzer" },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "vlang/v-analyzer",
        tag_filter = function(tag)
            if vmrRegexpFindString("v\\d+(\\.\\d+){2}", tag) ~= "" then
                return true
            end
            return vmrRegexpFindString("nightly", tag) ~= ""
        end,
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = {
            suffix = { "debug.zip", "dev.zip", ".vsix" },
        },
        os = {
            { "darwin", "darwin" },
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
