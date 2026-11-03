-- github-cli (gh): live GitHub Release crawl (ported from vcollector gh/tools/githubcli.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "github-cli"
sdk_name = "github-cli"
plugin_version = "0.1"
homepage = "https://cli.github.com/"

ic = C.installer({
    flag_files = { windows = { "bin" }, linux = { "bin" }, darwin = { "bin" } },
    binary_dirs = { windows = { { "bin" } }, linux = { { "bin" } }, darwin = { { "bin" } } },
})

function crawl()
    return C.github({
        repo = "cli/cli",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = {
            contains = { "_386" },
            suffix = { "checksums.txt", ".deb", ".rpm", ".msi" },
        },
        os = { { "macOS", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "amd64", "amd64" }, { "arm64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
