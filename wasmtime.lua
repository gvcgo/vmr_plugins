-- wasmtime: live GitHub Release crawl (ported from vcollector gh/tools/wasmtime.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "wasmtime"
sdk_name = "wasmtime"
plugin_version = "0.1"
homepage = "https://wasmtime.dev/"

ic = C.installer({
    flag_files = {
        windows = { "wasmtime.exe", "LICENSE" },
        linux = { "wasmtime", "LICENSE" },
        darwin = { "wasmtime", "LICENSE" },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "bytecodealliance/wasmtime",
        tag_regex = "v\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { contains = { "-c-api" }, suffix = { ".wasm", ".h", ".msi" } },
        os = { { "macos", "darwin" }, { "linux", "linux" }, { "windows", "windows" } },
        arch = { { "-x86_64", "amd64" }, { "-aarch64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
