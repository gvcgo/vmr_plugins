-- gsudo: live GitHub Release crawl (ported from vcollector gh/tools/gsudo_win.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "gsudo"
sdk_name = "gsudo"
plugin_version = "0.1"
homepage = "https://gerardog.github.io/gsudo/"

ic = C.installer({
    flag_files = { windows = { "x86", "x64", "arm64" }, linux = {}, darwin = {} },
    binary_dirs = { windows = { { "net46-AnyCpu" } }, linux = {}, darwin = {} },
})

function crawl()
    return C.github({
        repo = "gerardog/gsudo",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        include = { suffix = { "gsudo.portable.zip" } },
        os_parser = function()
            return "windows"
        end,
        arch_parser = function()
            return "amd64"
        end,
        installer = vmrInstallerUnarchiver,
    })
end
