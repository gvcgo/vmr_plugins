-- Shared helpers for VMR Lua plugins.
--
-- Plugins must be self-contained from VMR's point of view; this file is shipped next to them and
-- loaded with:
--
--   local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")
--
-- The functions below intentionally only use the `vmr*` bindings provided by VMR, so they keep
-- working across platforms and do not depend on a pre-generated .version.json file.

local C = {}

-- Returns true when `value` matches any { contains = {}, prefix = {}, suffix = {} } rule.
function C.match(value, rules)
    if not value or not rules then
        return false
    end
    for _, p in ipairs(rules.contains or {}) do
        if vmrContains(value, p) then
            return true
        end
    end
    for _, p in ipairs(rules.prefix or {}) do
        if vmrHasPrefix(value, p) then
            return true
        end
    end
    for _, p in ipairs(rules.suffix or {}) do
        if vmrHasSuffix(value, p) then
            return true
        end
    end
    return false
end

-- Ordered pattern -> value lookup, e.g. { { "-x86_64", "amd64" }, { "-aarch64", "arm64" } }.
function C.lookup(value, pairs)
    if not pairs then
        return ""
    end
    for _, pair in ipairs(pairs) do
        if vmrContains(value, pair[1]) then
            return pair[2]
        end
    end
    return ""
end

-- Builds an installer config from a compact table:
--   flag_files = { linux = {"bin"}, ... }
--   binary_dirs = { linux = { {"bin"}, {"lib"} }, ... }
--   additional_envs = { { name = "GOROOT", value = {}, version = "" }, ... }
--   flag_dir_excepted = true
function C.installer(cfg)
    local ic = vmrNewInstallerConfig()
    cfg = cfg or {}
    if cfg.flag_files then
        for os, files in pairs(cfg.flag_files) do
            ic = vmrAddFlagFiles(ic, os, files)
        end
    end
    if cfg.binary_dirs then
        for os, groups in pairs(cfg.binary_dirs) do
            for _, group in ipairs(groups) do
                ic = vmrAddBinaryDirs(ic, os, group)
            end
        end
    end
    if cfg.additional_envs then
        for _, e in ipairs(cfg.additional_envs) do
            ic = vmrAddAdditionalEnvs(ic, e.name, e.value or {}, e.version or "")
        end
    end
    if cfg.binary_rename then
        ic = vmrSetBinaryRename(ic, cfg.binary_rename.name_flag, cfg.binary_rename.rename_to)
    end
    if cfg.flag_dir_excepted then
        ic = vmrEnableFlagDirExcepted(ic)
    end
    return ic
end

-- Generic GitHub Release crawler.
--
-- cfg:
--   repo            = "owner/repo"
--   tag_regex       = optional regex used by tagFilter
--   version_regex   = regex used to extract the version from a tag
--   version_prefix  = prefix stripped from the extracted version (default "v")
--   exclude/include = { contains, prefix, suffix } rules for asset names
--   os              = ordered { {pattern, name}, ... }
--   arch            = ordered { {pattern, name}, ... }
--   installer       = installer string or function(assetName)
--   tag_filter/file_filter/version_parser/os_parser/arch_parser = optional overrides
function C.github(cfg)
    local tag_filter = cfg.tag_filter or function(tag)
        if not cfg.tag_regex or cfg.tag_regex == "" then
            return true
        end
        return vmrRegexpFindString(cfg.tag_regex, tag) ~= ""
    end

    local version_parser = cfg.version_parser or function(tag)
        local v = vmrRegexpFindString(cfg.version_regex or "\\d+(\\.\\d+){1,2}", tag)
        if v == "" then
            return ""
        end
        return vmrTrimPrefix(v, cfg.version_prefix or "v")
    end

    local file_filter = cfg.file_filter or function(name)
        if C.match(name, cfg.exclude) then
            return false
        end
        if cfg.include and not C.match(name, cfg.include) then
            return false
        end
        return true
    end

    local os_parser = cfg.os_parser or function(name)
        return C.lookup(name, cfg.os)
    end
    local arch_parser = cfg.arch_parser or function(name)
        return C.lookup(name, cfg.arch)
    end

    local installer = cfg.installer or vmrInstallerUnarchiver
    local installer_getter = cfg.installer_getter
    if not installer_getter then
        installer_getter = function(_)
            if type(installer) == "function" then
                return installer(_)
            end
            return installer
        end
    end

    return vmrGetGithubRelease(
        cfg.repo,
        tag_filter,
        version_parser,
        file_filter,
        arch_parser,
        os_parser,
        installer_getter
    )
end

-- Generic pixi package crawler (conda-forge channel). The package is solved/installed by
-- vmr's embedded pixi/rattler backend on `vmr use`; no conda executable is used.
-- `vmrSearchByConda` is a compatibility binding name kept for existing plugins.
function C.pixi(package_name)
    local vl = vmrNewVersionList()
    if vmrSearchByPixi then
        return vmrSearchByPixi(vl, package_name)
    end
    return vmrSearchByConda(vl, package_name)
end

-- Old name retained for upstream plugins that already call it.
C.conda = C.pixi

-- Combines several version lists (e.g. two GitHub repos).
function C.merge(a, b)
    return vmrMergeVersionList(a, b)
end

return C
