-- asciinema (acast): live GitHub Release crawl (ported from vcollector gh/tools/asciinema.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "asciinema"
sdk_name = "acast"
plugin_version = "0.1"
homepage = "https://asciinema.org/"

ic = C.installer({
    flag_files = { windows = { "acast.exe" }, linux = { "acast" }, darwin = { "acast" } },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "gvcgo/asciinema",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "amd64", "amd64" }, { "arm64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
