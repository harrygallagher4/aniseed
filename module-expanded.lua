local module_name, module, module_locals, autoload, fs, a, fennel = nil, nil, nil, nil, nil, nil, nil
do
  local module_name0 = "aniseed.macros-scratch"
  local module0
  do
    package.loaded[module_name0] = {}
    module0 = package.loaded[module_name0]
  end
  local module_locals0
  do
    module0["aniseed/locals"] = {}
    module_locals0 = (module0)["aniseed/locals"]
  end
  local autoload0 = (require("aniseed.autoload")).autoload
  local fs0 = autoload0("aniseed.fs")
  local a0 = require("aniseed.core")
  local fennel0 = require("fennel")
  do end 
  module_locals0["*module-name*"] = module_name0
  module_locals0["*module*"] = module0
  module_locals0["*module-locals*"] = module_locals0
  module_locals0["autoload"] = autoload0
  module_locals0["fs"] = fs0
  module_locals0["a"] = a0
  module_locals0["fennel"] = fennel0
  module_name, module, module_locals, autoload, fs, a, fennel = module_name0, module0, module_locals0, autoload0, fs0, a0, fennel0
end
return nil
