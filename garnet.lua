-- garnet: live GitHub Release crawl (ported from vcollector gh/tools/garnet.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "garnet"
sdk_name = "garnet"
plugin_version = "0.1"
homepage = "https://github.com/microsoft/garnet"

ic = C.installer({
    flag_files = {
        windows = { "GarnetServer.exe" },
        linux = { "GarnetServer" },
        darwin = { "GarnetServer" },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "microsoft/garnet",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".nupkg", "portable.7z" } },
        os = { { "osx", "darwin" }, { "linux", "linux" }, { "win-", "windows" } },
        arch = { { "x64", "amd64" }, { "arm64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
