mjlocal obfuscator = require("src.obfuscator")
local envLogger = require("src.envLogger")
local fileHandler = require("src.fileHandler")

local function main(inputFile, outputFile)
  print("=" .. string.rep("=", 48) .. "=")
  print("  Lua Obfuscator v1.0 with Environment Logger")
  print("=" .. string.rep("=", 48) .. "=")
  print()

  -- Log environment information
  print("[*] Logging environment information...")
  envLogger.logEnvironment()
  print()

  -- Validate input file
  if not inputFile then
    error("Error: Input file path required!")
  end

  -- Read the input file
  print("[*] Reading input file: " .. inputFile)
  local sourceCode = fileHandler.readFile(inputFile)
  if not sourceCode then
    error("Error: Could not read input file!")
  end

  print("[✓] File read successfully (" .. #sourceCode .. " bytes)")
  print()

  -- Perform obfuscation
  print("[*] Starting obfuscation process...")
  local startTime = os.clock()
  local obfuscatedCode = obfuscator.obfuscate(sourceCode)
  local endTime = os.clock()

  print("[✓] Obfuscation completed in " .. string.format("%.3f", endTime - startTime) .. " seconds")
  print("[✓] Obfuscated code size: " .. #obfuscatedCode .. " bytes")
  print()

  -- Determine output file
  outputFile = outputFile or inputFile:gsub("%.lua$", "_obfuscated.lua")

  -- Write obfuscated code to file
  print("[*] Writing obfuscated code to: " .. outputFile)
  if fileHandler.writeFile(outputFile, obfuscatedCode) then
    print("[✓] File written successfully!")
  else
    error("Error: Could not write output file!")
  end

  print()
  print("=" .. string.rep("=", 48) .. "=")
  print("  Obfuscation Complete!")
  print("=" .. string.rep("=", 48) .. "=")
end

-- Get command line arguments
local args = {...}
if #args == 0 then
  print("Usage: lua main.lua <input.lua> [output.lua]")
  print()
  print("Example:")
  print("  lua main.lua script.lua obfuscated.lua")
  print("  lua main.lua script.lua")
  return
end

main(args[1], args[2])
