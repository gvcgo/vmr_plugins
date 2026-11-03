-- typst-preview: live GitHub Release crawl (ported from vcollector gh/tools/typst_preview.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "typst-preview"
sdk_name = "typst-preview"
plugin_version = "0.1"
homepage = "https://enter-tainer.github.io/typst-preview/"

ic = C.installer({
    flag_files = {
        windows = { "typst-preview.exe" },
        linux = { "typst-preview" },
        darwin = { "typst-preview" },
    },
    flag_dir_excepted = true,
    binary_rename = { name_flag = "typst-preview", rename_to = "typst-preview" },
})

function crawl()
    return C.github({
        repo = "Enter-tainer/typst-preview",
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
