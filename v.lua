-- v: live GitHub Release crawl (ported from vcollector gh/lans/vlang.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "v"
sdk_name = "v"
plugin_version = "0.1"
homepage = "https://vlang.io/"

ic = C.installer({
    flag_files = {
        windows = { "cmd", "v.exe" },
        darwin = { "cmd", "v" },
        linux = { "cmd", "v" },
    },
    binary_dirs = {
        windows = { {}, { "cmd", "tools" } },
        darwin = { {}, { "cmd", "tools" } },
        linux = { {}, { "cmd", "tools" } },
    },
})

function crawl()
    return C.github({
        repo = "vlang/v",
        tag_filter = function(tag)
            if vmrRegexpFindString("\\d+(\\.\\d+){2}", tag) ~= "" then
                return true
            end
            return vmrHasPrefix(tag, "weekly.")
        end,
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        os = {
            { "macos", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch_parser = function(name)
            if vmrContains(name, "arm64") then
                return "arm64"
            end
            return "amd64"
        end,
        installer = vmrInstallerUnarchiver,
    })
end
