local input_file, error_msg = io.open("inputs\\day1input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function SolveFirstPart()
    local solution = 0;
    for line in input_file:lines() do
        local first_num = string.match(line, "%d");
        local last_num = string.match(string.reverse(line), "%d");
        local final_num = tonumber(first_num .. last_num);
        solution = solution + final_num;
        --print(string.format("Num one is %d and two is %d and final num is %d", first_num, last_num, final_num));
    end
    input_file:seek("set", 0);

    print("First part solution!");
    print(string.format("The solution is %d", solution));
end

function SolveSecondPart()
    local solution = 0;
    local number_converter = {}
    number_converter["zero"] = 0
    number_converter["one"] = 1
    number_converter["two"] = 2
    number_converter["three"] = 3
    number_converter["four"] = 4
    number_converter["five"] = 5
    number_converter["six"] = 6
    number_converter["seven"] = 7
    number_converter["eight"] = 8
    number_converter["nine"] = 9

    local FindFirstDigit = function(in_string, digit_to_look)
        local search_pattern = digit_to_look and tostring(digit_to_look) or "%d";
        local idx = string.find(in_string, search_pattern);
        return idx, tonumber(string.sub(in_string, idx, idx));
    end

    local FindLastDigit = function(in_string, digit_to_look)
        local search_pattern = digit_to_look and tostring(digit_to_look) or "%d";
        local idx = string.find(string.reverse(in_string), search_pattern);
        idx = string.len(in_string) - idx + 1;
        return idx, tonumber(string.sub(in_string, idx, idx));
    end

    local FindFirstWordDigit = function(in_string)
        local first_idx = 1000;
        local first_word = "";

        for k in pairs(number_converter) do
            local search_idx, search_len = string.find(in_string, k);
            if not search_idx then goto continue end
            if search_idx < first_idx then
                first_idx = search_idx;
                first_word = string.sub(in_string, search_idx, search_len);
            end
            ::continue::
        end

        return first_idx, number_converter[first_word];
    end

    local FindLastWordDigit = function(in_string)
        local last_idx = 0;
        local last_word = "";

        for k in pairs(number_converter) do
            local _, search_idx = string.find(string.reverse(in_string), string.reverse(k));
            if not search_idx then goto continue end
            search_idx = string.len(in_string) - search_idx + 1;
            local end_idx = search_idx + (string.len(k) - 1);
            if search_idx > last_idx then
                last_idx = search_idx;
                last_word = string.sub(in_string, search_idx, end_idx);
            end
            ::continue::
        end

        return last_idx, number_converter[last_word];
    end

    for line in input_file:lines() do
        local first_digit_index, first_digit_value = FindFirstDigit(line);
        local last_digit_index, last_digit_value = FindLastDigit(line);
        local first_word_index, first_word_value = FindFirstWordDigit(line);
        local last_word_index, last_word_value = FindLastWordDigit(line);

        local final_left = first_digit_index < first_word_index and first_digit_value or first_word_value;
        local final_right = last_digit_index > last_word_index and last_digit_value or last_word_value;
        local final_num = tonumber(string.format("%d%d", final_left, final_right));
        solution = solution + final_num;
        --print(string.format("First %d last %d", first_digit_index, last_digit_index));
    end
    input_file:seek("set", 0);

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
end

SolveFirstPart();
SolveSecondPart();