-- A simple unit which is "timid".
-- When it going to change sector and sees another unit in that sector
-- it halts, changes color to pink, then goes backwards. When it
-- reflects from the edge it changes back to white.

local this_unit={};		-- Our unit function table

-- The standard local variables
local x, y, dx, dy		-- Where we are and fast we move
local color = "white"		-- Our default color
local style = "unit"		-- Our style
local tick			-- Size of a clock tick msec
local me = unit.self()		-- This is me
local ammo,shield = 0,0

local xsize,ysize = region.size()	-- The size of the region

-- The default unit interface.

function this_unit.start() end

function this_unit.get_position() return x,y; end

function this_unit.set_position(a1, a2) x,y = a1,a2; end

function this_unit.get_speed() return dx,dy; end

function this_unit.set_speed(a1, a2) dx,dy = a1,a2; end

function this_unit.set_tick(a1) tick = a1; end

local function move_xy_bounce(x, y, dx, dy, valid_x, valid_y)
   local nx = x + dx
   local ny = y + dy
   -- Bounce off the edge
   if (not valid_x(nx)) then
      color = "white"		-- Go back to white when we bounce
      nx = x - dx
      dx = -dx
   end
   -- Bounce off the edge
   if (not valid_y(ny)) then
      color = "white"		-- Go back to white when we bounce
      ny = y - dy
      dy = -dy
   end
   return nx, ny, dx, dy
end

local function move(x, y, dx, dy)
   local nx,ny,ndx,ndy = move_xy_bounce(x, y, dx, dy,
					region.valid_x, region.valid_y)
   -- Where we were and where we are now.
   local osx,osy = region.sector(x, y)
   local nsx,nsy = region.sector(nx, ny)
   if (osx == nsx and osy == nsy) then
      -- Same sector, just set the values
      return nx,ny,ndx,ndy
   else
      -- Simple avoidance scheme
      if (region.get_sector(nx, ny)) then
	 -- Something there, change color, pause and reverse
	 color = "yellow"
	 return x,y,-dx,-dy
      else
	 -- In new sector, move us to the right sector
	 region.rem_sector(x, y)
	 region.add_sector(nx, ny)
	 return nx,ny,ndx,ndy
      end
   end
end

function this_unit.tick()
   x,y,dx,dy = move(x, y, dx, dy)
end

-- The unit has been zapped and will die
function this_unit.zap()
   region.rem_sector(x, y)
end

-- Return the unit table
return this_unit