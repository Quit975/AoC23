require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day4input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function ExtractNumbers(input_string)
    local res = {};
    for number in string.gmatch(input_string, "%d+") do
        table.insert(res, tonumber(number));
    end
    return res;
end

function SolveFirstPart()
    local solution = 0;

    for line in input_file:lines() do
        local left, right = SplitString(line, "|");
        _, left = SplitString(left, ":");
        local winning_numbers = Set.New(ExtractNumbers(left));
        local chosen_numbers = Set.New(ExtractNumbers(right));
        local matches = Set.Intersection(winning_numbers, chosen_numbers);
        local points = 0.5;
        for _, _ in pairs(matches) do
            points = points * 2;
        end
        solution = solution + math.floor(points);
    end
    input_file:seek("set", 0);

    print("First part solution!");
    print(string.format("The solution is %d", solution));
end

function AddCardCount(cards, card_id)
    if cards[card_id] then 
        cards[card_id] = cards[card_id] + 1;
    else
        cards[card_id] = 1;
    end
end

function SolveSecondPart()
    local solution = 0;
    local card_counts = {};
    local max_id = 0;

    for line in input_file:lines() do
        local left, right = SplitString(line, "|");
        local card_id_string, left = SplitString(left, ":");
        local id = ExtractNumbers(card_id_string)[1];
        AddCardCount(card_counts, id);
        max_id = id;

        local winning_numbers = Set.New(ExtractNumbers(left));
        local chosen_numbers = Set.New(ExtractNumbers(right));
        local matches, number_of_wins = Set.Intersection(winning_numbers, chosen_numbers);

        for i = 1, card_counts[id] do
            for j = 1, number_of_wins do
                AddCardCount(card_counts, id + j);
            end
        end
        
    end

    for i, v in ipairs(card_counts) do
        if i <= max_id then
            solution = solution + v;
        end
    end

    input_file:seek("set", 0);

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
end

SolveFirstPart();
SolveSecondPart();