require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day9input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function GetDiffsArray(sequence)
    local diffs = {};
    local sum = 0;
    for i = 2, #sequence do
        local diff = sequence[i] - sequence[i - 1];
        table.insert(diffs, diff);
        sum = sum + math.abs(diff);
    end

    local are_all_zeroes = sum == 0;
    return diffs, are_all_zeroes;
end

function PredictNextNumberForFirstSequence(array_of_sequences)
    for i = #array_of_sequences, 2, -1 do
        local target_array = array_of_sequences[i - 1];
        local curr_array = array_of_sequences[i];
        table.insert(target_array, curr_array[#curr_array] + target_array[#target_array]);
    end

    local first_sequence = array_of_sequences[1];
    return first_sequence[#first_sequence];
end

function SolveFirstPart()
    local start_time = os.clock();
    local solution = 0;

    local number_sequences = {};

    for line in input_file:lines() do
        local sequence = {};
        for number in string.gmatch(line, "-?%d+") do
            table.insert(sequence, tonumber(number));
        end
        table.insert(number_sequences, sequence);
    end
    input_file:seek("set", 0);

    for _, sequence in pairs(number_sequences) do
        local resolved_sequences = {};
        table.insert(resolved_sequences, sequence);
        while true do
            local diff_sequence, is_all_zeroes = GetDiffsArray(resolved_sequences[#resolved_sequences]);
            table.insert(resolved_sequences, diff_sequence);
            if is_all_zeroes then
                break;
            end
        end

        solution = solution + PredictNextNumberForFirstSequence(resolved_sequences);
    end

    local end_time = os.clock();
    local final_time = end_time - start_time;
   
    print("First part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

function PredictPrevNumberForFirstSequence(array_of_sequences)
    for i = #array_of_sequences, 2, -1 do
        local target_array = array_of_sequences[i - 1];
        local curr_array = array_of_sequences[i];
        table.insert(target_array, 1, target_array[1] - curr_array[1]);
    end

    local first_sequence = array_of_sequences[1];
    return first_sequence[1];
end

function SolveSecondPart()
    local start_time = os.clock();
    local solution = 0;

    local number_sequences = {};

    for line in input_file:lines() do
        local sequence = {};
        for number in string.gmatch(line, "-?%d+") do
            table.insert(sequence, tonumber(number));
        end
        table.insert(number_sequences, sequence);
    end
    input_file:seek("set", 0);

    for _, sequence in pairs(number_sequences) do
        local resolved_sequences = {};
        table.insert(resolved_sequences, sequence);
        while true do
            local diff_sequence, is_all_zeroes = GetDiffsArray(resolved_sequences[#resolved_sequences]);
            table.insert(resolved_sequences, diff_sequence);
            if is_all_zeroes then
                break;
            end
        end

        solution = solution + PredictPrevNumberForFirstSequence(resolved_sequences);
    end

    local end_time = os.clock();
    local final_time = end_time - start_time;

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

SolveFirstPart();
SolveSecondPart();