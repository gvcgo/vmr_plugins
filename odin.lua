-- odin: live GitHub Release crawl (ported from vcollector gh/lans/odin.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "odin"
sdk_name = "odin"
plugin_version = "0.1"
homepage = "http://odin-lang.org/"

ic = C.installer({
    flag_files = {
        windows = { "LICENSE", "base" },
        darwin = { "LICENSE", "base" },
        linux = { "LICENSE", "base" },
    },
})

function crawl()
    return C.github({
        repo = "odin-lang/Odin",
        tag_filter = function(tag)
            if vmrRegexpFindString("v\\d+(\\.\\d+){2}", tag) ~= "" then
                return true
            end
            return vmrHasPrefix(tag, "dev-")
        end,
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        os = {
            { "macos", "darwin" },
            { "ubuntu", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "-amd64", "amd64" },
            { "-arm64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
