local wyrm = require "wyrm"
local Wyrm = wyrm.Wyrm

local function new_env()
    local w = Wyrm.new()
    w:load_module("lib/base.wyrm")
    return w
end

-- ---------------------------------------------------------------
-- do-times
-- ---------------------------------------------------------------

describe("do-times", function()
    it("runs zero times when n is 0", function()
        local w = new_env()
        local result = w:eval([[
var hits 0
do-times 0 { hits= [+ $hits 1] }
$hits
]])
        assert(result == 0)
    end)

    it("runs exactly n times", function()
        local w = new_env()
        local result = w:eval([[
var hits 0
do-times 5 { hits= [+ $hits 1] }
$hits
]])
        assert(result == 5)
    end)

    it("body sees and mutates outer scope", function()
        local w = new_env()
        local result = w:eval([[
var total 0
var step 0
do-times 4 do
  step= [+ $step 1]
  total= [+ $total $step]
end
$total
]])
        assert(result == 10) -- 1+2+3+4
    end)
end)

-- ---------------------------------------------------------------
-- while
-- ---------------------------------------------------------------

describe("while", function()
    it("does not execute body when condition is initially false", function()
        local w = new_env()
        local result = w:eval([[
var hits 0
while {< $hits 0} { hits= [+ $hits 1] }
$hits
]])
        assert(result == 0)
    end)

    it("loops until condition becomes false", function()
        local w = new_env()
        local result = w:eval([[
var i 0
while {< $i 5} { i= [+ $i 1] }
$i
]])
        assert(result == 5)
    end)

    it("re-evaluates condition each iteration", function()
        local w = new_env()
        local result = w:eval([[
var i 0
var total 0
while {< $i 3} do
  i= [+ $i 1]
  total= [+ $total $i]
end
$total
]])
        assert(result == 6) -- 1+2+3
    end)
end)

-- ---------------------------------------------------------------
-- for
-- ---------------------------------------------------------------

describe("for", function()
    it("iterates from start to count inclusive", function()
        local w = new_env()
        local result = w:eval([[
var total 0
for i 1 5 { total= [+ $total $i] }
$total
]])
        assert(result == 15) -- 1+2+3+4+5
    end)

    it("runs body at least once even when start exceeds count", function()
        local w = new_env()
        local result = w:eval([[
var hits 0
for i 5 3 { hits= [+ $hits 1] }
$hits
]])
        assert(result == 1)
    end)

    it("runs exactly once when start equals count", function()
        local w = new_env()
        local result = w:eval([[
var hits 0
for i 3 3 { hits= [+ $hits 1] }
$hits
]])
        assert(result == 1)
    end)

    it("loop variable is accessible inside body", function()
        local w = new_env()
        local result = w:eval([[
var last 0
for i 1 4 { last= $i }
$last
]])
        assert(result == 4)
    end)
end)

-- ---------------------------------------------------------------
-- cond
-- ---------------------------------------------------------------

describe("cond", function()
    it("returns value from first matching clause", function()
        local w = new_env()
        local result = w:eval([[
cond do
  {> 5 3} do
    1
  end
  {> 5 1} do
    2
  end
end
]])
        assert(result == 1)
    end)

    it("skips non-matching clauses", function()
        local w = new_env()
        local result = w:eval([[
cond do
  {< 5 3} do
    1
  end
  {> 5 3} do
    2
  end
end
]])
        assert(result == 2)
    end)

    it("falls through to default clause", function()
        local w = new_env()
        local result = w:eval([[
cond do
  {< 5 3} do
    1
  end
  {< 5 4} do
    2
  end
  true do
    3
  end
end
]])
        assert(result == 3)
    end)

    it("returns nil when no clause matches", function()
        local w = new_env()
        local result = w:eval([[
cond do
  {< 5 3} do
    1
  end
  {< 5 4} do
    2
  end
end
]])
        assert(result == nil)
    end)

    it("short-circuits: only first matching body executes", function()
        local w = new_env()
        local result = w:eval([[
var hits 0
cond do
  {> 5 3} do
    hits= [+ $hits 1]
  end
  true do
    hits= [+ $hits 10]
  end
end
$hits
]])
        assert(result == 1)
    end)
end)
