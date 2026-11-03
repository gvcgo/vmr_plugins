-- protoc: live GitHub Release crawl (ported from vcollector gh/tools/protoc.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "protoc"
sdk_name = "protoc"
plugin_version = "0.1"
homepage = "https://protobuf.dev/"

ic = C.installer({
    flag_files = { windows = { "bin" }, linux = { "bin" }, darwin = { "bin" } },
    binary_dirs = { windows = { { "bin" } }, linux = { { "bin" } }, darwin = { { "bin" } } },
})

function crawl()
    return C.github({
        repo = "protocolbuffers/protobuf",
        tag_regex = "v\\d+(\\.\\d+){1}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        exclude = { prefix = { "protobuf-" } },
        os = { { "-osx", "darwin" }, { "linux", "linux" }, { "-win", "windows" } },
        arch = { { "-x86_64", "amd64" }, { "-win64", "amd64" }, { "-aarch_64", "arm64" } },
        installer = vmrInstallerUnarchiver,
    })
end
