local input_file, error_msg = io.open("inputs\\test21input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function SolveFirstPart()
    local position = 0;
    local depth = 0;

    local command_center = {};
    command_center["forward"] = function(n) position = position + n end
    command_center["up"] = function(n) depth = depth - n end
    command_center["down"] = function(n) depth = depth + n end

    for line in input_file:lines() do
        for command, number in string.gmatch(line, "(%w+) (%w+)") do
            command_center[command](number);
            --print(string.format("Command is %s and the number is %d", command, number));
        end
    end
    input_file:seek("set", 0);

    print("First part solution!");
    print(string.format("Final position is %d, final depth is %d, and the solution is %d", position, depth, position * depth));
end

function SolveSecondPart()
    local position = 0;
    local depth = 0;
    local aim = 0;

    local command_center = {};
    command_center["forward"] = function(n) position = position + n; depth = depth + (aim * n); end
    command_center["up"] = function(n) aim = aim - n end
    command_center["down"] = function(n) aim = aim + n end

    for line in input_file:lines() do
        for command, number in string.gmatch(line, "(%w+) (%w+)") do
            command_center[command](number);
            --print(string.format("Command is %s and the number is %d", command, number));
        end
    end
    input_file:seek("set", 0);

    print("Second part solution!");
    print(string.format("Final position is %d, final depth is %d, and the solution is %d", position, depth, position * depth));
end

SolveFirstPart();
SolveSecondPart();