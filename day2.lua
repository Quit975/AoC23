local input_file, error_msg = io.open("inputs\\day2input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function ParseRound(round)
    local result = {}
    result.red = 0;
    result.green = 0;
    result.blue = 0;

    for color_result in string.gmatch(round, "[%w%s]+,?") do
        if string.find(color_result, "red") then
            result.red = tonumber(string.match(color_result, "%d+"));
        elseif string.find(color_result, "green") then
            result.green = tonumber(string.match(color_result, "%d+"));
        elseif string.find(color_result, "blue") then
            result.blue = tonumber(string.match(color_result, "%d+"));
        else
            assert(nil, "lol");
        end
    end

    return result;
end

function ParseLine(line)
    local result = {};

    local game_id_string_idx = string.find(line, ":");
    assert(game_id_string_idx, "Something fucky goin on with input");
    local game_id_string = string.sub(line, 1, game_id_string_idx);
    result.game_id = tonumber(string.match(game_id_string, "%d+"))

    result.rounds = {};
    local i = 1;

    for round_result_string in string.gmatch(string.sub(line, game_id_string_idx), "[,%w%s]+;?") do
        result.rounds[i] = ParseRound(round_result_string);
        i = i + 1;
    end

    return result;
end

function IsGameValid(game_result, red_limit, green_limit, blue_limit)
    for _, round in ipairs(game_result.rounds) do
        if not(round.red <= red_limit and round.green <= green_limit and round.blue <= blue_limit) then
            return false;
        end
    end
    return true;
end

function SolveFirstPart()
    local solution = 0;

    for line in input_file:lines() do
        local game_result = ParseLine(line);
        if IsGameValid(game_result, 12, 13, 14) then
            solution = solution + game_result.game_id;
        end
    end
    input_file:seek("set", 0);

    print("First part solution!");
    print(string.format("The solution is %d", solution));
end

function GetPower(game_result)
    local red = 0;
    local green = 0;
    local blue = 0;

    for _, round in ipairs(game_result.rounds) do
        if round.red > red then red = round.red end
        if round.green > green then green = round.green end
        if round.blue > blue then blue = round.blue end
    end

    return red * green * blue;
end

function SolveSecondPart()
    local solution = 0;
    for line in input_file:lines() do
        local game_result = ParseLine(line);
        local game_power = GetPower(game_result);
        solution = solution + game_power;
    end
    input_file:seek("set", 0);

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
end

SolveFirstPart();
SolveSecondPart();