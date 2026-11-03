-- fzf: live GitHub Release crawl (ported from vcollector gh/tools/fzf.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "fzf"
sdk_name = "fzf"
plugin_version = "0.1"
homepage = "https://github.com/junegunn/fzf"

ic = C.installer({
    flag_files = { windows = { "fzf.exe" }, linux = { "fzf" }, darwin = { "fzf" } },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "junegunn/fzf",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".txt" } },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "amd64", "amd64" }, { "arm64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
