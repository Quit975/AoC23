require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day11input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function GetExpansionCount(expansions_array, from_galaxy, to_galaxy)
    local res = 0;
    local adj_from = from_galaxy < to_galaxy and from_galaxy or to_galaxy;
    local adj_to = from_galaxy < to_galaxy and to_galaxy or from_galaxy;
    for i = 1, #expansions_array do
        if expansions_array[i] >= adj_from and expansions_array[i] <= adj_to then
            res = res + 1;
        end
    end

    return res;
end

function SolveFirstPart()
    local start_time = os.clock();
    local solution = 0;
    
    local all_rows_set = Set.New({});
    local all_columns_set = Set.New({});
    local rows_with_galaxies = Set.New({});
    local columns_with_galaxies = Set.New({});
    local galaxies = {};

    local current_row = 0;
    local current_column = 0;

    for line in input_file:lines() do
        current_row = current_row + 1;
        current_column = 0;

        Set.Add(all_rows_set, current_row);

        for char in string.gmatch(line, ".") do
            current_column = current_column + 1;

            Set.Add(all_columns_set, current_column);

            if char == "#" then
                table.insert(galaxies, {x = current_column, y = current_row});
                Set.Add(rows_with_galaxies, current_row);
                Set.Add(columns_with_galaxies, current_column);
            end
        end

    end
    input_file:seek("set", 0);

    local expanded_rows_set, expanded_rows_size = Set.Complement(all_rows_set, rows_with_galaxies);
    local expanded_columns_set, expanded_columns_size = Set.Complement(all_columns_set, columns_with_galaxies);

    local expanded_rows = Set.ToArray(expanded_rows_set);
    local expanded_columns = Set.ToArray(expanded_columns_set);

    for i = 1, #galaxies - 1 do
        for j = i + 1, #galaxies do
            local from_x = galaxies[i].x;
            local to_x = galaxies[j].x;
            local x_distance = 0;
            if from_x ~= to_x then
                x_distance = math.abs(to_x - from_x) + GetExpansionCount(expanded_columns, from_x, to_x);
            end

            local from_y = galaxies[i].y;
            local to_y = galaxies[j].y;
            local y_distance = 0;
            if from_y ~= to_y then
                y_distance = math.abs(to_y - from_y) + GetExpansionCount(expanded_rows, from_y, to_y);
            end

            solution = solution + (x_distance + y_distance);
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
    local solution = 0;

    local all_rows_set = Set.New({});
    local all_columns_set = Set.New({});
    local rows_with_galaxies = Set.New({});
    local columns_with_galaxies = Set.New({});
    local galaxies = {};

    local current_row = 0;
    local current_column = 0;

    for line in input_file:lines() do
        current_row = current_row + 1;
        current_column = 0;

        Set.Add(all_rows_set, current_row);

        for char in string.gmatch(line, ".") do
            current_column = current_column + 1;

            Set.Add(all_columns_set, current_column);

            if char == "#" then
                table.insert(galaxies, {x = current_column, y = current_row});
                Set.Add(rows_with_galaxies, current_row);
                Set.Add(columns_with_galaxies, current_column);
            end
        end

    end
    input_file:seek("set", 0);

    local expanded_rows_set, expanded_rows_size = Set.Complement(all_rows_set, rows_with_galaxies);
    local expanded_columns_set, expanded_columns_size = Set.Complement(all_columns_set, columns_with_galaxies);

    local expanded_rows = Set.ToArray(expanded_rows_set);
    local expanded_columns = Set.ToArray(expanded_columns_set);

    for i = 1, #galaxies - 1 do
        for j = i + 1, #galaxies do
            local from_x = galaxies[i].x;
            local to_x = galaxies[j].x;
            local x_distance = 0;
            if from_x ~= to_x then
                local exp_count = GetExpansionCount(expanded_columns, from_x, to_x);
                x_distance = (math.abs(to_x - from_x) - exp_count) + (1000000 * exp_count);
            end

            local from_y = galaxies[i].y;
            local to_y = galaxies[j].y;
            local y_distance = 0;
            if from_y ~= to_y then
                local exp_count = GetExpansionCount(expanded_rows, from_y, to_y);
                y_distance = (math.abs(to_y - from_y) - exp_count) + (1000000 * exp_count);
            end

            solution = solution + (x_distance + y_distance);
        end
    end

    local end_time = os.clock();
    local final_time = end_time - start_time;

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

SolveFirstPart();
SolveSecondPart();