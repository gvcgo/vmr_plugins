--[[
    Rustup installation
--]]

-- global variables
sdk_name = "rustup"
plugin_name = "rustup"
plugin_version = "0.1"
prequisite = ""
homepage = "https://rustup.rs/"

-- installer config
ic = vmrNewInstallerConfig()
ic = vmrAddFlagFiles(ic, "windows", { "rustup-init.exe" })
ic = vmrAddFlagFiles(ic, "linux", { "rustup-init" })
ic = vmrAddFlagFiles(ic, "darwin", { "rustup-init" })
ic = vmrEnableFlagDirExcepted(ic)

latestRustup = {
    "https://static.rust-lang.org/rustup/dist/x86_64-apple-darwin/rustup-init",
    "https://static.rust-lang.org/rustup/dist/aarch64-apple-darwin/rustup-init",
    "https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init",
    "https://static.rust-lang.org/rustup/dist/aarch64-unknown-linux-gnu/rustup-init",
    "https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe",
    "https://static.rust-lang.org/rustup/dist/aarch64-pc-windows-msvc/rustup-init.exe",
}

function parseOs(u)
    if vmrContains(u, "windows") then
        return "windows"
    end
    if vmrContains(u, "linux") then
        return "linux"
    end
    if vmrContains(u, "darwin") then
        return "darwin"
    end
    return ""
end

function parseArch(u)
    if vmrContains(u, "x86_64") then
        return "amd64"
    end
    if vmrContains(u, "aarch64") then
        return "arm64"
    end
    return ""
end

os, arch = vmrGetOsArch()
-- spider
function crawl()
    local versionList = vmrNewVersionList()

    for i, url in ipairs(latestRustup) do
        local itemOs = parseOs(url)
        local itemArch = parseArch(url)
        if itemOs == os and itemArch == arch then
            local item = {}
            item["url"] = url
            item["os"] = os
            item["arch"] = arch
            item["installer"] = "executable"
            vmrAddItem(versionList, "latest", item)
        end
    end

    return versionList
end

-- TODO: post install handler
function postInstall(install_path)

end
