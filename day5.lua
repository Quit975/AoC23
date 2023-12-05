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
        local end_source = offset.source + (offset.length - 1);
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
    local start_time = os.clock();

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
        local seed_offset = seed_range.length - 1;
        local last_seed = seed_range.start + seed_offset;

        local dt = math.floor(seed_offset / 10000);
        local lowest_pos = -99;

        local prev_idx;
        local next_idx;
        for seed_idx = first_seed, last_seed, dt do
            local clamped_idx = seed_idx > last_seed and last_seed or seed_idx;
            local seed_pos = GetPositionForSeed(clamped_idx);
            if lowest_pos == -99 or lowest_pos > seed_pos then
                lowest_pos = seed_pos;
                prev_idx = (seed_idx - dt) >= first_seed and (seed_idx - dt) or first_seed;
                next_idx = (seed_idx + dt) <= last_seed and (seed_idx + dt) or last_seed;
            end;
        end

        local result = -99;
        for seed_idx = prev_idx, next_idx do
            local seed_pos = GetPositionForSeed(seed_idx);
            if result == -99 or result > seed_pos then result = seed_pos end;
        end

        return result;
    end

    for _, seed in pairs(seeds) do
        local pos = FindSmallestPosForSeedRange(seed);
        if solution == 0 or solution > pos then solution = pos end;
    end

    local end_time = os.clock();
    local final_time = end_time - start_time;

    print("Second part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

SolveFirstPart();
SolveSecondPart();