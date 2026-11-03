-- neovim: live GitHub Release crawl (ported from vcollector gh/tools/neovim.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "neovim"
sdk_name = "neovim"
plugin_version = "0.1"
homepage = "https://neovim.io/"

ic = C.installer({
    flag_files = { windows = { "bin", "share" }, linux = { "bin", "share" }, darwin = { "bin", "share" } },
    binary_dirs = { windows = { { "bin" } }, linux = { { "bin" } }, darwin = { { "bin" } } },
})

function crawl()
    return C.github({
        repo = "neovim/neovim",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { suffix = { ".sha256sum", ".msi", ".appimage", ".zsync" } },
        os_parser = function(name)
            if vmrContains(name, "macos") then
                return "darwin"
            end
            if vmrContains(name, "linux") then
                return "linux"
            end
            if vmrContains(name, "-win") then
                return "windows"
            end
            return ""
        end,
        arch_parser = function(name)
            if name == "nvim-macos.tar.gz" then
                return "any"
            end
            if vmrContains(name, "linux64") or vmrContains(name, "win64") or vmrContains(name, "x86_64") then
                return "amd64"
            end
            if vmrContains(name, "arm64") then
                -- upstream vcollector returns the literal "amr64" here; kept for parity.
                return "amr64"
            end
            return ""
        end,
        installer = vmrInstallerUnarchiver,
    })
end
