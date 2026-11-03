-- cmake: live GitHub Release crawl (ported from vcollector gh/tools/cmake.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "cmake"
sdk_name = "cmake"
plugin_version = "0.1"
homepage = "https://cmake.org/"

ic = C.installer({
    flag_files = { windows = { "bin", "share" }, linux = { "bin", "share" }, darwin = { "bin", "share" } },
    binary_dirs = { windows = { { "bin" } }, linux = { { "bin" } }, darwin = { { "bin" } } },
})

function crawl()
    return C.github({
        repo = "Kitware/CMake",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = {
            contains = { "macos10.10-" },
            suffix = { ".json", ".sh", ".dmg", ".txt", ".asc", ".msi" },
        },
        os = { { "macos", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = {
            { "-x86_64", "amd64" },
            { "-aarch64", "arm64" },
            { "-arm64", "arm64" },
            { "-universal", "any" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
