local input_file, error_msg = io.open("inputs\\day3input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

PartNumber = {};

function PartNumber.New(starting_idx)
    local res = {};
    res.number = 0;
    res.start_idx = starting_idx - 1;
    res.end_idx = starting_idx;
    res.is_attached = false;

    return res;
end

function PartNumber.AddDigit(part, next_digit)
    local curr_num_string = tostring(part.number);
    local new_num_string = curr_num_string .. next_digit;
    part.number = tonumber(new_num_string);
    part.end_idx = part.end_idx + 1;
end

function SolveFirstPart()
    local solution = 0;

    local previous_numbers = {};
    local previous_symbols = {};

    for line in input_file:lines() do
        local current_numbers = {};
        local current_symbols = {};
        local col = 0;

        local current_number = nil;
        local auto_attach = false;

        for char in string.gmatch(line, ".") do
            col = col + 1;

            -- we found a digit, add to current number
            if string.find(char, "%d") then
                current_number = current_number or PartNumber.New(col);
                PartNumber.AddDigit(current_number, char);
                current_number.is_attached = current_number.is_attached or auto_attach;
                auto_attach = false;
            else
                auto_attach = false;

                -- we found a symbol
                if string.find(char, "[^.]") then
                    auto_attach = true;
                    table.insert(current_symbols, col);
                end

                if current_number then
                    current_number.is_attached = current_number.is_attached or auto_attach;
                    table.insert(current_numbers, current_number);
                    current_number = nil;
                end
            end
        end

        -- end of the line, close a number
        if current_number then
            table.insert(current_numbers, current_number);
            current_number = nil;
        end

        -- post line processing
        -- case 1 - for each current number check if there is a symbol above them
        for i = #current_numbers, 1, -1 do
            local part = current_numbers[i];
            if part.is_attached then
                solution = solution + part.number;
                table.remove(current_numbers, i);
            else
                for _, symbol in ipairs(previous_symbols) do
                    if part.start_idx <= symbol and part.end_idx >= symbol then
                        solution = solution + part.number;
                        table.remove(current_numbers, i);
                        break;
                    end
                end
            end
        end

        -- case 2 - for each current symbol, check if there is a number above them
        for _, symbol in ipairs(current_symbols) do
            for i = #previous_numbers, 1, -1 do
                local part = previous_numbers[i];
                if part.start_idx <= symbol and part.end_idx >= symbol then
                    solution = solution + part.number;
                    table.remove(previous_numbers, i);
                end
            end
        end

        previous_symbols = current_symbols;
        previous_numbers = current_numbers;
    end
    input_file:seek("set", 0);

    print("First part solution!");
    print(string.format("The solution is %d", solution));
end

function GetGearRatio(gear_middle_pos, upper_parts, middle_parts, lower_parts)
    local adjacent_parts = {};

    if upper_parts then
        for _, part in ipairs(upper_parts) do
            if part.start_idx <= gear_middle_pos and part.end_idx >= gear_middle_pos then
                table.insert(adjacent_parts, part);
            end
        end
    end

    assert(middle_parts);
    for _, part in ipairs(middle_parts) do
        if part.start_idx <= gear_middle_pos and part.end_idx >= gear_middle_pos then
            table.insert(adjacent_parts, part);
        end
    end

    if lower_parts then
        for _, part in ipairs(lower_parts) do
            if part.start_idx <= gear_middle_pos and part.end_idx >= gear_middle_pos then
                table.insert(adjacent_parts, part);
            end
        end
    end

    if #adjacent_parts == 2 then
        return adjacent_parts[1].number * adjacent_parts[2].number;
    else
        return 0
    end
end

function SolveSecondPart()
    local solution = 0;

    local upper_parts = nil;
    local middle_parts = nil;
    local lower_parts = nil;

    local upper_gears = nil;
    local middle_gears = nil;
    local lower_gears = nil;

    for line in input_file:lines() do
        local col = 0;

        local current_part = nil;

        upper_parts = middle_parts;
        middle_parts = lower_parts;
        upper_gears = middle_gears;
        middle_gears = lower_gears;

        lower_parts = {};
        lower_gears = {};

        for char in string.gmatch(line, ".") do
            col = col + 1;

            -- we found a digit, add to current number
            if string.find(char, "%d") then
                current_part = current_part or PartNumber.New(col);
                PartNumber.AddDigit(current_part, char);
            else
                -- we found a gear
                if char == "*" then
                    table.insert(lower_gears, col);
                end

                if current_part then
                    table.insert(lower_parts, current_part);
                    current_part = nil;
                end
            end
        end

        -- end of the line, close a number
        if current_part then
            table.insert(lower_parts, current_part);
            current_part = nil;
        end

        if middle_gears then
            for _, gear in ipairs(middle_gears) do
                solution = solution + GetGearRatio(gear, upper_parts, middle_parts, lower_parts);
            end
        end
    end

    -- we need to process the last line as well
    for _, gear in ipairs(lower_gears) do
        solution = solution + GetGearRatio(gear, upper_parts, middle_parts, lower_parts);
    end

    input_file:seek("set", 0);

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
end

SolveFirstPart();
SolveSecondPart();