-- Position relative to the starting point
local x = 0
local y = 0
local z = 0

local FACING = {PX=0, NX=1, PZ=2, NZ=3}

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

function turnRight()
    local didTurn = turtle.turnRight()
    if didTurn then
        local newFacing = (tfacing + 1 + 4) % 4
        
        tfacing = newFacing
    end

    return didTurn
end

function turnLeft()
    local didTurn = turtle.turnLeft()
    if didTurn then
        local newFacing = (tfacing + 1 + 4) % 4

        tfacing = newFacing
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
end



local length = 15
local width = 15
local height = 15

while true do
    printState()
    if x >= length and tfacing == FACING.PX then
        -- Have to right
        turtle.digDown()
        turtle.suckUp()
        turnRight()
        goForward()
        turnRight()
    elseif x <= 0 and tfacing == FACING.NX then
        -- Have to turn left
        turtle.digDown()
        turtle.suckUp()
        turnLeft()
        goForward()
        turnLeft()
    else
        -- Dig and suck, then move forward and turn if necessary
        turtle.digDown()
        turtle.suckDown()

        goForward()
    end
end

os.sleep(5)