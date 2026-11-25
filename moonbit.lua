--[[
    MoonBit for VMR.
    The MoonBit CLI is published as a rolling "latest" set of binaries; each platform archive
    carries the matching core library archive in `extra`.
    https://www.moonbitlang.com/
--]]
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "moonbit"
sdk_name = "moonbit"
plugin_version = "0.1"
homepage = "https://www.moonbitlang.com/"

-- installer config
ic = C.installer({
    flag_files = {
        windows = { "bin", "lib", "include" },
        linux = { "bin", "lib", "include" },
        darwin = { "bin", "lib", "include" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        linux = { { "bin" } },
        darwin = { { "bin" } },
    },
    additional_envs = { { name = "MOON_HOME", value = {} } },
})

-- spider
local VERSIONS = { "latest" }

local CORE_URLS = {
    "https://cli.moonbitlang.com/binaries/%s/moonbit-darwin-x86_64.tar.gz",
    "https://cli.moonbitlang.com/binaries/%s/moonbit-darwin-aarch64.tar.gz",
    "https://cli.moonbitlang.com/binaries/%s/moonbit-linux-x86_64.tar.gz",
    "https://cli.moonbitlang.com/binaries/%s/moonbit-linux-aarch64.tar.gz",
    "https://cli.moonbitlang.com/binaries/%s/moonbit-windows-x86_64.zip",
}

local CORE_LIB_URL = "https://cli.moonbitlang.com/cores/core-%s.%s"

local function parseOs(dUrl)
    if vmrContains(dUrl, "darwin") then
        return "darwin"
    end
    if vmrContains(dUrl, "linux") then
        return "linux"
    end
    if vmrContains(dUrl, "windows") then
        return "windows"
    end
    return ""
end

local function parseArch(dUrl)
    if vmrContains(dUrl, "aarch64") then
        return "arm64"
    end
    if vmrContains(dUrl, "x86_64") then
        return "amd64"
    end
    return ""
end

function crawl()
    local vl = vmrNewVersionList()

    for _, versionStr in ipairs(VERSIONS) do
        for _, urlTemplate in ipairs(CORE_URLS) do
            local dUrl = vmrSprintf(urlTemplate, { versionStr })
            local osStr = parseOs(dUrl)
            local archStr = parseArch(dUrl)
            if osStr ~= "" and archStr ~= "" then
                local item = {}
                item["url"] = dUrl
                item["os"] = osStr
                item["arch"] = archStr
                item["installer"] = vmrInstallerUnarchiver
                item["extra"] = vmrSprintf(CORE_LIB_URL, { versionStr, osStr == "windows" and "zip" or "tar.gz" })
                item["size"] = 0
                item["lts"] = ""

                vmrAddItem(vl, versionStr, item)
            end
        end
    end

    return vl
end

function postInstall(path, version, item, archive)
    assert(item.extra ~= "", "MoonBit core archive URL is missing")
    local root = vmrCanonicalPath(path)
    assert(root ~= "", "failed to resolve MoonBit installation path")
    local bin = vmrPathJoin(root, "bin")
    local lib = vmrPathJoin(root, "lib")
    local windows = item.os == "windows"
    local moon = vmrPathJoin(bin, windows and "moon.exe" or "moon")
    local moonx = vmrPathJoin(bin, windows and "moonx.exe" or "moonx")

    assert(vmrChmodDirFiles(bin), "failed to make MoonBit binaries executable")
    local tcc = vmrPathJoin(vmrPathJoin(bin, "internal"), "tcc")
    if vmrFileExists(tcc) then
        assert(vmrChmodExecutable(tcc), "failed to make MoonBit tcc executable")
    end
    if not vmrFileExists(moonx) then
        assert(vmrHardLink(moon, moonx), "failed to link moonx")
    end

    assert(vmrCreateDir(lib), "failed to create MoonBit lib directory")
    local temp = vmrPathJoin(root, ".vmr-moonbit-core")
    assert(not vmrFileExists(temp), "MoonBit core temporary directory already exists")
    assert(vmrCreateDir(temp), "failed to create MoonBit core temporary directory")
    local core_archive = vmrPathJoin(temp, windows and "core.zip" or "core.tar.gz")
    assert(vmrDownloadFile(item.extra, core_archive), "failed to download MoonBit core")
    assert(vmrUnarchive(core_archive, lib, "", false), "failed to extract MoonBit core")
    assert(vmrRemoveAll(temp), "failed to remove MoonBit core temporary directory")

    local env = {
        MOON_HOME = root,
        PATH = bin .. (windows and ";" or ":") .. vmrGetOsEnv("PATH"),
    }
    local core = vmrPathJoin(lib, "core")
    assert(vmrExecSystemCmdEnv(core, { moon, "bundle", "--warn-list", "-a", "--all" }, env),
        "failed to bundle MoonBit core")
    assert(vmrExecSystemCmdEnv(core, { moon, "bundle", "--warn-list", "-a", "--target", "wasm-gc", "--quiet" }, env),
        "failed to bundle MoonBit core for wasm-gc")
    return true
end
