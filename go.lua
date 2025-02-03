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
ic = newInstallerConfig()
ic = addFlagFiles(ic , "", {"VERSION", "LICENSE"})
ic = addBinaryDirs(ic, "", {"bin"}) 
ic = addAdditionalEnvs(ic , "GOROOT", {}, "")

-- spider
function parseArch(archStr)
    if contains(archStr, "x86-64") then
        return "amd64"
    end
    if contains(archStr, "ARM64") then
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
    local resp = getResponse(url, timeout, headers)

    local s1 = initSelection(resp, ".toggle")
    local s2 = initSelection(resp, ".toggleVisible")

    local versionList = newVersionList()

    function parseToggle(i, ss)
        if not ss then
            return
        end
        local versionStr = attr(ss, "id")
        versionStr = trimSpace(versionStr)

        if not hasPrefix(versionStr, "go") then
           return 
        end
        
        local downloadTable = find(ss, "table.downloadtable")
        local tr = find(downloadTable, "tr")

        function parseItem(i, sss)
            local tds = find(sss, "td")

            local eqs = eq(tds, 1)
            local pkgKind = trimSpace(text(eqs))

            eqs = eq(tds, 3)
            local archInfo = parseArch(text(eqs))

            eqs = eq(tds, 2)
            local osInfo = parseOs(text(eqs))

            if pkgKind == "Archive" and archInfo ~= "" and osInfo ~= "" then
                eqs = eq(tds, 0)
                local a = find(eqs, "a")
                local href = attr(a, "href")
                if href == "" then
                    return
                end
                local item = {}
                item["arch"] = archInfo
                item["os"] = osInfo
                item["url"] = urlJoin("https://go.dev", href)
                item["installer"] = "unarchiver"
                
                eqs = eq(tds, 4)
                item["extra"] = trimSpace(text(eqs))

                eqs = eq(tds, 5)
                item["sum"] = trimSpace(text(eqs))

                if lenString(item["sum"]) == 64 then
                    item["sum_type"] = "sha256"
                elseif lenString(item["sum"]) == 40 then
                    item["sum_type"] = "sha1"
                end

                item["size"] = 0
                item["lts"] = ""

                addItem(versionList, versionStr, item)
            end
        end

        each(tr, parseItem)
    end

    each(s1, parseToggle)
    each(s2, parseToggle)

    return versionList
end
