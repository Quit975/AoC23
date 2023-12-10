require "utils/strings"
require "utils/sets"

local input_file, error_msg = io.open("inputs\\day10input.txt", "r");
if not input_file then
    print(error_msg);
    return;
end

local NORTH <const> = 1 << 0;
local SOUTH <const> = 1 << 1;
local EAST <const> = 1 << 2;
local WEST <const> = 1 << 3;

function GetOpposingDirection(direction)
    if direction == NORTH then return SOUTH end;
    if direction == SOUTH then return NORTH end;
    if direction == EAST then return WEST end;
    if direction == WEST then return EAST end;
end

function CreateCell(cell_char)
    if cell_char == "." then return nil end;

    local cell = {};
    cell.type = 0;
    if cell_char == "S" then goto finished end; -- start will need to be configured separately later

    do
        local pipe_type;
        if cell_char == "F" then
            pipe_type = SOUTH | EAST;
        elseif cell_char == "L" then
            pipe_type = NORTH | EAST;
        elseif cell_char == "7" then
            pipe_type = SOUTH | WEST;
        elseif cell_char == "J" then
            pipe_type = NORTH | WEST;
        elseif cell_char == "|" then
            pipe_type = NORTH | SOUTH;
        elseif cell_char == "-" then
            pipe_type = EAST | WEST;
        else
            assert(false);
        end

        cell.type = pipe_type;
    end

    ::finished::
    return cell;
end

function InitMap(w, h, raw_input, sx, sy)
    local world = {};

    for x = 1, w do
        table.insert(world, {});
        for y = 1, h do
            local cell = CreateCell(raw_input[x][y]);
            if cell then
                cell.x = x;
                cell.y = y;
            end
            world[x][y] = cell;
        end
    end

    -- establish start cell type
    do
        local start_cell = world[sx][sy];
        local north_neighbor = sy > 1 and world[sx][sy-1] or nil;
        local south_neighbor = sy < h and world[sx][sy+1] or nil;
        local east_neighbor = sx < w and world[sx+1][sy] or nil;
        local west_neighbor = sx > 1 and world[sx-1][sy] or nil;

        local has_n_connection = (north_neighbor and north_neighbor.type & SOUTH ~= 0) and 1 or 0;
        local has_s_connection = (south_neighbor and south_neighbor.type & NORTH ~= 0) and 1 or 0;
        local has_e_connection = (east_neighbor and east_neighbor.type & WEST ~= 0) and 1 or 0;
        local has_w_connection = (west_neighbor and west_neighbor.type & EAST ~= 0) and 1 or 0;

        assert(has_n_connection + has_s_connection + has_e_connection + has_w_connection == 2);

        start_cell.type = start_cell.type | (has_n_connection ~= 0 and NORTH or 0);
        start_cell.type = start_cell.type | (has_s_connection ~= 0 and SOUTH or 0);
        start_cell.type = start_cell.type | (has_e_connection ~= 0 and EAST or 0);
        start_cell.type = start_cell.type | (has_w_connection ~= 0 and WEST or 0);

        assert(start_cell.type == 5);
    end

    -- build connections
    for x = 1, w do
        for y = 1, h do
            local cell = world[x][y];
            if not cell then goto continue end;

            local north_neighbor = y > 1 and world[x][y-1] or nil;
            local south_neighbor = y < h and world[x][y+1] or nil;
            local east_neighbor = x < w and world[x+1][y] or nil;
            local west_neighbor = x > 1 and world[x-1][y] or nil;

            local has_n_connection = cell.type & NORTH ~= 0 and (north_neighbor and north_neighbor.type & SOUTH ~= 0) or false;
            local has_s_connection = cell.type & SOUTH ~= 0 and (south_neighbor and south_neighbor.type & NORTH ~= 0) or false;
            local has_e_connection = cell.type & EAST ~= 0 and (east_neighbor and east_neighbor.type & WEST ~= 0) or false;
            local has_w_connection = cell.type & WEST ~=0 and (west_neighbor and west_neighbor.type & EAST ~= 0) or false;

            cell[NORTH] = has_n_connection and north_neighbor or nil;
            cell[SOUTH] = has_s_connection and south_neighbor or nil;
            cell[EAST] = has_e_connection and east_neighbor or nil;
            cell[WEST] = has_w_connection and west_neighbor or nil;

            ::continue::
        end
    end

    return world;
end

function FollowCell(visited_cell, visited_from_direction)
    assert(visited_cell.type & visited_from_direction ~= 0);
    local visit_to_direction = visited_cell.type ~ visited_from_direction;
    return visited_cell[visit_to_direction], visit_to_direction;
end

function SolveFirstPart()
    local start_time = os.clock();
    local solution = 0;

    local x = 1;
    local y = 1;
    local start_x = 1;
    local start_y = 1;
    local raw_input = {};
    
    for line in input_file:lines() do
        x = 1;
        for char in string.gmatch(line, ".") do
            if not raw_input[x] then
                table.insert(raw_input, {});
            end
            raw_input[x][y] = char;

            if char == "S" then start_x, start_y = x, y end;
            x = x + 1;
        end

        y = y + 1;
    end
    input_file:seek("set", 0);

    local world_map = InitMap(x - 1, y - 1, raw_input, start_x, start_y); -- x and y need to be adjusted because both of them got incremented one more time

    local loop_length = 0;
    local starting_cell = world_map[start_x][start_y];
    local current_cell = nil;
    local goto_direction = nil;

    if starting_cell.type & NORTH ~= 0 then
        current_cell = starting_cell[NORTH];
        goto_direction = NORTH;
    elseif starting_cell.type & SOUTH ~= 0 then
        current_cell = starting_cell[SOUTH];
        goto_direction = SOUTH;
    elseif starting_cell.type & EAST ~= 0  then
        current_cell = starting_cell[EAST];
        goto_direction = EAST;
    elseif starting_cell.type & WEST ~= 0 then
        current_cell = starting_cell[WEST];
        goto_direction = WEST;
    end

    assert(current_cell);

    while current_cell ~= starting_cell do
        current_cell, goto_direction = FollowCell(current_cell, GetOpposingDirection(goto_direction));
        loop_length = loop_length + 1;
    end

    solution = math.ceil(loop_length / 2);

    local end_time = os.clock();
    local final_time = end_time - start_time;
   
    print("First part solution!");
    print(string.format("The solution is %d", solution));
    print(string.format("The solution took %f seconds", final_time));
end

function IsCorner(cell)
    if cell.type == 6 or cell.type == 5 or cell.type == 10 or cell.type == 9 then
        return true;
    end

    return false;
end

function IsPointInLoop(poly_corners, poly_x, poly_y, x, y)
    --[[
        //  int    polyCorners  =  how many corners the polygon has
        //  float  polyX[]      =  horizontal coordinates of corners
        //  float  polyY[]      =  vertical coordinates of corners
        //  float  x, y         =  point to be tested

        bool pointInPolygon() {
        
          int   i, j=polyCorners-1 ;
          bool  oddNodes=NO      ;
        
          for (i=0; i<polyCorners; i++) {
            if ((polyY[i]< y && polyY[j]>=y
            ||   polyY[j]< y && polyY[i]>=y)
            &&  (polyX[i]<=x || polyX[j]<=x)) {
              oddNodes^=(polyX[i]+(y-polyY[i])/(polyY[j]-polyY[i])*(polyX[j]-polyX[i])<x); }
            j=i; }
        
          return oddNodes; }
    ]]

    local prev_idx = poly_corners - 1;

    for idx = 1, poly_corners - 1 do
        if ((poly_y[idx] < y and poly_y[prev_idx] >= y)
        or (poly_y[prev_idx] < y and poly_y[idx] >= y))
        and (poly_x[idx] <= x or poly_x[prev_idx] <= x) then
            local res = ((poly_x[idx]+(y-poly_y[idx])/(poly_y[prev_idx]-poly_y[idx])*(poly_x[prev_idx]-poly_x[idx])<x));
            if res then return true end;
        end

        prev_idx = idx;
    end

    return false;
end


function SolveSecondPart()
    local start_time = os.clock();
    local solution = 0;

    local x = 1;
    local y = 1;
    local start_x = 1;
    local start_y = 1;
    local raw_input = {};
    
    for line in input_file:lines() do
        x = 1;
        for char in string.gmatch(line, ".") do
            if not raw_input[x] then
                table.insert(raw_input, {});
            end
            raw_input[x][y] = char;

            if char == "S" then start_x, start_y = x, y end;
            x = x + 1;
        end

        y = y + 1;
    end
    input_file:seek("set", 0);

    local world_map = InitMap(x - 1, y - 1, raw_input, start_x, start_y); -- x and y need to be adjusted because both of them got incremented one more time

    local starting_cell = world_map[start_x][start_y];
    local current_cell = nil;
    local goto_direction = nil;

    if starting_cell.type & NORTH ~= 0 then
        current_cell = starting_cell[NORTH];
        goto_direction = NORTH;
    elseif starting_cell.type & SOUTH ~= 0 then
        current_cell = starting_cell[SOUTH];
        goto_direction = SOUTH;
    elseif starting_cell.type & EAST ~= 0  then
        current_cell = starting_cell[EAST];
        goto_direction = EAST;
    elseif starting_cell.type & WEST ~= 0 then
        current_cell = starting_cell[WEST];
        goto_direction = WEST;
    end

    assert(current_cell);

    local x_corners = {};
    local y_corners = {};
    local corners_count = 0;

    do
        local is_corner = IsCorner(starting_cell);
        if is_corner then 
            table.insert(x_corners, starting_cell.x);
            table.insert(y_corners, starting_cell.y);
            corners_count = corners_count + 1;
        end;
    end

    starting_cell.is_main_loop = true;

    while current_cell ~= starting_cell do

        current_cell.is_main_loop = true;
        
        local is_corner = IsCorner(current_cell);
        if is_corner then
            table.insert(x_corners, current_cell.x);
            table.insert(y_corners, current_cell.y);
            corners_count = corners_count + 1;
        end

        current_cell, goto_direction = FollowCell(current_cell, GetOpposingDirection(goto_direction));
    end

    
    local is_inside_loop = false;
    for yy = 1, y - 1 do
        for xx = 1, x - 1 do
            local cell = world_map[xx][yy];
            --[[if not cell or not cell.is_main_loop then
                local result = IsPointInLoop(corners_count, x_corners, y_corners, xx, yy);
                if result then solution = solution + 1 end;
            end]]

            if cell and cell.is_main_loop then
                if cell.type & SOUTH ~= 0 then
                    is_inside_loop = not is_inside_loop;
                end
            end

            if (not cell or not cell.is_main_loop) and is_inside_loop then
                solution = solution + 1;
            end
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