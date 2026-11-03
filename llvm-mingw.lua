-- llvm-mingw: live GitHub Release crawl (ported from vcollector gh/lans/llvm_mingw.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "llvm-mingw"
sdk_name = "llvm-mingw"
plugin_version = "0.1"
homepage = "https://github.com/mstorsjo/llvm-mingw"

ic = C.installer({
    flag_files = {
        windows = { "bin", "lib", "include" },
        darwin = { "bin", "lib", "include" },
        linux = { "bin", "lib", "include" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local function file_filter(name)
    if vmrContains(name, "-i686") then
        return false
    end
    if vmrContains(name, "-msvcrt-ubuntu") then
        return false
    end
    if vmrContains(name, "-ucrt-") and not vmrContains(name, "ubuntu") and not vmrContains(name, "macos") then
        return false
    end
    return true
end

function crawl()
    return C.github({
        repo = "mstorsjo/llvm-mingw",
        tag_filter = function(tag)
            return vmrRegexpFindString("\\d{8}", tag) ~= ""
        end,
        version_parser = function(tag)
            return vmrRegexpFindString("\\d{8}", tag)
        end,
        file_filter = file_filter,
        os_parser = function(name)
            if vmrContains(name, "-ucrt-ubuntu") then
                return "linux"
            end
            if vmrContains(name, "-ucrt-macos") then
                return "darwin"
            end
            return "windows"
        end,
        arch = {
            { "-x86_64", "amd64" },
            { "-aarch64", "arm64" },
            { "-universal", "any" },
        },
        installer = vmrInstallerUnarchiver,
    })
end
