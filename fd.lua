-- fd: live GitHub Release crawl (ported from vcollector gh/tools/fd.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "fd"
sdk_name = "fd"
plugin_version = "0.1"
homepage = "https://github.com/sharkdp/fd"

ic = C.installer({
    flag_files = {
        windows = { "fd.1", "README.md" },
        linux = { "fd.1", "README.md" },
        darwin = { "fd.1", "README.md" },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "sharkdp/fd",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".deb", "-linux-musl.tar.gz", "-windows-msvc.zip" } },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "-x86_64", "amd64" }, { "-aarch64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
