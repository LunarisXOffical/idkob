class LuaObfuscator {
  constructor() {
    this.stringPool = [];
    this.variableMap = {};
    this.functionMap = {};
    this.counter = 0;
  }

  obfuscate(code) {
    let obfuscated = code;
    
    obfuscated = this.obfuscateStrings(obfuscated);
    obfuscated = this.obfuscateVariables(obfuscated);
    obfuscated = this.obfuscateFunctions(obfuscated);
    obfuscated = this.removeComments(obfuscated);
    obfuscated = this.minifyCode(obfuscated);
    obfuscated = this.addAntiDebug(obfuscated);
    
    return obfuscated;
  }

  obfuscateStrings(code) {
    let result = code;
    let stringIndex = 0;
    
    const stringRegex = /(['"])(?:(?=(\\?))\2.)*?\1/g;
    
    result = result.replace(stringRegex, (match) => {
      this.stringPool[stringIndex] = match;
      return `__STR${stringIndex++}__`;
    });

    const stringInit = this.stringPool.length > 0 
      ? `local __STRINGS={${this.stringPool.map(s => s).join(',')}} ` 
      : '';
    
    return stringInit + result;
  }

  obfuscateVariables(code) {
    let result = code;
    const varPattern = /local\s+([a-zA-Z_][a-zA-Z0-9_]*)/g;
    const variables = new Set();
    
    let match;
    while ((match = varPattern.exec(code)) !== null) {
      variables.add(match[1]);
    }

    variables.forEach((varName) => {
      if (varName !== 'self' && !varName.startsWith('__')) {
        const obfuscatedName = `_${this.generateHash(varName)}`;
        this.variableMap[varName] = obfuscatedName;
        const regex = new RegExp(`\\b${varName}\\b`, 'g');
        result = result.replace(regex, obfuscatedName);
      }
    });

    return result;
  }

  obfuscateFunctions(code) {
    let result = code;
    const funcPattern = /function\s+([a-zA-Z_][a-zA-Z0-9_]*)/g;
    
    let match;
    while ((match = funcPattern.exec(code)) !== null) {
      const funcName = match[1];
      if (!funcName.startsWith('__')) {
        const obfuscatedName = `_f${this.generateHash(funcName)}`;
        this.functionMap[funcName] = obfuscatedName;
        const regex = new RegExp(`\\b${funcName}\\b`, 'g');
        result = result.replace(regex, obfuscatedName);
      }
    }

    return result;
  }

  removeComments(code) {
    let result = code;
    
    result = result.replace(/--\[\[[\s\S]*?\]\]/g, '');
    result = result.replace(/--.*$/gm, '');
    
    return result;
  }

  minifyCode(code) {
    let result = code;
    
    result = result.replace(/\s+/g, ' ');
    result = result.replace(/\s*([{}()\[\];,=+\-*/<>:])\s*/g, '$1');
    result = result.replace(/;\s*;+/g, ';');
    
    return result.trim();
  }

  addAntiDebug(code) {
    const antiDebug = `
local __D=debug if __D then 
  __D.sethook(nil) 
end `;
    return antiDebug + code;
  }

  generateHash(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
    }
    return Math.abs(hash).toString(36);
  }
}

module.exports = LuaObfuscator;
