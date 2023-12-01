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

    for line in input_file:lines() do

    end
    input_file:seek("set", 0);

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
end

SolveFirstPart();
SolveSecondPart();