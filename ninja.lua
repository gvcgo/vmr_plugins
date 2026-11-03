-- ninja: live GitHub Release crawl (ported from vcollector gh/tools/ninja.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "ninja"
sdk_name = "ninja"
plugin_version = "0.1"
homepage = "https://ninja-build.org/"

ic = C.installer({
    flag_files = { windows = { "ninja.exe" }, linux = { "ninja" }, darwin = { "ninja" } },
})

function crawl()
    return C.github({
        repo = "ninja-build/ninja",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        os = { { "mac", "darwin" }, { "linux", "linux" }, { "-win", "windows" } },
        arch_parser = function(name)
            if vmrContains(name, "arm64") or vmrContains(name, "aarch64") then
                return "arm64"
            end
            if vmrContains(name, "mac") then
                return "any"
            end
            return "amd64"
        end,
        installer = vmrInstallerUnarchiver,
    })
end
