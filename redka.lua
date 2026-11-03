-- redka: live GitHub Release crawl (ported from vcollector gh/tools/redka.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "redka"
sdk_name = "redka"
plugin_version = "0.1"
homepage = "https://github.com/nalgeon/redka"

ic = C.installer({
    flag_files = { windows = { "redka.exe" }, linux = { "redka" }, darwin = { "redka" } },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "nalgeon/redka",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".txt" } },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "amd64", "amd64" }, { "arm64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
