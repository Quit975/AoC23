require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day8input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function SolveFirstPart()
    local start_time = os.clock();
    local solution = 0;
    
    local instructions_string = input_file:read("l");
    local instructions = {};

    for char in string.gmatch(instructions_string, ".") do
        if char == "L" then
            table.insert(instructions, 1);
        else
            table.insert(instructions, 2);
        end
    end

    local instruction_count = #instructions;

    local _ = input_file:read("l"); --empty line

    local waypoint_map = {};
    for line in input_file:lines() do
        local id, routes = SplitString(line, "=");
        assert(id and routes);
        routes = string.gsub(routes, "[%(%)]", "");
        local left_route, right_route = SplitString(routes, ",");
        waypoint_map[id] = {left_route, right_route};
    end
    input_file:seek("set", 0);

    local current_node = "AAA";
    local instruction_idx = 1;

    while current_node ~= "ZZZ" do
        current_node = waypoint_map[current_node][instructions[instruction_idx]];
        solution = solution + 1;
        instruction_idx = instruction_idx + 1;

        if instruction_idx > instruction_count then
            instruction_idx = 1;
        end
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

    local instructions_string = input_file:read("l");
    local instructions = {};

    for char in string.gmatch(instructions_string, ".") do
        if char == "L" then
            table.insert(instructions, 1);
        else
            table.insert(instructions, 2);
        end
    end

    local instruction_count = #instructions;

    local _ = input_file:read("l"); --empty line

    local waypoint_map = {};
    local current_nodes = {};
    
    for line in input_file:lines() do
        local id, routes = SplitString(line, "=");
        assert(id and routes);
        routes = string.gsub(routes, "[%(%)]", "");
        local left_route, right_route = SplitString(routes, ",");
        waypoint_map[id] = {left_route, right_route};

        if string.sub(id, 3, 3) == "A" then
            table.insert(current_nodes, id);
        end
    end
    input_file:seek("set", 0);

    local results = {};

    for _, node in pairs(current_nodes) do
        local current_node = node;
        local instruction_idx = 1;

        local result = 0;

        while string.sub(current_node, 3, 3) ~= "Z" do
            current_node = waypoint_map[current_node][instructions[instruction_idx]];
            result = result + 1;
            instruction_idx = instruction_idx + 1;

            if instruction_idx > instruction_count then
                instruction_idx = 1;
            end
        end

        table.insert(results, result);
    end

    function FindGCD(a, b)
        while b ~= 0 do
            a, b = b, a % b;
        end
        return a;
    end

    function FindLCM(a, b)
        return (a * b) / FindGCD(a, b);
    end

    function FindLCMArray(numbers_input)
        local result = 1;
        for _, number in pairs(numbers_input) do
            result = FindLCM(result, number);
        end
        return result;
    end

    solution = FindLCMArray(results);

    local end_time = os.clock();
    local final_time = end_time - start_time;

    print("Second part solution!");
    print(string.format("The solution is %u", solution));
    print(string.format("The solution took %f seconds", final_time));
end

SolveFirstPart();
SolveSecondPart();