-- jdk: live crawl of the BellSoft Liberica releases API plus the Liberica NIK releases API
-- (ported from vcollector official/jdk_liberica.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "jdk"
sdk_name = "jdk"
plugin_version = "0.1"
homepage = "https://bell-sw.com/pages/downloads/"

ic = C.installer({
    flag_files = {
        windows = { "bin", "lib", "include" },
        darwin = { "bin", "lib", "include" },
        linux = { "bin", "lib", "include" },
    },
    binary_dirs = {
        windows = { { "bin" }, { "jre", "bin" } },
        darwin = { { "bin" }, { "jre", "bin" } },
        linux = { { "bin" }, { "jre", "bin" } },
    },
    additional_envs = {
        { name = "JAVA_HOME", value = {}, version = "" },
        -- The installer binding stores one DirPath per entry, so the three legacy CLASSPATH
        -- entries are registered separately (same name/version, one jar each).
        { name = "CLASSPATH", value = { "lib", "dt.jar" }, version = "major<=8" },
        { name = "CLASSPATH", value = { "lib", "tools.jar" }, version = "major<=8" },
        { name = "CLASSPATH", value = { "jre", "lib", "rt.jar" }, version = "major<=8" },
    },
})

local LIBERICA_URL = "https://api.bell-sw.com/v1/liberica/releases/?&"
local NIK_URL = "https://api.bell-sw.com/v1/nik/releases/?&"

local OS_MAP = { linux = "linux", windows = "windows", macos = "darwin" }
local ARCH_MAP = { x86 = "amd64", arm = "arm64" }

local function version_string(item)
    return vmrSprintf("%s.%s.%s.%s_%s", {
        vmrGetInt(item, "featureVersion"),
        vmrGetInt(item, "extraVersion"),
        vmrGetInt(item, "updateVersion"),
        vmrGetInt(item, "patchVersion"),
        vmrGetInt(item, "buildVersion"),
    })
end

local function add_item(vl, vstr, item)
    local os_name = OS_MAP[vmrGetString(item, "os")]
    local arch = ARCH_MAP[vmrGetString(item, "architecture")]
    if not os_name or not arch then
        return
    end
    if vmrGetInt(item, "bitness") ~= 64 then
        return
    end
    local package_type = vmrGetString(item, "packageType")
    if package_type ~= "tar.gz" and package_type ~= "zip" then
        return
    end

    vmrAddItem(vl, vstr, {
        url = vmrGetString(item, "downloadUrl"),
        arch = arch,
        os = os_name,
        sum = vmrGetString(item, "sha1"),
        sum_type = "sha1",
        size = vmrGetInt(item, "size"),
        installer = vmrInstallerUnarchiver,
        lts = (vmrGetString(item, "LTS") == "true") and "1" or "",
        extra = vmrGetString(item, "version"),
    })
end

local function nik_version(item)
    local component_version = ""
    vmrSliceEach(item, "components", function(_, comp)
        if vmrGetString(comp, "component") == "liberica" then
            component_version = vmrGetString(comp, "version")
        end
    end)
    if component_version == "" then
        return ""
    end
    local joined = "nik-" .. component_version .. "-" .. vmrGetString(item, "version")
    local parts = vmrSplit(joined, "+")
    return table.concat(parts, ".")
end

local function crawl_liberica(vl)
    local resp = vmrGetResponse(LIBERICA_URL, 300, {})
    vmrSliceEach(vmrInitGJson(resp), "", function(_, item)
        if vmrGetString(item, "bundleType") ~= "jdk-full" then
            return
        end
        add_item(vl, version_string(item), item)
    end)
end

local function crawl_nik(vl)
    local resp = vmrGetResponse(NIK_URL, 300, {})
    vmrSliceEach(vmrInitGJson(resp), "", function(_, item)
        if vmrGetString(item, "component") ~= "nik" then
            return
        end
        if not vmrContains(vmrGetString(item, "bundleType"), "full") then
            return
        end
        local vstr = nik_version(item)
        if vstr ~= "" then
            add_item(vl, vstr, item)
        end
    end)
end

function crawl()
    local vl = vmrNewVersionList()
    crawl_liberica(vl)
    crawl_nik(vl)
    return vl
end
