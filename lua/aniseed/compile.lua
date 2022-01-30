local _2afile_2a = "fnl/aniseed/compile.fnl"
local _2amodule_name_2a = "aniseed.compile"
local _2amodule_2a
do
  package.loaded[_2amodule_name_2a] = {}
  _2amodule_2a = package.loaded[_2amodule_name_2a]
end
local _2amodule_locals_2a
do
  _2amodule_2a["aniseed/locals"] = {}
  _2amodule_locals_2a = (_2amodule_2a)["aniseed/locals"]
end
local autoload = (require("aniseed.autoload")).autoload
local a, fennel, fs, nvim, s = autoload("aniseed.core"), autoload("aniseed.fennel"), autoload("aniseed.fs"), autoload("aniseed.nvim"), autoload("aniseed.string")
do end (_2amodule_locals_2a)["a"] = a
_2amodule_locals_2a["fennel"] = fennel
_2amodule_locals_2a["fs"] = fs
_2amodule_locals_2a["nvim"] = nvim
_2amodule_locals_2a["s"] = s
local function macros_strs(mods)
  local function _1_(_241)
    return string.format("(require-macros \"%s\")", _241)
  end
  local function _2_()
    if a["string?"](mods) then
      return {mods}
    else
      return mods
    end
  end
  return s.join("\n", a.map(_1_, a.concat({"aniseed.macros"}, _2_())))
end
_2amodule_2a["macros-strs"] = macros_strs
local function macros_prefix(code, opts)
  local macros_modules = macros_strs(a.get(opts, "macros"))
  local filename
  do
    local _3_ = a.get(opts, "filename")
    if (nil ~= _3_) then
      local _4_ = string.gsub(_3_, (nvim.fn.getcwd() .. fs["path-sep"]), "")
      if (nil ~= _4_) then
        filename = string.gsub(_4_, "\\", "\\\\")
      else
        filename = _4_
      end
    else
      filename = _3_
    end
  end
  return string.format("(local *file* \"%s\")\n%s\n(wrap-module-body\n%s\n)", (filename or "nil"), macros_modules, (code or ""))
end
_2amodule_2a["macros-prefix"] = macros_prefix
local marker_prefix = "ANISEED_"
_2amodule_2a["marker-prefix"] = marker_prefix
local delete_marker = (marker_prefix .. "DELETE_ME")
do end (_2amodule_2a)["delete-marker"] = delete_marker
local delete_marker_pat = ("\n[^\n]-\"" .. delete_marker .. "\".-")
do end (_2amodule_locals_2a)["delete-marker-pat"] = delete_marker_pat
local function str(code, opts)
  ANISEED_STATIC_MODULES = (true == a.get(opts, "static?"))
  local fnl = fennel.impl()
  local function _7_()
    return string.gsub(string.gsub(fnl.compileString(macros_prefix(code, opts), a["merge!"]({allowedGlobals = false, compilerEnv = _G}, opts)), (delete_marker_pat .. "\n"), "\n"), (delete_marker_pat .. "$"), "")
  end
  return xpcall(_7_, fnl.traceback)
end
_2amodule_2a["str"] = str
local function file(src, dest, opts)
  local code = a.slurp(src)
  local _8_, _9_ = str(code, a["merge!"]({filename = src, ["static?"] = true}, opts))
  if ((_8_ == false) and (nil ~= _9_)) then
    local err = _9_
    return nvim.err_writeln(err)
  elseif ((_8_ == true) and (nil ~= _9_)) then
    local result = _9_
    fs.mkdirp(fs.basename(dest))
    return a.spit(dest, result)
  else
    return nil
  end
end
_2amodule_2a["file"] = file
local function glob(src_expr, src_dir, dest_dir, opts)
  for _, path in ipairs(fs.relglob(src_dir, src_expr)) do
    if fs["macro-file-path?"](path) then
      a.spit((dest_dir .. path), a.slurp((src_dir .. path)))
    else
      file((src_dir .. path), string.gsub((dest_dir .. path), ".fnl$", ".lua"), opts)
    end
  end
  return nil
end
_2amodule_2a["glob"] = glob
