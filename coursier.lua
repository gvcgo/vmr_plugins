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
ic = newInstallerConfig()
ic = addFlagFiles(ic, "windows", {"cs.exe"})
ic = addFlagFiles(ic, "linux", {"cs"})
ic = addFlagFiles(ic, "darwin", {"cs"})
ic = enableFlagDirExcepted(ic)

--spider
local rePattern = "v(\\d+)(.\\d+){2}"
function tagFilter(str)
    local s = regexpFindString(rePattern, str)
	if s ~= "" then
		return true
	end
	return false
end

function versionParser(str)
	local s = regexpFindString(rePattern, str)
	s = trimPrefix(s, "v")
	return s
end

function fileFilter(str)
	if hasPrefix(str, "cs-") and hasSuffix(str, "-sdk.zip") then
        return true
    end
	return false
end

function archParser(str)
	if contains(str, "-x86_64") then
		return "amd64"
	end
	if contains(str, "-aarch64") then
		return "arm64"
	end
	return ""
end

function osParser(str)
	if contains(str, "linux") then
		return "linux"
	end
	if contains(str, "darwin") then
		return "darwin"
	end
	if contains(str, "-win32") then
		return "windows"
	end
	return ""
end

function installerGetter(str)
	return "unarchiver"
end

-- called by vmr
function crawl()
    local r1 = getGithubRelease("coursier/coursier", tagFilter, versionParser, fileFilter, archParser, osParser, installerGetter)
    local r2 = getGithubRelease("VirtusLab/coursier-m1", tagFilter, versionParser, fileFilter, archParser, osParser, installerGetter)
    local result = mergeVersionList(r1, r2)
    return result
end
