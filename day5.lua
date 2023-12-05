require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day5input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

function GetSeeds1(input_line)
    local _, seeds_str = SplitString(input_line, ":");
    if not seeds_str then return nil end;
    local seeds = {};
    for seed in string.gmatch(seeds_str, "%d+") do
        table.insert(seeds, tonumber(seed));
    end
    return seeds;
end

function ProcessMap1(input_file_param, out_map)
    for line in input_file_param:lines() do
        if line == "" then
            return;
        else
            local destination, source, length = string.match(line, "(%d+) (%d+) (%d+)");
            local new_offset = {};
            new_offset.destination = tonumber(destination);
            new_offset.source = tonumber(source);
            new_offset.length = tonumber(length);
            table.insert(out_map, new_offset);
        end
    end
end

function GetMapping1(input_number, map_to_use)
    for _, offset in pairs(map_to_use) do
        local end_source = offset.source + offset.length;
        if input_number >= offset.source and input_number <= end_source then
            local actual_offset = input_number - offset.source;
            return offset.destination + actual_offset;
        end
    end
    return input_number;
end

function SolveFirstPart()
    local solution = 0;
    local seed_to_soil_map = {};
    local soil_to_fert_map = {};
    local fert_to_water_map = {};
    local water_to_light_map = {};
    local light_to_temp_map = {};
    local temp_to_hum_map = {};
    local hum_to_loc_map = {};

    local seeds_line = input_file:read("l");
    local seeds = GetSeeds1(seeds_line);
    assert(seeds);

    for line in input_file:lines() do
        if line == "seed-to-soil map:" then
            ProcessMap1(input_file, seed_to_soil_map);
        elseif line == "soil-to-fertilizer map:" then
            ProcessMap1(input_file, soil_to_fert_map);
        elseif line == "fertilizer-to-water map:" then
            ProcessMap1(input_file, fert_to_water_map);
        elseif line == "water-to-light map:" then
            ProcessMap1(input_file, water_to_light_map);
        elseif line == "light-to-temperature map:" then
            ProcessMap1(input_file, light_to_temp_map);
        elseif line == "temperature-to-humidity map:" then
            ProcessMap1(input_file, temp_to_hum_map);
        elseif line == "humidity-to-location map:" then
            ProcessMap1(input_file, hum_to_loc_map);
        end
    end
    input_file:seek("set", 0);

    for _, seed in pairs(seeds) do
        local sts = GetMapping1(seed, seed_to_soil_map);
        local stf = GetMapping1(sts, soil_to_fert_map);
        local ftw = GetMapping1(stf, fert_to_water_map);
        local wtl = GetMapping1(ftw, water_to_light_map);
        local ltt = GetMapping1(wtl, light_to_temp_map);
        local tth = GetMapping1(ltt, temp_to_hum_map);
        local pos = GetMapping1(tth, hum_to_loc_map);

        if solution == 0 or solution > pos then solution = pos end;
    end

    print("First part solution!");
    print(string.format("The solution is %d", solution));
end

function GetSeeds2(input_line)
    local _, seeds_str = SplitString(input_line, ":");
    if not seeds_str then return nil end;
    local seeds = {};
    for seed_start, seed_length in string.gmatch(seeds_str, "(%d+) (%d+)") do
        local seed = {};
        seed.start = tonumber(seed_start);
        seed.length = tonumber(seed_length);
        table.insert(seeds, seed);
    end
    return seeds;
end

function SolveSecondPart()
    local solution = 0;

    local seed_to_soil_map = {};
    local soil_to_fert_map = {};
    local fert_to_water_map = {};
    local water_to_light_map = {};
    local light_to_temp_map = {};
    local temp_to_hum_map = {};
    local hum_to_loc_map = {};

    local seeds_line = input_file:read("l");
    local seeds = GetSeeds2(seeds_line);
    assert(seeds);

    for line in input_file:lines() do
        if line == "seed-to-soil map:" then
            ProcessMap1(input_file, seed_to_soil_map);
        elseif line == "soil-to-fertilizer map:" then
            ProcessMap1(input_file, soil_to_fert_map);
        elseif line == "fertilizer-to-water map:" then
            ProcessMap1(input_file, fert_to_water_map);
        elseif line == "water-to-light map:" then
            ProcessMap1(input_file, water_to_light_map);
        elseif line == "light-to-temperature map:" then
            ProcessMap1(input_file, light_to_temp_map);
        elseif line == "temperature-to-humidity map:" then
            ProcessMap1(input_file, temp_to_hum_map);
        elseif line == "humidity-to-location map:" then
            ProcessMap1(input_file, hum_to_loc_map);
        end
    end
    input_file:seek("set", 0);

    function GetPositionForSeed(seed_num)
        local sts = GetMapping1(seed_num, seed_to_soil_map);
        local stf = GetMapping1(sts, soil_to_fert_map);
        local ftw = GetMapping1(stf, fert_to_water_map);
        local wtl = GetMapping1(ftw, water_to_light_map);
        local ltt = GetMapping1(wtl, light_to_temp_map);
        local tth = GetMapping1(ltt, temp_to_hum_map);
        local pos = GetMapping1(tth, hum_to_loc_map);
        return pos;
    end

    function FindSmallestPosForSeedRange(seed_range)
        local first_seed = seed_range.start;
        local last_seed = seed_range.start + seed_range.length - 1;
        local dt = math.floor(seed_range.length / 10000);

        local lowest_pos = 0;
        local lowest_idx = 0;
        local prev_idx = -1;
        local next_idx = 0;

        for idx = first_seed, last_seed, dt do
            local idx_to_check = (idx <= last_seed) and idx or last_seed;
            local pos = GetPositionForSeed(idx_to_check);

            if lowest_pos == 0 or lowest_pos > pos then 
                lowest_pos = pos;
                lowest_idx = idx_to_check;
                prev_idx = (prev_idx > -1) and (idx - dt) or idx;
                next_idx = ((idx + dt) <= last_seed) and (idx + dt) or last_seed;;
            end;
        end

        for idx = prev_idx, next_idx do
            local pos = GetPositionForSeed(idx);
            if lowest_pos > pos then lowest_pos = pos end;
        end

        return lowest_pos;
    end

    for _, seed in pairs(seeds) do
        local pos = FindSmallestPosForSeedRange(seed);
        if solution == 0 or solution > pos then solution = pos end;
    end

    print("Second part solution!");
    print(string.format("The solution is %d", solution));

    --[[alt solution
    local source_comp = function(l, r)
        return l.source <= r.source;
    end

    local dest_comp = function(l, r)
        return l.destination < r.destination;
    end

    -- find lowest position
    table.sort(hum_to_loc_map, dest_comp);
    local lowest_pos = hum_to_loc_map[1].destination;
    local lowest_pos_input = hum_to_loc_map[1].source;

    -- find input to hum that gives this pos
    table.sort(temp_to_hum_map, dest_comp);
    local hum_input = 0;
    for _, hum in pairs(temp_to_hum_map) do
        if lowest_pos_input >= hum.destination and lowest_pos_input <= (hum.destination + hum.length) then
            local offset = lowest_pos_input - hum.destination;
            hum_input = hum.source + offset;
            break;
        end
    end

    -- find input to temp that gives this hum
    table.sort(light_to_temp_map, dest_comp);
    local temp_input = 0;
    for _, temp in pairs(light_to_temp_map) do
        if hum_input >= temp.destination and hum_input <= (temp.destination + temp.length) then
            local offset = hum_input - temp.destination;
            temp_input = temp.source + offset;
            break;
        end
    end

    -- find input to light that gives this temp
    table.sort(water_to_light_map, dest_comp);
    local light_input = 0;
    for _, light in pairs(water_to_light_map) do
        if temp_input >= light.destination and temp_input <= (light.destination + light.length) then
            local offset = temp_input - light.destination;
            light_input = light.source + offset;
            break;
        end
    end

    -- find input to water that gives this light
    table.sort(fert_to_water_map, dest_comp);
    local water_input = 0;
    for _, water in pairs(fert_to_water_map) do
        if light_input >= water.destination and light_input <= (water.destination + water.length) then
            local offset = light_input - water.destination;
            water_input = water.source + offset;
            break;
        end
    end

    -- find input to fert that gives this water
    table.sort(soil_to_fert_map, dest_comp);
    local fert_input = 0;
    for _, fert in pairs(soil_to_fert_map) do
        if water_input >= fert.destination and water_input <= (fert.destination + fert.length) then
            local offset = water_input - fert.destination;
            fert_input = fert.source + offset;
            break;
        end
    end

    -- find input to seed that gives this fert
    table.sort(seed_to_soil_map, dest_comp);
    local soil_input = 0;
    for _, soil in pairs(seed_to_soil_map) do
        if fert_input >= soil.destination and fert_input <= (soil.destination + soil.length) then
            local offset = fert_input - soil.destination;
            soil_input = soil.source + offset;
            break;
        end
    end

    local my_turbo_seed = 0;
    for _, seed in pairs(seeds) do
        if soil_input >= seed.start and soil_input <= (seed.start + seed.length -1) then
            local offset = soil_input - seed.start;
        end
    end

    print(soil_input);
    print(GetPositionForSeed(soil_input));
    ]]--
end

SolveFirstPart();
SolveSecondPart();