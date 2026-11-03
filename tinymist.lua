-- tinymist: live GitHub Release crawl (ported from vcollector gh/tools/tinymist.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "tinymist"
sdk_name = "tinymist"
plugin_version = "0.1"
homepage = "https://github.com/Myriad-Dreamin/tinymist"

ic = C.installer({
    flag_files = { windows = { "tinymist.exe" }, linux = { "tinymist" }, darwin = { "tinymist" } },
    flag_dir_excepted = true,
    binary_rename = { name_flag = "tinymist", rename_to = "tinymist" },
})

function crawl()
    return C.github({
        repo = "Myriad-Dreamin/tinymist",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".dwarf", ".debug", ".vsix", ".html", ".pdb" } },
        os = { { "darwin", "darwin" }, { "linux", "linux" }, { "-win32", "windows" } },
        arch = { { "-x64", "amd64" }, { "-arm64", "arm64" } },
        installer = vmrInstallerExecutable,
    })
end
