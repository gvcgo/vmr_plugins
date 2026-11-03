-- upx: live GitHub Release crawl (ported from vcollector gh/tools/upx.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "upx"
sdk_name = "upx"
plugin_version = "0.1"
homepage = "https://upx.github.io/"

ic = C.installer({
    flag_files = { windows = { "upx.exe" }, linux = { "upx" }, darwin = { "upx" } },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "upx/upx",
        tag_regex = "v\\d+(\\.\\d+){1}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { contains = { "-docs", "-src" } },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "-win", "windows" } },
        arch = { { "-amd64", "amd64" }, { "-arm64", "arm64" }, { "-win64", "amd64" } },
        installer = vmrInstallerUnarchiver,
    })
end
