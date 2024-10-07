local source = [[
and you know me 2==1 im the bomb 
fein("yes")
yeah im the bomb 2==2 im the bomb
fein("no") 
never see me again
]]

-- configs

local printSource = true

local operators = {
    ["go go go go"] = "while true do",
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
}

-- lexer

local sortedOperators = {}
for phrase in pairs(operators) do
    table.insert(sortedOperators, phrase)
end
table.sort(sortedOperators, function(a, b) return #a > #b end)

for _, phrase in ipairs(sortedOperators) do
    local replacement = operators[phrase]
    source = string.gsub(source, phrase, replacement)
end

if printSource then
  print("--------------------SOURCE--------------------")
    print(source)
  print("------------------END SOURCE------------------")
end

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
}

setmetatable(env, {__index = function(t, k)
    return _G[k] or t.t[t.i]
end,
__newindex = function(t, k, v)
    t.t[t.i] = v
end })

-- runtime

local func, err = load(source, "fein.lua", "t", env)

if func then
    local status, runtimeErr = pcall(func)
    if not status then
        print("Runtime error in translated code:", runtimeErr)
    end
else
    print("Error in translated code:", err)
end
