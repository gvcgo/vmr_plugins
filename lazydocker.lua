-- lazydocker: live GitHub Release crawl (ported from vcollector gh/tools/lazydocker.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "lazydocker"
sdk_name = "lazydocker"
plugin_version = "0.1"
homepage = "https://github.com/jesseduffield/lazydocker"

ic = C.installer({
    flag_files = {
        windows = { "README.md", "LICENSE" },
        linux = { "README.md", "LICENSE" },
        darwin = { "README.md", "LICENSE" },
    },
    flag_dir_excepted = true,
})

local name_os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } }

function crawl()
    return C.github({
        repo = "jesseduffield/lazydocker",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".txt" } },
        os_parser = function(name)
            return C.lookup(vmrToLower(name), name_os)
        end,
        arch = { { "x86_64", "amd64" }, { "arm64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
