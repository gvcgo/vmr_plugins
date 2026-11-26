-- clojure: live GitHub Release crawl (ported from vcollector gh/lans/clojure.go).
local C = dofile(__vmr_plugin_dir .. "/_vmr_common.lua")

plugin_name = "clojure"
sdk_name = "clojure"
plugin_version = "0.1"
homepage = "https://clojure.org/"

ic = C.installer({
    flag_files = {
        windows = { "ClojureTools.psd1", "ClojureTools.psm1" },
        darwin = { "deps.edn", "example-deps.edn" },
        linux = { "deps.edn", "example-deps.edn" },
    },
    binary_dirs = {
        windows = { { "bin" } },
        darwin = { { "bin" } },
        linux = { { "bin" } },
    },
    flag_dir_excepted = true,
})

function crawl()
    return C.github({
        repo = "clojure/brew-install",
        tag_regex = "\\d+(\\.\\d+){2}",
        version_parser = function(tag)
            return vmrTrimPrefix(tag, "v")
        end,
        file_filter = function(name)
            if vmrHasSuffix(name, ".zip") then
                return true
            end
            return vmrHasPrefix(name, "clojure") and vmrHasSuffix(name, ".tar.gz")
        end,
        os_parser = function(name)
            if vmrHasSuffix(name, ".zip") then
                return "windows"
            end
            return "unix"
        end,
        arch_parser = function(_)
            return "any"
        end,
        installer = vmrInstallerUnarchiver,
    })
end

function postInstall(path, version, item, archive)
    local os = vmrGetOsArch()
    local bin = vmrPathJoin(path, "bin")
    if not vmrCreateDir(bin) then
        error("cannot create Clojure bin directory")
    end
    if os == "windows" then
        local script = "$ErrorActionPreference = 'Stop'\r\nImport-Module (Join-Path $PSScriptRoot '..\\ClojureTools.psd1')\r\nInvoke-Clojure @args\r\nif ($null -ne $LASTEXITCODE) { exit $LASTEXITCODE }\r\n"
        for _, name in ipairs({ "clojure", "clj" }) do
            local launcher = '@echo off\r\npowershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0' .. name .. '.ps1" %*\r\nexit /b %errorlevel%\r\n'
            if not vmrWriteFile(vmrPathJoin(bin, name .. ".ps1"), script)
                or not vmrWriteFile(vmrPathJoin(bin, name .. ".cmd"), launcher) then
                error("cannot write Clojure launchers")
            end
        end
    else
        local lib = vmrPathJoin(path, "lib/clojure")
        local libexec = vmrPathJoin(lib, "libexec")
        if not vmrCreateDir(libexec) then
            error("cannot create Clojure library directory")
        end
        local entries = vmrReadDir(path)
        if not entries then
            error("cannot list Clojure installation")
        end
        for _, name in ipairs(entries) do
            if name == "deps.edn" or name == "example-deps.edn" or name == "tools.edn"
                or name:match("%.jar$") then
                local source = vmrPathJoin(path, name)
                local dest = vmrPathJoin(name:match("%.jar$") and libexec or lib, name)
                if not vmrCopyFile(source, dest) or not vmrRemoveFile(source) then
                    error("cannot install Clojure file: " .. name)
                end
            end
        end
        for _, launcher in ipairs({ { "clojure", "PREFIX", lib }, { "clj", "BINDIR", bin } }) do
            local source = vmrPathJoin(path, launcher[1])
            local script = vmrReadFile(source)
            if not script:find(launcher[2], 1, true) then
                error("Clojure launcher is missing " .. launcher[2])
            end
            local quoted = "'" .. launcher[3]:gsub("'", "'\\''") .. "'"
            script = script:gsub(launcher[2], function() return quoted end)
            local dest = vmrPathJoin(bin, launcher[1])
            if not vmrWriteFile(dest, script) or not vmrChmodExecutable(dest)
                or not vmrRemoveFile(source) then
                error("cannot install Clojure launcher: " .. launcher[1])
            end
        end
    end
    return true
end
