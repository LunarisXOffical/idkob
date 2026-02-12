local envLogger = {}

local function getSystemInfo()
  local info = {}
  
  -- Lua version
  info.luaVersion = _VERSION or "Unknown"
  
  -- OS info
  info.os = jit and "LuaJIT" or "Lua"
  
  -- Platform detection
  local success, platform = pcall(function() return package.config:sub(1,1) end)
  if success then
    info.pathSeparator = platform
  end
  
  return info
end

local function captureEnvironment()
  local env = {}
  
  -- Capture global functions available
  env.globals = {}
  for k, v in pairs(_G) do
    if type(v) == "function" then
      table.insert(env.globals, k)
    end
  end
  
  -- Capture loaded modules
  env.modules = {}
  if package.loaded then
    for k, v in pairs(package.loaded) do
      table.insert(env.modules, k)
    end
  end
  
  return env
end

function envLogger.log()
  local systemInfo = getSystemInfo()
  local environment = captureEnvironment()
  
  local log = {
    timestamp = os.time(),
    system = systemInfo,
    environment = environment
  }
  
  return log
end

function envLogger.toString(logData)
  local result = "=== Environment Log ===\n"
  result = result .. "Lua Version: " .. logData.system.luaVersion .. "\n"
  result = result .. "Runtime: " .. logData.system.os .. "\n"
  result = result .. "Loaded Modules: " .. #logData.environment.modules .. "\n"
  result = result .. "Available Functions: " .. #logData.environment.globals .. "\n"
  
  return result
end

return envLogger
