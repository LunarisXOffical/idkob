local obfuscator = {}

local stringPool = {}
local variableMap = {}
local functionMap = {}
local obfuscationCounter = 0

local function generateObfuscatedName(prefix)
  obfuscationCounter = obfuscationCounter + 1
  return prefix .. "_" .. obfuscationCounter
end

local function obfuscateVariableNames(code)
  -- Simple variable name obfuscation
  local obfuscated = code
  local vars = {}
  
  -- Match local variable declarations
  for varName in code:gmatch("local%s+([a-zA-Z_][a-zA-Z0-9_]*)") do
    if not vars[varName] and varName ~= "self" then
      vars[varName] = generateObfuscatedName("_v")
    end
  end
  
  -- Replace variable names
  for original, obfuscated_name in pairs(vars) do
    obfuscated = obfuscated:gsub("%f[%a_]" .. original .. "%f[%A_]", obfuscated_name)
  end
  
  return obfuscated
end

local function obfuscateStrings(code)
  -- Collect all strings
  local strings = {}
  local stringIndex = 0
  
  -- Match string literals
  local obfuscated = code:gsub('(["\'])([^%1]*?)%1', function(quote, str)
    stringIndex = stringIndex + 1
    strings[stringIndex] = str
    return "_STR_" .. stringIndex
  end)
  
  stringPool = strings
  return obfuscated
end

local function stringDecoder(strings)
  -- Returns a function that decodes obfuscated strings at runtime
  local decoder = "local _STRINGS = {"
  for i, str in ipairs(strings) do
    decoder = decoder .. string.format("[%d]=%q,", i, str)
  end
  decoder = decoder .. "}"
  decoder = decoder .. "\nlocal function _STR_(id) return _STRINGS[id] end\n"
  return decoder
end

local function obfuscateControl(code)
  -- Add dummy control flow
  local obfuscated = code
  
  -- Insert dummy variables
  obfuscated = "local _x,_y,_z = 0,1,2\n" .. obfuscated
  
  -- Add junk code segments
  local junk = [[
if _x == 999999 then
  local _dummy = function() end
  _dummy()
end
]]
  obfuscated = obfuscated .. "\n" .. junk
  
  return obfuscated
end

local function addAntiTamper(code)
  -- Add basic anti-tamper checks
  local antiTamper = [[
-- Anti-tamper protection
local _verify = getfenv()._verify or true
if type(_verify) == "function" then
  _verify()
end
]]
  return antiTamper .. "\n" .. code
end

function obfuscator.obfuscate(code)
  -- Apply obfuscation techniques in sequence
  local result = code
  
  -- Step 1: String obfuscation
  result = obfuscateStrings(result)
  
  -- Step 2: Variable name mangling
  result = obfuscateVariableNames(result)
  
  -- Step 3: Add string decoder
  result = stringDecoder(stringPool) .. result
  
  -- Step 4: Control flow obfuscation
  result = obfuscateControl(result)
  
  -- Step 5: Add anti-tamper protection
  result = addAntiTamper(result)
  
  return result
end

function obfuscator.setStringPool(pool)
  stringPool = pool
end

function obfuscator.getStringPool()
  return stringPool
end

return obfuscator
