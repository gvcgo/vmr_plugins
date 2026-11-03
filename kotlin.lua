-- kotlin: live GitHub Release crawl (ported from vcollector gh/lans/kotlin.go).
--
-- Two passes over the same repository, merged:
--   1. platform archives (`kotlin-native-image-<os>-<arch>-<version>.tar.gz|zip`) named
--      `native-<version>`;
--   2. the cross-platform compiler archives (`kotlin-compiler-*`), OS/arch `any`.
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "kotlin"
sdk_name = "kotlin"
plugin_version = "0.1"
homepage = "https://kotlinlang.org/"

ic = C.installer({
    flag_files = {
        windows = { "bin" },
        darwin = { "bin" },
        linux = { "bin" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local function file_filter(name)
    if vmrHasPrefix(name, "maven-") then
        return false
    end
    if vmrHasSuffix(name, ".sha256") or vmrHasSuffix(name, ".json") then
        return false
    end
    return true
end

local function tag_version(tag)
    local v = vmrRegexpFindString("v\\d+(\\.\\d+){2}", tag)
    if v == "" then
        return ""
    end
    return vmrTrimPrefix(v, "v")
end

function crawl()
    local native = C.github({
        repo = "JetBrains/kotlin",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            local v = tag_version(tag)
            if v == "" then
                return ""
            end
            return "native-" .. v
        end,
        file_filter = file_filter,
        os = {
            { "macos", "darwin" },
            { "linux", "linux" },
            { "windows", "windows" },
        },
        arch = {
            { "-x86_64", "amd64" },
            { "-aarch64", "arm64" },
        },
        installer = vmrInstallerUnarchiver,
    })

    local compiler = C.github({
        repo = "JetBrains/kotlin",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = tag_version,
        file_filter = file_filter,
        os_parser = function(name)
            if vmrContains(name, "kotlin-compiler-") then
                return "any"
            end
            return ""
        end,
        arch_parser = function(name)
            if vmrContains(name, "kotlin-compiler-") then
                return "any"
            end
            return ""
        end,
        installer = vmrInstallerUnarchiver,
    })

    return C.merge(native, compiler)
end
