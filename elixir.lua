-- elixir: live GitHub Release crawl (ported from vcollector gh/lans/exilir.go).
--
-- Elixir publishes one asset per OTP release (`elixir-otp-<N>.zip`/`.exe`), so the version name is
-- derived from the asset (`<tag-version>-otp-<N>`), which the generic C.github helper cannot do.
-- This crawler therefore talks to the GitHub releases API through the plain VMR HTTP bindings.
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "elixir"
sdk_name = "elixir"
plugin_version = "0.1"
homepage = "https://elixir-lang.org/"

ic = C.installer({
    flag_files = {
        windows = { "bin", "lib" },
        darwin = { "bin", "lib" },
        linux = { "bin", "lib" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
})

local RELEASES_URL = "https://api.github.com/repos/elixir-lang/elixir/releases?per_page=100&page="
local MAX_PAGES = 10

local function asset_filter(name)
    if vmrHasSuffix(name, ".sha1sum") or vmrHasSuffix(name, ".sha256sum") then
        return false
    end
    return vmrHasPrefix(name, "elixir-otp-")
end

function crawl()
    local vl = vmrNewVersionList()
    local headers = {
        ["User-Agent"] = "vmr",
        ["Accept"] = "application/vnd.github+json",
        ["Authorization"] = "Bearer " .. vmrGetGithubToken(),
    }

    for page = 1, MAX_PAGES do
        local resp = vmrGetResponse(RELEASES_URL .. tostring(page), 120, headers)
        local releases = vmrInitGJson(resp)
        if vmrGetString(releases, "0.tag_name") == "" then
            break
        end

        vmrSliceEach(releases, "", function(_, release)
            local tag = vmrGetString(release, "tag_name")
            if vmrRegexpFindString("v\\d+(\\.\\d+){2}", tag) == "" then
                return
            end
            local base = vmrTrimPrefix(tag, "v")

            vmrSliceEach(release, "assets", function(_, asset)
                local name = vmrGetString(asset, "name")
                if not asset_filter(name) then
                    return
                end
                local otp = vmrRegexpFindString("otp-[0-9]+", name)
                if otp == "" then
                    return
                end

                local version = base .. "-" .. otp
                local url = vmrGetString(asset, "browser_download_url")
                local size = vmrGetInt(asset, "size")

                if vmrHasSuffix(name, ".exe") then
                    vmrAddItem(vl, version, {
                        url = url,
                        os = "windows",
                        arch = "amd64",
                        size = size,
                        installer = vmrInstallerExecutable,
                    })
                elseif vmrHasSuffix(name, ".zip") then
                    for _, platform in ipairs({ "darwin", "linux" }) do
                        vmrAddItem(vl, version, {
                            url = url,
                            os = platform,
                            arch = "any",
                            size = size,
                            installer = vmrInstallerUnarchiver,
                        })
                    end
                end
            end)
        end)
    end

    return vl
end
