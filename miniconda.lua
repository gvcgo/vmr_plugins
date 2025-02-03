--[[
    Miniconda.
    Latest verisons only.
--]]

-- global variables
sdk_name = "miniconda"
plugin_name = "miniconda"
plugin_version = "0.1"
prequisite = ""
homepage = "https://docs.anaconda.com/miniconda/"

-- installer config
ic = newInstallerConfig()
ic = addBinaryDirs(ic, "", {"bin"})
ic = addBinaryDirs(ic, "", {"condabin"})

-- spider
function parseArch(archStr)
    if contains(archStr, "x86_64") then
        return "amd64"
    end
    if contains(archStr, "arm64") then
        return "arm64"
    end
    if contains(archStr, "aarch64") then
        return "arm64"
    end
    return ""
end

function parseOs(osStr)
    if contains(osStr, "MacOSX") then
        return "darwin"
    elseif contains(osStr, "Windows") then
        return "windows"
    elseif contains(osStr, "Linux") then
        return "linux"
    end
    return ""
end

function filterByFileName(fileName)
    if contains(fileName, "Miniconda3-latest-") then
        if not contains(fileName, ".pkg") then
            return true
        end
    end
    return false
end

-- called by vmr
function crawl()
    local url = "https://repo.anaconda.com/miniconda/"
    local timeout = 600
    local headers = {}
    headers["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.36"
    local resp = getResponse(url, timeout, headers)

    local t = initSelection(resp, "table")
    local tr = find(t, "tr")

    local versionList = newVersionList()

    function parseItem(i, s)
        if not s then
            return
        end
        local td = find(s, "td")

        local eqs = eq(td, 0)
        local a = find(eqs, "a")
        local href = attr(a, "href")
        if href == "" then
            return
        end

        local fileName = text(a)
        if not filterByFileName(fileName) then
            return
        end

        local item = {}
        item["arch"] = parseArch(fileName)
        item["os"] = parseOs(fileName)

        if item["arch"] == "" or item["os"] == "" then
            return
        end

        if not hasPrefix(href, "http") then
            href = urlJoin(url, href)
        end
        item["url"] = href

        eqs = eq(td, 3)
        item["sum"] = text(eqs)
        if item["sum"] ~= "" then
            item["sum_type"] = "sha256"
        else
            item["sum_type"] = ""
        end

        item["extra"] = ""
        item["lts"] = ""
        item["size"] = 0
        item["installer"] = "executable"

        addItem(versionList, "latest", item)
    end

    each(tr, parseItem)

    return versionList
end
