--[[
    Coursier.
    https://github.com/coursier/coursier
    https://github.com/VirtusLab/coursier-m1
--]]

-- global variables
sdk_name = "coursier"
plugin_name = "coursier"
plugin_version = "0.1"
prequisite = ""
homepage = "https://get-coursier.io/docs/cli-overview"

-- installer config
ic = vmrNewInstallerConfig()
ic = vmrAddFlagFiles(ic, "windows", { "cs.exe" })
ic = vmrAddFlagFiles(ic, "linux", { "cs" })
ic = vmrAddFlagFiles(ic, "darwin", { "cs" })
ic = vmrEnableFlagDirExcepted(ic)

--spider
local rePattern = "v(\\d+)(.\\d+){2}"
function tagFilter(str)
    local s = vmrRegexpFindString(rePattern, str)
    if s ~= "" then
        return true
    end
    return false
end

function versionParser(str)
    local s = vmrRegexpFindString(rePattern, str)
    s = vmrTrimPrefix(s, "v")
    return s
end

function fileFilter(str)
    if vmrHasPrefix(str, "cs-") and vmrHasSuffix(str, "-sdk.zip") then
        return true
    end
    return false
end

function archParser(str)
    if vmrContains(str, "-x86_64") then
        return "amd64"
    end
    if vmrContains(str, "-aarch64") then
        return "arm64"
    end
    return ""
end

function osParser(str)
    if vmrContains(str, "linux") then
        return "linux"
    end
    if vmrContains(str, "darwin") then
        return "darwin"
    end
    if vmrContains(str, "-win32") then
        return "windows"
    end
    return ""
end

function installerGetter(str)
    return "unarchiver"
end

-- called by vmr
function crawl()
    local r1 = vmrGetGithubRelease("coursier/coursier", tagFilter, versionParser, fileFilter, archParser, osParser,
        installerGetter)
    local r2 = vmrGetGithubRelease("VirtusLab/coursier-m1", tagFilter, versionParser, fileFilter, archParser, osParser,
        installerGetter)
    local result = vmrMergeVersionList(r1, r2)
    return result
end
