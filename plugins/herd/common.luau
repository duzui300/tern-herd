--!strict
-- Shared block identity, the inert host/window action mailbox, and quoting.

local M = {}

M.KIND = "herd.herd"
M.OPEN_ACTION = "plugin.herd.open"

-- Normalized hc list row, shared without per-observation projection copies.
export type Term = {
	address: string,
	name: string?,
	agent: string,
	cwd: string,
	-- Program's 7501 word, or running when no status is reported.
	status: string,
	state: string,
	turn: number?,
	where: string,
	parent: string?,
	exit_code: number?,
	reason: string?,
}

-- `hc` by name first, then common Windows and POSIX install locations.
local home = tern.getenv("HOME") or tern.getenv("USERPROFILE")
local local_appdata = tern.getenv("LOCALAPPDATA")
M.HOME = home
M.HC = { "hc" }
local paths: { string } = {}
if local_appdata and local_appdata ~= "" then
	table.insert(paths, local_appdata .. "\\Programs\\herdr-core\\hc.exe")
end
if home and home ~= "" then
	table.insert(paths, home .. "\\AppData\\Local\\Programs\\herdr-core\\hc.exe")
	table.insert(paths, home .. "/.local/bin/hc")
end
table.insert(paths, "/usr/local/bin/hc")
table.insert(paths, "/usr/bin/hc")
for _, path in paths do
	if not table.find(M.HC, path) then
		table.insert(M.HC, path)
	end
end

-- Shared kv keys for executable resolution and bounded run-scope preferences.
M.KV_HC = "hc_path"
M.KV_SCOPES = "recent_scopes"
M.KV_PANE_SCOPES = "pane_scopes"

function M.scope(value: any): string?
	if type(value) ~= "string" then return nil end
	local clean = string.match(value, "^%s*(.-)%s*$") or ""
	return if #clean > 0 and #clean <= 128 and not string.find(clean, "%c") then clean else nil
end

-- Current native layout of the exact registered read-only Watch pane.
export type ViewerState = "none" | "tiled" | "floating" | "parked"

-- Carried as inert root-node metadata, never as a URL/open effect. The
-- serial host worker grants each request to one window before it acts.
export type WindowRequest = {
	id: string,
	verb: string,
	address: string,
	label: string,
	hc: string,
	mode: ("read" | "write")?,
	agent: boolean?,
	expires: number,
	owner: string?,
	viewer_owner: string?,
	generation: number?,
	scopes: { string }?,
	selection: number?,
	path: string?,
	config: string?,
}

function M.is_windows_path(path: string): boolean
	return string.match(path, "^%a:[/\\]") ~= nil
end

function M.is_absolute(path: string): boolean
	return string.sub(path, 1, 1) == "/" or M.is_windows_path(path)
end

local function norm_slashes(path: string): string
	return (string.gsub(path, "\\", "/"))
end

function M.tilde(path: string): string
	if not home or home == "" then
		return path
	end
	local win = M.is_windows_path(home)
	local np = string.gsub(norm_slashes(path), "/+$", "")
	local nh = string.gsub(norm_slashes(home), "/+$", "")
	local cmp_p = if win then string.lower(np) else np
	local cmp_h = if win then string.lower(nh) else nh
	if cmp_p == cmp_h then
		return "~"
	end
	if string.sub(cmp_p, 1, #cmp_h + 1) == cmp_h .. "/" then
		local sep = if string.find(path, "\\", 1, true) and not string.find(path, "/", 1, true) then "\\" else "/"
		return "~" .. sep .. string.sub(path, #nh + 2)
	end
	return path
end

function M.leaf(cwd: string): string
	if cwd == "" then
		return ""
	end
	if home and home ~= "" and M.tilde(cwd) == "~" then
		return "~"
	end
	return string.match(cwd, "([^/\\]+)[/\\]*$") or cwd
end

function M.split_parent_leaf(path: string): (string?, string?)
	local clean = string.gsub(path, "[/\\]+$", "")
	local dir, leaf = string.match(clean, "^(.*[/\\])([^/\\]+)$")
	return dir, leaf
end

-- Quotes one command argument for POSIX shells or Windows PowerShell/cmd.
function M.quote(s: string, windows: boolean?): string
	if windows then
		if string.match(s, "^[%w%-%._/=:@\\]+$") then
			return s
		end
		return '"' .. (string.gsub(s, '"', '\\"')) .. '"'
	end
	if string.match(s, "^[%w%-%._/=:@]+$") then
		return s
	end
	return "'" .. (string.gsub(s, "'", "'\\''")) .. "'"
end

return M
