local source = [[
fein hawk "Hello world!" tuah
]]

-- configs

local printSource = true
local compileToFeincode = false

local operators = {
    ["head so good"] = "while",
    ["go go go go"] = "do",
    ["never see me again"] = "end",
    ["and you know me"] = "if",
    ["im the bomb"] = "then",
    ["bomb"] = "else",
    ["yeah im the bomb"] = "elseif",
    ["love all my supporters its time"] = "return",
    ["fein"] = "print",
    ["runaway"] = "local",
    ["sigma"] = "true",
    ["skibidi"] = "false",
    ["as fast as you can "] = "_G.",
    ["hawk"] = "(",
    ["tuah"] = ")",
    ["diddy party"] = "function",
    ["twin"] = "==",
    ["edges"] = "<",
    ["busts"] = ">",
    ["gyatt"] = "for",
    ["jelqs"] = "=",
    ["dominant"] = "+",
    ["submissive"] = "-",
}

function reverseTable(tbl)
    local reversed = {}
    for key, value in pairs(tbl) do
        reversed[value] = key
    end
    return reversed
end

if compileToFeincode then
  operators = reverseTable(operators)
end

-- lexer

local sortedOperators = {}
for phrase in pairs(operators) do
    table.insert(sortedOperators, phrase)
end
table.sort(sortedOperators, function(a, b) return #a > #b end)

local function escape_pattern(text)
    return text:gsub("([^%w])", "%%%1")
end

local function replace_outside_quotes(source)
    local result = {}
    local inside_string = false
    local current_string = ""
    
    for line in source:gmatch("[^\n]*\n?") do
        local processed_line = ""
        local i = 1

        while i <= #line do
            local char = line:sub(i, i)

            if char == '"' then
                inside_string = not inside_string
            end

            if inside_string then
                processed_line = processed_line .. char
            else
                local replaced = false
                for _, phrase in ipairs(sortedOperators) do
                    local pattern = "^" .. escape_pattern(phrase)
                    local match = line:sub(i):match(pattern)
                    if match then
                        processed_line = processed_line .. operators[phrase]
                        i = i + #phrase - 1
                        replaced = true
                        break
                    end
                end

                if not replaced then
                    processed_line = processed_line .. char
                end
            end

            i = i + 1
        end

        table.insert(result, processed_line)
    end

    return table.concat(result)
end

source = replace_outside_quotes(source)

-- environment

local env = {
    i = 0,
    t = setmetatable({}, {__index = function() return 0 end}),
    read = function() return io.stdin:read(1):byte() end,
    write = function(c) io.stdout:write(string.char(c)) end,

    -- custom functions
    wait = function(t)
        t = t or 0.01
        local start = os.clock()
        while os.clock() - start < t do
        end
    end,
    
    printTest = function(t)
        print(t)
    end,
}

setmetatable(env, {__index = function(t, k)
    return rawget(t, k) or _G[k]
end,
__newindex = function(t, k, v)
    rawset(t, k, v)
end })

source = replace_outside_quotes(source)

if printSource then
    print("--------------------SOURCE--------------------")
    print(source)
    print("------------------END SOURCE------------------")
end

-- runtime

if not compileToFeincode then
  local func, err = load(source, "fein.lua", "t", env) or loadstring(source, "fein.lua", "t", env)
  
  if func then
      local status, runtimeErr = pcall(func)
      if not status then
          print("Runtime error in translated code:", runtimeErr)
      end
  else
      print("Error in translated code:", err)
  end
end
