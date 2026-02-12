local codeInjector = {}

local function validateCode(code)
  -- Basic validation to check for obviously malicious patterns
  local dangerous = {
    "os.execute",
    "io.open",
    "loadfile",
    "dofile"
  }
  
  for _, pattern in ipairs(dangerous) do
    if string.find(code, pattern) then
      return false
    end
  end
  
  return true
end

function codeInjector.inject(code, env)
  -- Validate the code first
  if not validateCode(code) then
    return nil, "Code contains potentially dangerous functions"
  end
  
  -- Create an isolated environment
  local sandbox = setmetatable({}, {__index = env or _G})
  
  -- Attempt to load and execute the code
  local func, err = load(code, "injected", "t", sandbox)
  if not func then
    return nil, err
  end
  
  -- Execute in protected mode
  local success, result = pcall(func)
  if not success then
    return nil, result
  end
  
  return result
end

function codeInjector.injectFile(filePath, env)
  local file = io.open(filePath, "r")
  if not file then
    return nil, "File not found: " .. filePath
  end
  
  local code = file:read("*a")
  file:close()
  
  return codeInjector.inject(code, env)
end

return codeInjector
