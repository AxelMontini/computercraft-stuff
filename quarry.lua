-- Position relative to the starting point
local x = 0
local y = 0
local z = 0

local FACING = {PX=0, PZ=1, NX=2, NZ=3}

local tfacing = FACING.PX

local FUEL_SLOT = 1

local dumping = false

function hasFuel()
    return turtle.getFuelLevel() >= 20
end

function waitForFuel()
    -- If no fuel, wait for it. Otherwise, proceed
    if not hasFuel() then
        while not hasFuel() do
            turtle.select(FUEL_SLOT)
            turtle.refuel()
            turtle.dropDown() -- Empty slow after refueling (if it isn't fuel it should be emptied)
        end
        -- Pick up the dropped stuff
        turtle.suckDown()
    end
end

-- Movement helpers that update the state
function goDown()
    printState()
    waitForFuel()
    local didGo = turtle.down()

    if didGo then
        y = y + 1 -- NOTE: Y axis points down!
    end

    return didGo
end

function goUp()
    printState()
    waitForFuel()
    local didGo = turtle.up()

    if didGo then
        y = y - 1
    end

    return didGo
end

function goForward()
    printState()
    waitForFuel()
    local didGo = turtle.forward()

    if didGo then
        if tfacing == FACING.PX then
            x = x + 1
        elseif tfacing == FACING.NX then
            x = x - 1
        elseif tfacing == FACING.PZ then
            z = z + 1
        elseif tfacing == FACING.NZ then
            z = z - 1
        end
    end

    return didGo
end

function goBack()
    printState()
    waitForFuel()
    local didGo = turtle.back()

    if didGo then
        if tfacing == FACING.NX then
            x = x + 1
        elseif tfacing == FACING.PX then
            x = x - 1
        elseif tfacing == FACING.NZ then
            z = z + 1
        elseif tfacing == FACING.PZ then
            z = z - 1
        end
    end

    return didGo
end

function rotateLeft(facing)
    return (tfacing - 1 + 4) % 4 -- Add 4 in case we end up negative
end

function rotateRight(facing)
    return (tfacing + 1) % 4
end

function turnRight()
    printState()
    waitForFuel()
    local didTurn = turtle.turnRight()
    if didTurn then
        tfacing = rotateRight(tfacing)
    end

    return didTurn
end

function turnLeft()
    printState()
    waitForFuel()
    local didTurn = turtle.turnLeft()
    if didTurn then
        tfacing = rotateLeft(tfacing)
    end

    return didTurn
end

-- Convert a facing to text
function facingToText(tfacing)
    if tfacing == FACING.PX then
        return "+X"
    elseif tfacing == FACING.NX then
        return "-X"
    elseif tfacing == FACING.PZ then
        return "+Z"
    elseif tfacing == FACING.NZ then
        return "-Z"
    end
end

function printState()
    term.setTextColor(colors.black)
    term.setBackgroundColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
    term.write("Relative pos X Y Z: " .. x .. " " .. y .. " " .. z)
    term.setCursorPos(1, 2)
    term.write("Relative facing: " .. facingToText(tfacing))
    term.setCursorPos(1, 3)
    term.write("Fuel: " .. turtle.getFuelLevel() .. " ")

    if not hasFuel() then
        term.write("NEEDS REFUELING!")
    end

    if dumping then
        term.setCursorPos(1, 5)
        term.write("!DUMPING PROCEDURE!")
    end
end

-- suck twice and check if couldn't suck. In that case, empty
function suckDownProcedure()
    turtle.suckDown()
    if turtle.getItemCount(16) > 0 then
        goEmpty()
    end
end

function goEmpty()
    local old_x = x
    local old_y = y
    local old_z = z
    local old_facing = tfacing

    dumping = true

    -- Go back to the corner of the quarry. There will be a chest on top.
    if x ~= 0 then
        while tfacing ~= FACING.NX do turnRight() end
        while x ~= 0 do goForward() end
    end

    if z ~= 0 then
        while tfacing ~= FACING.NZ do turnRight() end
        while z ~= 0 do goForward() end
    end

    
    while y ~= 0 do goUp() end

    -- We're now below the chest
    -- Empty items

    for i = 1, 16, 1 do
        turtle.select(i)
        turtle.dropUp()
    end

    -- Go back to where we left
    --restore height
    while y < old_y do goDown() end

    -- restore z
    if z ~= old_z then
        while tfacing ~= FACING.PZ do turnRight() end
        while z <= old_z do goForward() end
    end

    -- restore x
    if x ~= old_x then
        while tfacing ~= FACING.PX do turnRight() end
        while x <= old_x do goForward() end
    end

    -- restore rotation
    while tfacing ~= old_facing do turnRight() end

    dumping = false
end

function uTurnRight()
    turnRight()
    goForward()
    turnRight()
end

function uTurnLeft()
    turnLeft()
    goForward()
    turnLeft()
end

local length = 15 -- must be 
local width = 15
local height = 15

while x ~= length and y ~= height and z ~= width do
    if x == length - 1 and z == width - 1 and tfacing == FACING.PX then -- reached a corner, should now start digging the other way
        turnLeft()
        while z > 0 do goForward() end
        turnLeft()
        while x > 0 do goForward() end
        turnLeft()
        turnLeft()
        goDown()
    elseif x == 0 and z == width - 1 and tfacing == FACING.NX then -- reached a corner, should now start digging the other way
        turnRight()
        while z > 0 do goForward() end
        turnRight()
        goDown()
    elseif x + 1 >= length and tfacing == FACING.PX then
        -- Have to right
        turtle.digDown()
        suckDownProcedure()
        uTurnRight()
    elseif x <= 0 and tfacing == FACING.NX then
        -- Have to turn left
        turtle.digDown()
        suckDownProcedure()
        uTurnLeft()
    else
        -- Dig and suck, then move forward and turn if necessary
        turtle.digDown()
        suckDownProcedure()

        goForward()
    end
end

-- Done digging, go back up

os.sleep(5)