local _2amodule_name_2a, _2amodule_2a, _2amodule_locals_2a, a, fennel = nil, nil, nil, nil, nil
do
  local _2amodule_name_2a0 = "testfile"
  local _2amodule_2a0
  do
    package.loaded[_2amodule_name_2a0] = {}
    _2amodule_2a0 = package.loaded[_2amodule_name_2a0]
  end
  local _2amodule_locals_2a0
  do
    _2amodule_2a0["aniseed/locals"] = {}
    _2amodule_locals_2a0 = (_2amodule_2a0)["aniseed/locals"]
  end
  local a0 = require("miniseed")
  local fennel0 = require("fennel")
  do end (_2amodule_locals_2a0)["a"] = a0
  _2amodule_locals_2a0["fennel"] = fennel0
  _2amodule_name_2a, _2amodule_2a, _2amodule_locals_2a, a, fennel = _2amodule_name_2a0, _2amodule_2a0, _2amodule_locals_2a0, a0, fennel0
end
local x_internal
do
  local x_internal0 = {internal = true}
  _2amodule_locals_2a["x-internal"] = x_internal0
  x_internal = x_internal0
end
local y_public
do
  local y_public0 = {internal = false}
  _2amodule_2a["y-public"] = y_public0
  y_public = y_public0
end
local do_internal_thing
do
  local do_internal_thing0
  local function do_internal_thing1(...)
    return print(...)
  end
  do_internal_thing0 = do_internal_thing1
  _2amodule_locals_2a["do-internal-thing"] = do_internal_thing0
  do_internal_thing = do_internal_thing0
end
local do_other_thing
do
  local do_other_thing0
  local function do_other_thing1(...)
    return print(...)
  end
  do_other_thing0 = do_other_thing1
  _2amodule_2a["do-other-thing"] = do_other_thing0
  do_other_thing = do_other_thing0
end
return fennel.view(_2amodule_2a)
