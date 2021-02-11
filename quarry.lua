-- Position relative to the starting point
local x = 0
local y = 0
local z = 0

local FACING = {PX=0, PZ=1, NX=2, NZ=3}

local tfacing = FACING.PX

local FUEL_SLOT = 1

-- Movement helpers that update the state
function goDown()
    local didGo = turtle.down()

    if didGo then
        y = y - 1
    end

    return didGo
end

function goUp()
    local didGo = turtle.up()

    if didGo then
        y = y + 1
    end

    return didGo
end

function goForward()
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
    local didTurn = turtle.turnRight()
    if didTurn then
        tfacing = rotateRight(tfacing)
    end

    return didTurn
end

function turnLeft()
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
    termn.setCursorPos(1, 3)
    term.write()
end

-- suck twice and check if couldn't suck. In that case, empty
function suckDownProcedure()
    turtle.suckDown()
    local didSuck, reason = turtle.suckDown()

    if string.find(reason, "space") then -- no space, must go empty stuff
        goEmpty()
    end
end

function goEmpty()
    local old_x = x
    local old_y = y
    local old_z = z
    local old_facing = facing

    -- Go back to the corner of the quarry. There will be a chest on top.

    -- Then empty the items there and go back to digging
    turtle.
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

while x != length and y != height and z != width do
    printState()
    if x == length - 1 and z == width - 1 and tfacing == FACING.PX then -- reached a corner, should now start digging the other way
        turnLeft()
        for i = 0, width, 1 do goForward() end
        turnLeft()
        for i = 0, length, 1 do goForward() end
        turnLeft()
        turnLeft()
        goDown()
    elseif x == 0 and z == width - 1 and tfacing == FACING.NX then -- reached a corner, should now start digging the other way
        turnRight()
        for i = 0, width, 1 do goForward() end
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