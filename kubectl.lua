-- kubectl: live crawl of the Kubernetes patch-release table plus dl.k8s.io checksums
-- (ported from vcollector official/kubectl.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "kubectl"
sdk_name = "kubectl"
plugin_version = "0.1"
homepage = "https://kubernetes.io/docs/tasks/tools/"

ic = C.installer({
    flag_files = {
        windows = { "kubectl.exe" },
        darwin = { "kubectl" },
        linux = { "kubectl" },
    },
    binary_rename = { name_flag = "kubectl", rename_to = "kubectl" },
})

local DOWNLOAD_URL = "https://kubernetes.io/releases/patch-releases/"
local LATEST_URL = "https://dl.k8s.io/release/stable.txt"
local DOWNLOAD_PATTERN = "https://dl.k8s.io/release/v%s/bin/%s/%s/kubectl"
local SHA256_PATTERN = "https://dl.k8s.io/release/v%s/bin/%s/%s/kubectl.sha256"
local EXE_SHA256_PATTERN = "https://dl.k8s.io/v%s/bin/%s/%s/kubectl.exe.sha256"
local VERSION_REGEX = "\\d+(.\\d+){2}"

local ARCH_OS_LIST = {
    { "darwin", "amd64" },
    { "darwin", "arm64" },
    { "linux", "amd64" },
    { "linux", "arm64" },
    { "windows", "amd64" },
}

local function response_text(resp)
    return vmrText(vmrInitSelection(resp, "body"))
end

local function parse_version(vl, vstr, os_name, arch)
    local sha_url
    if os_name == "windows" then
        sha_url = vmrSprintf(EXE_SHA256_PATTERN, { vstr, os_name, arch })
    else
        sha_url = vmrSprintf(SHA256_PATTERN, { vstr, os_name, arch })
    end

    local sha = vmrTrimSpace(response_text(vmrGetResponse(sha_url, 30, {})))
    if sha == "" or vmrContains(sha, "NoSuchKey") then
        return
    end

    local durl = vmrSprintf(DOWNLOAD_PATTERN, { vstr, os_name, arch })
    if os_name == "windows" then
        durl = durl .. ".exe"
    end

    vmrAddItem(vl, vstr, {
        url = durl,
        arch = arch,
        os = os_name,
        sum = sha,
        sum_type = "sha256",
        size = 0,
        installer = vmrInstallerExecutable,
        lts = "",
        extra = "",
    })
end

function crawl()
    local vl = vmrNewVersionList()
    local versions = {}

    local resp = vmrGetResponse(DOWNLOAD_URL, 180, {})
    vmrEach(vmrInitSelection(resp, "tr td"), function(_, cell)
        local found = vmrRegexpFindString(VERSION_REGEX, vmrTrimSpace(vmrText(cell)))
        if found ~= "" and vmrContains(found, ".") then
            table.insert(versions, found)
        end
    end)

    local latest = vmrRegexpFindString(
        VERSION_REGEX,
        response_text(vmrGetResponse(LATEST_URL, 30, {}))
    )
    if latest ~= "" then
        table.insert(versions, latest)
    end

    for _, target in ipairs(ARCH_OS_LIST) do
        for _, vstr in ipairs(versions) do
            parse_version(vl, vstr, target[1], target[2])
        end
    end

    return vl
end
