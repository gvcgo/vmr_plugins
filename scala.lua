-- scala: live GitHub Release crawl of scala/scala3 (Scala 3) + scala/scala (Scala 2),
-- no coursier dependency.
--
-- Layouts handled here:
--   * Scala 2 (scala/scala): universal `scala-<ver>.tgz` (unix) / `.zip` (windows);
--   * Scala 3 LTS/3.3.x: universal `scala3-<ver>.tar.gz` (unix) / `.zip` (windows);
--   * Scala 3 3.10+: per-platform `scala3-<ver>-<arch>-<os>.tar.gz|.zip`.
-- Archives extract to `<root>/` containing `bin/` and `lib/`.
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "scala"
sdk_name = "scala"
plugin_version = "0.1"
homepage = "https://www.scala-lang.org/"

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

local function crawl_scala3()
    return C.github({
        repo = "scala/scala3",
        tag_filter = function(tag)
            -- Stable releases only: `3.3.9`, `3.10.0`; skip RCs/nightlies.
            return vmrRegexpFindString("^[0-9]+\\.[0-9]+\\.[0-9]+$", tag) ~= ""
        end,
        version_parser = function(tag)
            return tag
        end,
        file_filter = function(name)
            return vmrHasSuffix(name, ".tar.gz") or vmrHasSuffix(name, ".zip")
        end,
        os_parser = function(name)
            if vmrContains(name, "windows") then
                return "windows"
            end
            if vmrContains(name, "apple-darwin") then
                return "darwin"
            end
            if vmrContains(name, "pc-linux") then
                return "linux"
            end
            -- Universal archives: tar.gz for unix, zip for windows.
            if vmrHasSuffix(name, ".zip") then
                return "windows"
            end
            return "unix"
        end,
        arch_parser = function(name)
            if vmrContains(name, "aarch64") or vmrContains(name, "arm64") then
                return "arm64"
            end
            if vmrContains(name, "x86_64") or vmrContains(name, "amd64") then
                return "amd64"
            end
            return "any"
        end,
        installer = vmrInstallerUnarchiver,
    })
end

local function crawl_scala2()
    return C.github({
        repo = "scala/scala",
        tag_filter = function(tag)
            -- Stable 2.12/2.13 releases only (`v2.13.18`).
            return vmrRegexpFindString("^v2\\.[0-9]+\\.[0-9]+$", tag) ~= ""
        end,
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        file_filter = function(name)
            if vmrContains(name, "docs") then
                return false
            end
            return vmrHasSuffix(name, ".tgz") or vmrHasSuffix(name, ".zip")
        end,
        os_parser = function(name)
            if vmrHasSuffix(name, ".zip") then
                return "windows"
            end
            return "unix"
        end,
        arch_parser = function(_)
            return "any"
        end,
        installer = vmrInstallerUnarchiver,
    })
end

function crawl()
    return vmrMergeVersionList(crawl_scala3(), crawl_scala2())
end
