--[[
    Go language support for VMR.
--]]

-- global variables
sdk_name = "go"
plugin_name = "go"
plugin_version = "0.1"
prequisite = ""
homepage = "https://go.dev/"

-- installer config
ic = vmrNewInstallerConfig()
ic = vmrAddFlagFiles(ic , "", {"VERSION", "LICENSE"})
ic = vmrAddBinaryDirs(ic, "", {"bin"})
ic = vmrAddAdditionalEnvs(ic , "GOROOT", {}, "")

-- spider
function parseArch(archStr)
    if vmrContains(archStr, "x86-64") then
        return "amd64"
    end
    if vmrContains(archStr, "ARM64") then
        return "arm64"
    end
    return ""
end

function parseOs(osStr)
    if osStr == "macOS" then
        return "darwin"
    elseif osStr == "OS X" then
        return "darwin"
    elseif osStr == "Windows" then
        return "windows"
    elseif osStr == "Linux" then
        return "linux"
    end
    return ""
end

--[[
item{
    arch
    os
    url
    installer
    extra
    sum
    sum_type
    size
    lts
}
--]]

-- called by vmr
function crawl()
    local url = "https://golang.google.cn/dl/"
    local timeout = 600
    local headers = {}
    headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    local resp = vmrGetResponse(url, timeout, headers)

    local s1 = vmrInitSelection(resp, ".toggle")
    local s2 = vmrInitSelection(resp, ".toggleVisible")

    local versionList = vmrNewVersionList()

    function parseToggle(i, ss)
        if not ss then
            return
        end
        local versionStr = vmrAttr(ss, "id")
        versionStr = vmrTrimSpace(versionStr)

        if not vmrHasPrefix(versionStr, "go") then
           return
        end

        versionStr = vmrTrimPrefix(versionStr, "go")

        local downloadTable = vmrFind(ss, "table.downloadtable")
        local tr = vmrFind(downloadTable, "tr")

        function parseItem(i, sss)
            local tds = vmrFind(sss, "td")

            local eqs = vmrEq(tds, 1)
            local pkgKind = vmrTrimSpace(vmrText(eqs))

            eqs = vmrEq(tds, 3)
            local archInfo = parseArch(vmrText(eqs))

            eqs = vmrEq(tds, 2)
            local osInfo = parseOs(vmrText(eqs))

            if pkgKind == "Archive" and archInfo ~= "" and osInfo ~= "" then
                eqs = vmrEq(tds, 0)
                local a = vmrFind(eqs, "a")
                local href = vmrAttr(a, "href")
                if href == "" then
                    return
                end
                local item = {}
                item["arch"] = archInfo
                item["os"] = osInfo
                item["url"] = vmrUrlJoin("https://go.dev", href)
                item["installer"] = "unarchiver"

                eqs = vmrEq(tds, 4)
                item["extra"] = vmrTrimSpace(vmrText(eqs))

                eqs = vmrEq(tds, 5)
                item["sum"] = vmrTrimSpace(vmrText(eqs))

                if vmrLenString(item["sum"]) == 64 then
                    item["sum_type"] = "sha256"
                elseif vmrLenString(item["sum"]) == 40 then
                    item["sum_type"] = "sha1"
                end

                item["size"] = 0
                item["lts"] = ""

                vmrAddItem(versionList, versionStr, item)
            end
        end

        vmrEach(tr, parseItem)
    end

    vmrEach(s1, parseToggle)
    vmrEach(s2, parseToggle)

    return versionList
end
