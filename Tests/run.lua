local suites = {
    dofile("Tests/RollStateTest.lua"),
    dofile("Tests/RollViewTest.lua"),
    dofile("Tests/RollControllerTest.lua"),
    dofile("Tests/PositionTest.lua"),
}

local passed = 0

for _, suite in ipairs(suites) do
    for _, test in ipairs(suite) do
        test()
        passed = passed + 1
    end
end

print(string.format("PASS: %d tests", passed))
