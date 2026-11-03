--[[
    Erlang/OTP support for VMR.
    Conda-forge packages plus the official GitHub releases (Windows installers).
    https://github.com/erlang/otp/releases
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "erlang"
sdk_name = "erlang"
plugin_version = "0.1"
homepage = "https://www.erlang.org/"

-- installer config
ic = C.installer({
    flag_files = {
        windows = { "bin", "lib" },
        linux = { "bin", "lib" },
        darwin = { "bin", "lib" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        linux = { { "bin" } },
        darwin = { { "bin" } },
    },
})

-- spider
local function versionParser(tag)
    return vmrTrimPrefix(vmrTrimPrefix(tag, "v"), "OTP-")
end

local function fileFilter(name)
    return vmrHasSuffix(name, ".exe") and vmrContains(name, "win64")
end

local function osParser(_)
    return "windows"
end

local function archParser(_)
    return "amd64"
end

function crawl()
    local vl = C.pixi("erlang")
    local gh = C.github({
        repo = "erlang/otp",
        version_parser = versionParser,
        file_filter = fileFilter,
        os_parser = osParser,
        arch_parser = archParser,
        installer = vmrInstallerExecutable,
    })
    return vmrMergeVersionList(vl, gh)
end
