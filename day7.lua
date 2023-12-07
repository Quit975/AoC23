require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day7input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

local card_to_hex_map = {};
card_to_hex_map["2"] = 0x2;
card_to_hex_map["3"] = 0x3;
card_to_hex_map["4"] = 0x4;
card_to_hex_map["5"] = 0x5;
card_to_hex_map["6"] = 0x6;
card_to_hex_map["7"] = 0x7;
card_to_hex_map["8"] = 0x8;
card_to_hex_map["9"] = 0x9;
card_to_hex_map["T"] = 0xA;
card_to_hex_map["J"] = 0xB;
card_to_hex_map["Q"] = 0xC;
card_to_hex_map["K"] = 0xD;
card_to_hex_map["A"] = 0xE;

local FIVE_OF_A_KIND = 1;
local FOUR_OF_A_KIND = 2;
local FULL_HOUSE = 3;
local THREE_OF_A_KIND = 4;
local TWO_PAIRS = 5;
local ONE_PAIR = 6;
local HIGH_CARD = 7;

function GetMaxUniqueCardCount(cards)
    local card = 0x0;
    local count = 0;

    local top_card = 0x0;
    local top_count = 0;

    for i = 1, 5 do
        if card == cards[i] then
            count = count + 1;
        else
            if count >= top_count then
                top_card = card;
                top_count = count;

                card = cards[i];
                count = 1;
            end
        end
    end

    if count > top_count then
        top_card = card;
        top_count = count;
    end

    return top_count, top_card;
end

function HandSortingFunction(hand_l, hand_r)
    for i = 1, 5 do
        if hand_l.cards[i] < hand_r.cards[i] then
            return true;
        elseif hand_l.cards[i] > hand_r.cards[i] then
            return false;
        end
    end
    assert(hand_l.bid == hand_r.bid);
    return false;
end

function ParseHand(string_input)
    local hand = {};
    
    local cards_string, bid = SplitString(string_input, " ");
    assert(cards_string and bid);
    hand.bid = tonumber(bid);
    
    hand.cards = {};

    for c in string.gmatch(cards_string, ".") do
        table.insert(hand.cards, card_to_hex_map[c]);
    end

    local sorted_hand = {table.unpack(hand.cards)};
    table.sort(sorted_hand);

    local card_set, set_size = Set.New(hand.cards);

    if set_size == 1 then
        hand.type = FIVE_OF_A_KIND;
    elseif set_size == 2 then
        local count, card = GetMaxUniqueCardCount(sorted_hand);
        if count == 4 then
            hand.type = FOUR_OF_A_KIND;
        else
            hand.type = FULL_HOUSE;
        end
    elseif set_size == 3 then
        local count, card = GetMaxUniqueCardCount(sorted_hand);
        if count == 3 then
            hand.type = THREE_OF_A_KIND;
        else
            hand.type = TWO_PAIRS;
        end
    elseif set_size == 4 then
        hand.type = ONE_PAIR;
    else
        hand.type = HIGH_CARD;
    end

    return hand;
end

function SolveFirstPart()
    local start_time = os.clock();
    local solution = 0;

    local five_kinds = {};
    local four_kinds = {};
    local fulls = {};
    local three_kinds = {};
    local two_pairs = {};
    local one_pairs = {};
    local highs = {};

    local HandSorter = {
        function(hand) table.insert(five_kinds, hand) end,
        function(hand) table.insert(four_kinds, hand) end,
        function(hand) table.insert(fulls, hand) end,
        function(hand) table.insert(three_kinds, hand) end,
        function(hand) table.insert(two_pairs, hand) end,
        function(hand) table.insert(one_pairs, hand) end,
        function(hand) table.insert(highs, hand) end,
    }
    
    for line in input_file:lines() do
        local hand = ParseHand(line);
        HandSorter[hand.type](hand);
    end
    input_file:seek("set", 0);

    table.sort(five_kinds, HandSortingFunction);
    table.sort(four_kinds, HandSortingFunction);
    table.sort(fulls, HandSortingFunction);
    table.sort(three_kinds, HandSortingFunction);
    table.sort(two_pairs, HandSortingFunction);
    table.sort(one_pairs, HandSortingFunction);
    table.sort(highs, HandSortingFunction);

    local current_rank = 1;
    for _, hand in ipairs(highs) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(one_pairs) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(two_pairs) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(three_kinds) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(fulls) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(four_kinds) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(five_kinds) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end


    local end_time = os.clock();
    local final_time = end_time - start_time;
   
    print("First part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

function ParseHand2(string_input)
    local hand = {};
    
    local cards_string, bid = SplitString(string_input, " ");
    assert(cards_string and bid);
    hand.bid = tonumber(bid);
    
    hand.cards = {};
    local promote_count = 0;

    for c in string.gmatch(cards_string, ".") do
        local num_to_insert = card_to_hex_map[c]
        if c == "J" then
            promote_count = promote_count + 1;
            num_to_insert = 0x1;
        end
        table.insert(hand.cards, num_to_insert);
    end

    local sorted_hand = {table.unpack(hand.cards)};
    table.sort(sorted_hand);
    for i = #sorted_hand, 1, -1 do
        if sorted_hand[i] == 0x1 then
            table.remove(sorted_hand, i);
        end
    end

    local card_set, set_size = Set.New(sorted_hand);
    set_size = set_size + promote_count;

    if set_size == 1 then
        hand.type = FIVE_OF_A_KIND;
    elseif set_size == 2 then
        local count, card = GetMaxUniqueCardCount(sorted_hand);
        if count == 4 then
            hand.type = FOUR_OF_A_KIND;
        else
            hand.type = FULL_HOUSE;
        end
    elseif set_size == 3 then
        local count, card = GetMaxUniqueCardCount(sorted_hand);
        if count == 3 then
            hand.type = THREE_OF_A_KIND;
        else
            hand.type = TWO_PAIRS;
        end
    elseif set_size == 4 then
        hand.type = ONE_PAIR;
    else
        hand.type = HIGH_CARD;
    end

    for count = 1, promote_count do
        if hand.type == HIGH_CARD then
            hand.type = ONE_PAIR;
        elseif hand.type == ONE_PAIR then
            hand.type = THREE_OF_A_KIND;
        elseif hand.type == TWO_PAIRS then
            hand.type = FULL_HOUSE;
        elseif hand.type == THREE_OF_A_KIND then
            hand.type = FOUR_OF_A_KIND;
        elseif hand.type == FULL_HOUSE then
            hand.type = FOUR_OF_A_KIND;
        elseif hand.type == FOUR_OF_A_KIND then
            hand.type = FIVE_OF_A_KIND;
        elseif hand.type == FIVE_OF_A_KIND then
            hand.type = FIVE_OF_A_KIND;
        end
    end

    return hand;
end

function SolveSecondPart()
    local start_time = os.clock();
    local solution = 0;

    local five_kinds = {};
    local four_kinds = {};
    local fulls = {};
    local three_kinds = {};
    local two_pairs = {};
    local one_pairs = {};
    local highs = {};

    local HandSorter = {
        function(hand) table.insert(five_kinds, hand) end,
        function(hand) table.insert(four_kinds, hand) end,
        function(hand) table.insert(fulls, hand) end,
        function(hand) table.insert(three_kinds, hand) end,
        function(hand) table.insert(two_pairs, hand) end,
        function(hand) table.insert(one_pairs, hand) end,
        function(hand) table.insert(highs, hand) end,
    }
    
    for line in input_file:lines() do
        local hand = ParseHand2(line);
        HandSorter[hand.type](hand);
    end
    input_file:seek("set", 0);

    table.sort(five_kinds, HandSortingFunction);
    table.sort(four_kinds, HandSortingFunction);
    table.sort(fulls, HandSortingFunction);
    table.sort(three_kinds, HandSortingFunction);
    table.sort(two_pairs, HandSortingFunction);
    table.sort(one_pairs, HandSortingFunction);
    table.sort(highs, HandSortingFunction);

    local current_rank = 1;
    for _, hand in ipairs(highs) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(one_pairs) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(two_pairs) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(three_kinds) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(fulls) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(four_kinds) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    for _, hand in ipairs(five_kinds) do
        solution = solution + (current_rank * hand.bid);
        current_rank = current_rank + 1;
    end

    local end_time = os.clock();
    local final_time = end_time - start_time;

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

SolveFirstPart();
SolveSecondPart();