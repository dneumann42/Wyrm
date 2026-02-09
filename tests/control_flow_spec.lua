describe("Control flow", function()
    local Wyrm

    setup(function()
        Wyrm = require("wyrm").Wyrm
    end)

    describe("break", function()
        it("exits while loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                var count 0
                var n 0
                while {< $n 10} do
                    count= [+ $count 1]
                    if {= $n 5} do
                        break
                    end
                    n= [+ $n 1]
                end
                $count
            ]])
            assert.equals(6, result)  -- Should iterate 6 times (0-5)
        end)

        it("exits for loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                var count 0
                for i 1 10 do
                    count= [+ $count 1]
                    if {= $i 5} do
                        break
                    end
                end
                $count
            ]])
            assert.equals(5, result)
        end)

        it("exits do-times loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                var count 0
                do-times 10 do
                    count= [+ $count 1]
                    if {= $count 3} do
                        break
                    end
                end
                $count
            ]])
            assert.equals(3, result)
        end)
    end)

    describe("continue", function()
        it("skips to next iteration in while loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                var sum 0
                var n 0
                while {< $n 10} do
                    n= [+ $n 1]
                    if {= $n 5} do
                        continue
                    end
                    sum= [+ $sum $n]
                end
                $sum
            ]])
            -- Sum of 1-10 except 5 = 55 - 5 = 50
            assert.equals(50, result)
        end)

        it("skips to next iteration in for loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                var sum 0
                for i 1 10 do
                    if {= $i 5} do
                        continue
                    end
                    sum= [+ $sum $i]
                end
                $sum
            ]])
            assert.equals(50, result)
        end)

        it("skips to next iteration in do-times", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                var count 0
                var skip_count 0
                do-times 10 do
                    count= [+ $count 1]
                    if {= $count 5} do
                        skip_count= [+ $skip_count 1]
                        continue
                    end
                    skip_count= [+ $skip_count 1]
                end
                $skip_count
            ]])
            assert.equals(10, result)  -- All iterations run, one just continues early
        end)
    end)

    describe("return", function()
        it("returns value from function", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                fun get-value {} do
                    return 42
                end
                get-value
            ]])
            assert.equals(42, result)
        end)

        it("exits function early", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                fun check-value {x} do
                    if {< $x 10} do
                        return 99
                    end
                    return $x
                end
                check-value 5
            ]])
            assert.equals(99, result)
        end)

        it("returns from inside while loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                fun find-value {target} do
                    var n 0
                    while {< $n 20} do
                        if {= $n $target} do
                            return $n
                        end
                        n= [+ $n 1]
                    end
                    return -1
                end
                find-value 7
            ]])
            assert.equals(7, result)
        end)

        it("returns -1 when value not found in loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                fun find-value {target} do
                    var n 0
                    while {< $n 20} do
                        if {= $n $target} do
                            return $n
                        end
                        n= [+ $n 1]
                    end
                    return -1
                end
                find-value 99
            ]])
            assert.equals(-1, result)
        end)

        it("returns from inside for loop", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                fun find-even {} do
                    for i 1 10 do
                        if {= [lua "return " $i " % 2"] 0} do
                            return $i
                        end
                    end
                    return -1
                end
                find-even
            ]])
            assert.equals(2, result)
        end)
    end)

    describe("trampoline (recr)", function()
        it("handles deep recursion without stack overflow", function()
            local w = Wyrm.new()
            w:load_module("lib/base.wyrm")
            local result = w:eval([[
                var n 0
                while {< $n 10000} do
                    n= [+ $n 1]
                end
                $n
            ]])
            assert.equals(10000, result)
        end)
    end)
end)
