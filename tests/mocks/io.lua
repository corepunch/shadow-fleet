--- Mock I/O Module
--- Provides mock implementations for input/output during testing
---
--- This module enables automated testing by capturing output and
--- providing pre-scripted input, eliminating the need for interactive
--- terminal sessions during tests.
---
--- @module tests.mocks.io

local mock_io = {}

--- Create a new mock output function that captures output
--- @return function Mock output function
--- @return table Captured output lines
function mock_io.create_output()
    local captured = {}
    
    local function mock_output(...)
        local args = {...}
        local text
        
        if #args > 0 then
            if #args == 1 then
                text = args[1]
            else
                text = string.format(args[1], select(2, ...))
            end
        else
            text = ""
        end
        
        table.insert(captured, text)
    end
    
    return mock_output, captured
end

--- Create a mock read_char function with pre-scripted input
--- @param inputs table Array of characters to return sequentially
--- @return function Mock read_char function
function mock_io.create_read_char(inputs)
    inputs = inputs or {}
    local index = 0
    
    return function(echo_input)
        index = index + 1
        if index <= #inputs then
            return inputs[index]
        else
            return nil  -- EOF
        end
    end
end

--- Create a mock read_line function with pre-scripted input
--- @param inputs table Array of lines to return sequentially
--- @return function Mock read_line function
function mock_io.create_read_line(inputs)
    inputs = inputs or {}
    local index = 0
    
    return function(echo_input)
        index = index + 1
        if index <= #inputs then
            return inputs[index]
        else
            return nil  -- EOF
        end
    end
end

--- Create a complete mock I/O environment
--- @param char_inputs table Array of characters for read_char
--- @param line_inputs table Array of lines for read_line
--- @return table Mock environment with output_fn, read_char, read_line, and captured output
function mock_io.create_environment(char_inputs, line_inputs)
    local mock_output, captured = mock_io.create_output()
    
    return {
        output_fn = mock_output,
        read_char = mock_io.create_read_char(char_inputs),
        read_line = mock_io.create_read_line(line_inputs),
        captured = captured
    }
end

--- Assert that output contains a specific string
--- @param captured table Array of captured output strings
--- @param expected string String to search for
--- @param error_msg string Optional error message
function mock_io.assert_output_contains(captured, expected, error_msg)
    local full_output = table.concat(captured)
    if not full_output:find(expected, 1, true) then
        error_msg = error_msg or string.format("Expected output to contain '%s'", expected)
        error(error_msg)
    end
end

--- Assert that output does not contain a specific string
--- @param captured table Array of captured output strings
--- @param unexpected string String that should not appear
--- @param error_msg string Optional error message
function mock_io.assert_output_not_contains(captured, unexpected, error_msg)
    local full_output = table.concat(captured)
    if full_output:find(unexpected, 1, true) then
        error_msg = error_msg or string.format("Expected output to NOT contain '%s'", unexpected)
        error(error_msg)
    end
end

--- Get full output as a single string
--- @param captured table Array of captured output strings
--- @return string Full output text
function mock_io.get_full_output(captured)
    return table.concat(captured)
end

--- Clear captured output
--- @param captured table Array of captured output strings
function mock_io.clear_output(captured)
    for i = 1, #captured do
        captured[i] = nil
    end
end

return mock_io
