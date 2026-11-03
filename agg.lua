-- agg: live GitHub Release crawl (ported from vcollector gh/tools/agg.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "agg"
sdk_name = "agg"
plugin_version = "0.1"
homepage = "https://github.com/asciinema/agg"

ic = C.installer({
    flag_files = { windows = { "agg.exe" }, linux = { "agg" }, darwin = { "agg" } },
    flag_dir_excepted = true,
    binary_rename = { name_flag = "agg", rename_to = "agg" },
})

function crawl()
    return C.github({
        repo = "asciinema/agg",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { "-linux-gnu" } },
        os = { { "apple", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "-x86_64", "amd64" }, { "-aarch64", "arm64" }, { "-arm64", "arm64" } },
        installer = vmrInstallerExecutable,
    })
end
