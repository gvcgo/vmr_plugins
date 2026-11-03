-- git-win: live GitHub Release crawl (ported from vcollector gh/tools/git_win.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "git-win"
sdk_name = "git-win"
plugin_version = "0.1"
homepage = "https://git-scm.com/"

ic = C.installer({
    flag_files = { windows = { "bin", "cmd", "usr" }, linux = {}, darwin = {} },
    binary_dirs = {
        windows = { { "bin" }, { "usr", "bin" }, { "cmd" }, { "mingw64", "bin" } },
        linux = {},
        darwin = {},
    },
})

function crawl()
    return C.github({
        repo = "git-for-windows/git",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        include = { prefix = { "PortableGit-" } },
        os_parser = function()
            return "windows"
        end,
        arch = { { "-64-bit", "amd64" } },
        installer = vmrInstallerUnarchiver,
    })
end
