local Helpers = {}

function Helpers.assertEqual(actual, expected, message)
    if actual ~= expected then
        error(string.format(
            "%s: expected %s, got %s",
            message or "values differ",
            tostring(expected),
            tostring(actual)
        ), 2)
    end
end

function Helpers.assertSame(actual, expected, message)
    for key, value in pairs(expected) do
        Helpers.assertEqual(actual[key], value, message .. "." .. key)
    end
end

return Helpers
