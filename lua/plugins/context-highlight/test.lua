-- Copyright (c) 2025 Antenore Gatta
-- Licensed under the MIT License. See LICENSE file in the project root for details.

-- Test file for context highlighting plugin
-- This demonstrates multi-level scope dimming + symbol highlighting

-- Global configuration
local CONFIG = {
  max_retries = 3,
  timeout = 5000,
  debug = false
}

-- Utility function to validate input
local function validate_data(data, min_length)
  if not data then
    return false, "Data is nil"
  end

  if #data < min_length then
    return false, "Data too short"
  end

  return true, "Valid"
end

-- Process a list of numbers with filtering and transformation
local function process_numbers(numbers, threshold)
  local result = {}
  local total = 0
  local filtered_count = 0

  -- Filter and process each number
  for index, value in ipairs(numbers) do
    if value > threshold then
      local transformed = value * 2
      table.insert(result, transformed)
      total = total + transformed
      filtered_count = filtered_count + 1

      -- Nested condition for special values
      if value > 100 then
        if CONFIG.debug then
          print("Large value detected:", value)
        end
      end
    end
  end

  return result, total, filtered_count
end

-- Calculate statistics with error handling
local function calculate_statistics(dataset)
  local valid, error_msg = validate_data(dataset, 1)

  if not valid then
    return nil, error_msg
  end

  local sum = 0
  local count = 0
  local max_val = dataset[1]
  local min_val = dataset[1]

  -- Main calculation loop
  for _, value in ipairs(dataset) do
    sum = sum + value
    count = count + 1

    if value > max_val then
      max_val = value
    end

    if value < min_val then
      min_val = value
    end
  end

  local average = sum / count

  return {
    sum = sum,
    count = count,
    average = average,
    max = max_val,
    min = min_val
  }
end

-- Main entry point
local function main()
  -- Initialize test data
  local test_data = {15, 42, 7, 23, 156, 91, 8, 234, 19, 67}
  local threshold = 20

  print("Processing with threshold:", threshold)

  -- Process the data
  local processed, total, count = process_numbers(test_data, threshold)

  print(string.format("Processed %d items, total: %d", count, total))

  -- Calculate statistics
  local stats = calculate_statistics(test_data)

  if stats then
    print("Statistics:")
    print("  Sum:", stats.sum)
    print("  Average:", stats.average)
    print("  Max:", stats.max)
    print("  Min:", stats.min)
  end

  -- Test retry logic
  local attempts = 0
  local success = false

  while attempts < CONFIG.max_retries and not success do
    attempts = attempts + 1

    -- Simulate operation
    if attempts >= 2 then
      success = true
      print("Operation succeeded on attempt", attempts)
    else
      print("Attempt", attempts, "failed, retrying...")
    end
  end

  return processed, stats
end

-- TESTING INSTRUCTIONS:
-- ====================
--
-- 1. MULTI-LEVEL DIMMING TEST:
--    - Put cursor in the "for index, value" loop inside process_numbers()
--      → Inner loop: BRIGHTEST
--      → process_numbers function: MEDIUM BRIGHT
--      → Everything else (main, calculate_statistics, etc): DIMMED
--
-- 2. SYMBOL HIGHLIGHTING TEST:
--    - Put cursor on "value" inside the loop
--      → All "value" occurrences in process_numbers highlighted
--    - Put cursor on "CONFIG" at top of file
--      → All CONFIG references highlighted (even in dimmed areas!)
--    - Put cursor on "threshold" parameter
--      → All threshold uses highlighted
--
-- 3. SCOPE NAVIGATION:
--    - Move between functions and watch dimming shift
--    - Enter nested if statements - see gradual dimming levels
--    - Move to while loop - see main() brighten, others dim
--
-- 4. VERIFY COLOR SCHEME INTEGRATION:
--    - Change your colorscheme (:colorscheme <name>)
--    - Plugin should adapt dimming to new background automatically

return main()
