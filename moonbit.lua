local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

-- global variables
plugin_name = "moonbit"
sdk_name = "moonbit"
plugin_version = "0.1"
homepage = "https://www.moonbitlang.com/"

-- installer config
ic = C.installer({
    binary_dirs = {
        windows = { { "bin" } },
        linux = { { "bin" } },
        darwin = { { "bin" } },
    },
    additional_envs = { { name = "MOON_HOME", value = {} } },
})

local INDEX_URL = "https://moonup.csu.moe/v3/channel-latest.json"
local RELEASE_URL = "https://github.com/chawyehsu/moonbit-binaries/releases/download/"
local TARGETS = {
    ["aarch64-apple-darwin"] = { os = "darwin", arch = "arm64", legacy = "darwin-arm64.tar.gz" },
    ["x86_64-apple-darwin"] = { os = "darwin", arch = "amd64", legacy = "darwin-x64.tar.gz" },
    ["aarch64-unknown-linux"] = { os = "linux", arch = "arm64", legacy = "linux-aarch64.tar.gz" },
    ["x86_64-unknown-linux"] = { os = "linux", arch = "amd64", legacy = "linux-x64.tar.gz" },
    ["x86_64-pc-windows"] = { os = "windows", arch = "amd64", legacy = "win-x64.zip" },
}

function crawl()
    local versions = vmrNewVersionList()
    local index = vmrInitGJson(vmrGetResponse(INDEX_URL, 300, {}))
    vmrSliceEach(index, "releases", function(_, release)
        local version = vmrGetString(release, "version")
        if version == "" then
            return
        end
        local tag = ("v" .. version):gsub("%+", "%%2B")
        local base = RELEASE_URL .. tag .. "/"
        local legacy = vmrGetString(release, "layoutVersion1") == "true"
        local bundle = vmrGetString(release, "bundleSourceDir") == "true" and "source" or "current"
        local moonx = vmrGetString(release, "moonx") == "unavailable" and "unavailable" or "available"
        local core = base .. "moonbit-core-" .. tag .. (legacy and ".zip" or "-universal.zip")
        vmrSliceEach(release, "targets", function(_, value)
            local target = vmrGetString(value, "")
            local platform = TARGETS[target]
            if not platform then
                return
            end
            local suffix = legacy and platform.legacy
                or (target .. (platform.os == "windows" and ".zip" or ".tar.gz"))
            vmrAddItem(versions, version, {
                url = base .. "moonbit-" .. tag .. "-" .. suffix,
                os = platform.os,
                arch = platform.arch,
                installer = vmrInstallerUnarchiver,
                extra = core .. "|" .. bundle .. "|" .. moonx,
            })
        end)
    end)
    return versions
end

function install(path, version, item, archive)
    local temp = vmrTempDir()
    assert(temp ~= "", "failed to create MoonBit temporary directory")
    local ok, err = pcall(function()
        assert(vmrExtract(archive, temp), "failed to extract MoonBit binaries")
        local executable = vmrFindFile(temp, item.os == "windows" and "moon.exe" or "moon", 3)
        assert(executable ~= "", "MoonBit executable not found")
        local bin = executable:match("^(.*)[/\\][^/\\]+$")
        assert(bin, "failed to locate MoonBit binaries")
        local root = bin:match("^(.*)[/\\]bin$")
        if root then
            assert(vmrCopyDir(root, path), "failed to copy MoonBit binaries")
        else
            assert(vmrCopyDir(bin, vmrPathJoin(path, "bin")), "failed to copy MoonBit binaries")
        end
    end)
    local cleaned = vmrRemoveAll(temp)
    assert(ok, err)
    assert(cleaned, "failed to remove MoonBit temporary directory")
    return true
end

function postInstall(path, version, item, archive)
    local core_url, bundle_mode, moonx_mode = item.extra:match("^([^|]+)|([^|]+)|([^|]+)$")
    assert(core_url, "MoonBit core archive URL is missing")
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
    if moonx_mode ~= "unavailable" and not vmrFileExists(moonx) then
        assert(vmrHardLink(moon, moonx), "failed to link moonx")
    end

    assert(vmrCreateDir(lib), "failed to create MoonBit lib directory")
    local temp = vmrPathJoin(root, ".vmr-moonbit-core")
    assert(not vmrFileExists(temp), "MoonBit core temporary directory already exists")
    assert(vmrCreateDir(temp), "failed to create MoonBit core temporary directory")
    local core_archive = vmrPathJoin(temp, "core.zip")
    assert(vmrDownloadFile(core_url, core_archive), "failed to download MoonBit core")
    assert(vmrUnarchive(core_archive, lib, "", false), "failed to extract MoonBit core")
    assert(vmrRemoveAll(temp), "failed to remove MoonBit core temporary directory")

    local env = {
        MOON_HOME = root,
        PATH = bin .. (windows and ";" or ":") .. vmrGetOsEnv("PATH"),
    }
    local core = vmrPathJoin(lib, "core")
    if bundle_mode == "source" then
        assert(vmrExecSystemCmdEnv(core, { moon, "--source-dir", core, "bundle", "--all" }, env),
            "failed to bundle MoonBit core")
    elseif moonx_mode == "unavailable" then
        assert(vmrExecSystemCmdEnv(core, { moon, "-C", core, "bundle", "--all" }, env),
            "failed to bundle MoonBit core")
    else
        assert(vmrExecSystemCmdEnv(core, { moon, "bundle", "--warn-list", "-a", "--all" }, env),
            "failed to bundle MoonBit core")
        assert(vmrExecSystemCmdEnv(core, { moon, "bundle", "--warn-list", "-a", "--target", "wasm-gc", "--quiet" }, env),
            "failed to bundle MoonBit core for wasm-gc")
    end
    return true
end
