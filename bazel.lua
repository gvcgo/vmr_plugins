-- bazel: live GitHub Release crawl (ported from vcollector gh/tools/bazel.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "bazel"
sdk_name = "bazel"
plugin_version = "0.1"
homepage = "https://github.com/bazelbuild/bazel"

ic = C.installer({
    flag_files = { windows = { "bazel.exe" }, linux = { "bazel" }, darwin = { "bazel" } },
    flag_dir_excepted = true,
    binary_rename = { name_flag = "bazel", rename_to = "bazel" },
})

function crawl()
    return C.github({
        repo = "bazelbuild/bazel",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        include = { contains = { "nojdk" } },
        exclude = { suffix = { ".sha256", ".sig", ".zip", ".sh" } },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "-x86_64", "amd64" }, { "-arm64", "arm64" } },
        installer = vmrInstallerExecutable,
    })
end
