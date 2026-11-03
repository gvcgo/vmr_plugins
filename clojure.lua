-- clojure: live GitHub Release crawl (ported from vcollector gh/lans/clojure.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "clojure"
sdk_name = "clojure"
plugin_version = "0.1"
homepage = "https://clojure.org/"

ic = C.installer({
    flag_files = {
        windows = { "deps.edn", "example-deps.edn" },
        darwin = { "deps.edn", "example-deps.edn" },
        linux = { "deps.edn", "example-deps.edn" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "clojure/brew-install",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        file_filter = function(name)
            if vmrHasSuffix(name, ".zip") then
                return true
            end
            return vmrHasPrefix(name, "clojure") and vmrHasSuffix(name, ".tar.gz")
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
