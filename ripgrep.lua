-- ripgrep: live GitHub Release crawl (ported from vcollector gh/tools/ripgrep.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "ripgrep"
sdk_name = "ripgrep"
plugin_version = "0.1"
homepage = "https://github.com/BurntSushi/ripgrep"

ic = C.installer({
    flag_files = { windows = { "rg.exe" }, linux = { "rg" }, darwin = { "rg" } },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "BurntSushi/ripgrep",
        version_regex = "\\d+(\\.\\d+){2}",
        exclude = {
            contains = { "archive/refs/" },
            suffix = { "-windows-msvc.zip", ".sha256", ".deb" },
        },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "-x86_64", "amd64" }, { "-aarch64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
