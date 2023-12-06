require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day6input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function GetWinningOptionCount(race_info)
    local hold_time = math.ceil(race_info.distance / race_info.time);
    local from = nil;
    local to = nil;

    while not from do
        local race_time = race_info.time - hold_time;
        if hold_time * race_time > race_info.distance then
            from = hold_time;
            to = race_time;
        end
        hold_time = hold_time + 1;
    end

    return to - from + 1;
end

function SolveFirstPart()
    local start_time = os.clock();
    local solution = 1;
    
    local _, times_string = SplitString(input_file:read("l"), ":");
    assert(times_string)
    local t1s, t2s, t3s, t4s = string.match(times_string, "(%d+) +(%d+) +(%d+) +(%d+)");

    local _, distance_string = SplitString(input_file:read("l"), ":");
    assert(distance_string)
    local d1s, d2s, d3s, d4s = string.match(distance_string, "(%d+) +(%d+) +(%d+) +(%d+)");
    
    input_file:seek("set", 0);

    local race_data = {
        {time = tonumber(t1s), distance = tonumber(d1s)},
        {time = tonumber(t2s), distance = tonumber(d2s)},
        {time = tonumber(t3s), distance = tonumber(d3s)},
        {time = tonumber(t4s), distance = tonumber(d4s)},
    };

    for _, race in pairs(race_data) do
        solution = solution * GetWinningOptionCount(race);
    end

    local end_time = os.clock();
    local final_time = end_time - start_time;
   
    print("First part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end


function SolveSecondPart()
    local start_time = os.clock();
    local solution = 1;
    
    local _, times_string = SplitString(input_file:read("l"), ":");
    assert(times_string)
    local t1s, t2s, t3s, t4s = string.match(times_string, "(%d+) +(%d+) +(%d+) +(%d+)");
    local total_time = t1s..t2s..t3s..t4s;

    local _, distance_string = SplitString(input_file:read("l"), ":");
    assert(distance_string)
    local d1s, d2s, d3s, d4s = string.match(distance_string, "(%d+) +(%d+) +(%d+) +(%d+)");
    local total_distance = d1s..d2s..d3s..d4s;
    
    input_file:seek("set", 0);

    local race_info = {time = tonumber(total_time), distance = tonumber(total_distance)};

    solution = GetWinningOptionCount(race_info);

    local end_time = os.clock();
    local final_time = end_time - start_time;

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

SolveFirstPart();
SolveSecondPart();