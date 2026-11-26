--[[
    Miniconda installation
--]]

-- global variables
sdk_name = "miniconda"
plugin_name = "miniconda"
plugin_version = "0.1"
homepage = "https://www.anaconda.com/docs/getting-started/miniconda/main"

-- installer config
ic = vmrNewInstallerConfig()
ic = vmrAddBinaryDirs(ic, "windows", {})
ic = vmrAddBinaryDirs(ic, "windows", { "Scripts" })
ic = vmrAddBinaryDirs(ic, "windows", { "Library", "bin" })
ic = vmrAddBinaryDirs(ic, "windows", { "condabin" })
ic = vmrAddBinaryDirs(ic, "linux", { "bin" })
ic = vmrAddBinaryDirs(ic, "linux", { "condabin" })
ic = vmrAddBinaryDirs(ic, "darwin", { "bin" })
ic = vmrAddBinaryDirs(ic, "darwin", { "condabin" })

-- spider
function parseArch(archStr)
    aa = vmrToLower(archStr)
    if vmrContains(aa, "x86_64") then
        return "amd64"
    end
    if vmrContains(aa, "arm64") then
        return "arm64"
    end
    if vmrContains(aa, "aarch64") then
        return "arm64"
    end
    return ""
end

function parseOs(osStr)
    oo = vmrToLower(osStr)
    if vmrContains(oo, "macosx") then
        return "darwin"
    elseif vmrContains(oo, "windows") then
        return "windows"
    elseif vmrContains(oo, "linux") then
        return "linux"
    end
    return ""
end

function parseVersionFromName(verName)
    local result = vmrRegexpFindString("(\\d+\\.\\d+\\.\\d+-\\d+)", verName)
    if result == "" then
        return vmrRegexpFindString("(\\d+\\.\\d+\\.\\d+)", verName)
    end
    return result
end

function filterByHref(h)
    return vmrHasSuffix(h, ".sh") or vmrHasSuffix(h, ".exe")
end

function crawl()
    local url = "https://repo.anaconda.com/miniconda"
    local timeout = 600
    local headers = {}
    headers["User-Agent"] =
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    local resp = vmrGetResponse(url, timeout, headers)

    local os, arch = vmrGetOsArch()

    local tr = vmrInitSelection(resp, "tr")
    local versionList = vmrNewVersionList()

    function parseTr(i, ss)
        if not ss then
            return
        end

        local tds = vmrFind(ss, "td")
        local eqs = vmrEq(tds, 0)
        local a = vmrFind(eqs, "a")
        if not a then
            return
        end

        local href = vmrAttr(a, "href")
        if not href or (not filterByHref(href)) then
            return
        end

        local itemOs = parseOs(href)
        local itemArch = parseArch(href)
        if itemOs ~= os or itemArch ~= arch then
            return
        end

        local versionName = parseVersionFromName(href)
        if versionName == "" then
            return
        end

        local item = {}
        item["url"] = vmrUrlJoin(url, href)
        item["os"] = os
        item["arch"] = arch
        item["installer"] = vmrInstallerExecutable

        eqs = vmrEq(tds, 3)
        item["sum"] = vmrTrimSpace(vmrText(eqs))
        if item["sum"] ~= "" then
            item["sum_type"] = "sha256"
        end
        item["size"] = 0

        vmrAddItem(versionList, versionName, item)
    end

    vmrEach(tr, parseTr)
    return versionList
end

function install(path, version, item, archive)
    local os = vmrGetOsArch()
    local _, ok
    if os == "windows" then
        _, ok = vmrExecDirect(false, "", {
            archive, "/InstallationType=JustMe", "/RegisterPython=0", "/S",
        }, "/D=" .. path)
    else
        _, ok = vmrExecDirect(false, "", { "sh", archive, "-b", "-f", "-p", path })
    end
    local executable = os == "windows" and "Scripts/conda.exe" or "bin/conda"
    if not ok or not vmrFileExists(vmrPathJoin(path, executable)) then
        error("Miniconda installer failed or did not produce conda")
    end
    return true
end
