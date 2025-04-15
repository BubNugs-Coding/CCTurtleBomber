-- Helper function to check if we have enough TNT
local function checkTNTAmount(required)
    local total = 0
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        -- Print complete item details for debugging
        if item then
            print("Slot " .. slot .. " contains:")
            for key, value in pairs(item) do
                print("  " .. key .. ": " .. tostring(value))
            end
        end
        -- Check for different possible TNT names
        if item and (item.name == "minecraft:tnt" or item.name == "TNT" or item.name == "tnt") then
            total = total + item.count
        end
    end
    return total >= required
end

-- Direction constants (0 = north, 1 = east, 2 = south, 3 = west)
local NORTH = 0
local EAST = 1
local SOUTH = 2
local WEST = 3

-- Add current facing direction variable (assume turtle starts facing north)
local currentDirection = NORTH

-- Update turn function to use shortest path
local function turnToDirection(targetDirection)
    print("Current direction:", currentDirection)
    print("Target direction:", targetDirection)
    
    if currentDirection == targetDirection then
        print("Already facing correct direction")
        return -- Already facing the right way
    end
    
    -- Calculate number of turns needed for clockwise and counterclockwise
    local clockwiseTurns = (targetDirection - currentDirection) % 4
    local counterclockwiseTurns = (currentDirection - targetDirection) % 4
    
    -- Choose the shortest path
    if clockwiseTurns <= counterclockwiseTurns then
        print("Turning right " .. clockwiseTurns .. " times")
        for i = 1, clockwiseTurns do
            turtle.turnRight()
            currentDirection = (currentDirection + 1) % 4
            print("New direction:", currentDirection)
        end
    else
        print("Turning left " .. counterclockwiseTurns .. " times")
        for i = 1, counterclockwiseTurns do
            turtle.turnLeft()
            currentDirection = (currentDirection - 1) % 4
            if currentDirection < 0 then currentDirection = 3 end
            print("New direction:", currentDirection)
        end
    end
    
    print("Final direction:", currentDirection)
end

-- Add fuel checking function
local function checkAndRefuel(requiredFuel)
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" then return true end
    
    if fuelLevel < requiredFuel then
        print("Low fuel! Current level: " .. fuelLevel)
        print("Attempting to refuel...")
        
        -- Search for fuel items in inventory
        for slot = 1, 16 do
            turtle.select(slot)
            -- Try to refuel with the item in this slot
            if turtle.refuel(1) then
                -- Successfully found and used fuel
                fuelLevel = turtle.getFuelLevel()
                if fuelLevel >= requiredFuel then
                    print("Successfully refueled. New fuel level: " .. fuelLevel)
                    return true
                end
            end
        end
        
        print("Failed to get enough fuel! Need at least " .. requiredFuel .. " fuel.")
        return false
    end
    return true
end

-- Updated movement functions with better retry logic
local function moveForward()
    local tries = 0
    local maxTries = 3
    local success = false
    
    while tries < maxTries and not success do
        success = turtle.forward()
        if not success then
            if turtle.detect() then
                if not turtle.dig() then
                    print("Failed to dig block! Might be unbreakable or need different tool")
                    return false
                end
                sleep(0.5)
            else
                print("Move attempt " .. (tries + 1) .. " failed, retrying...")
                sleep(0.5)
            end
        end
        tries = tries + 1
    end
    
    return success
end

local function moveUp()
    local tries = 0
    local maxTries = 3
    local success = false
    
    while tries < maxTries and not success do
        success = turtle.up()
        if not success then
            if turtle.detectUp() then
                if not turtle.digUp() then
                    print("Failed to dig block above! Might be unbreakable or need different tool")
                    return false
                end
                sleep(0.5)
            else
                print("Move up attempt " .. (tries + 1) .. " failed, retrying...")
                sleep(0.5)
            end
        end
        tries = tries + 1
    end
    
    return success
end

local function moveDown()
    local tries = 0
    local maxTries = 3
    local success = false
    
    while tries < maxTries and not success do
        success = turtle.down()
        if not success then
            if turtle.detectDown() then
                if not turtle.digDown() then
                    print("Failed to dig block below! Might be unbreakable or need different tool")
                    return false
                end
                sleep(0.5)
            else
                print("Move down attempt " .. (tries + 1) .. " failed, retrying...")
                sleep(0.5)
            end
        end
        tries = tries + 1
    end
    
    return success
end

-- Update goToCoordinates function to check fuel before starting
local function goToCoordinates(currentX, currentY, currentZ, targetX, targetY, targetZ)
    -- Calculate manhattan distance for fuel requirement
    local fuelNeeded = math.abs(targetX - currentX) + 
                      math.abs(targetY - currentY) + 
                      math.abs(targetZ - currentZ)
    
    -- Add some buffer fuel and check
    if not checkAndRefuel(fuelNeeded + 10) then
        print("Not enough fuel for the journey!")
        return false
    end
    
    print(string.format("Current position: %d, %d, %d", currentX, currentY, currentZ))
    print(string.format("Moving to: %d, %d, %d", targetX, targetY, targetZ))
    
    local x, y, z = currentX, currentY, currentZ
    
    print("Starting navigation from:", x, y, z)
    
    -- Move to target Y level first
    while y < targetY do
        if not moveUp() then
            print("Failed to move up")
            return false
        end
        y = y + 1
    end
    while y > targetY do
        if not moveDown() then
            print("Failed to move down")
            return false
        end
        y = y - 1
    end
    
    -- Move in X direction (fixed direction logic)
    if x < targetX then
        turnToDirection(EAST)
        while x < targetX do
            if not moveForward() then
                print("Failed to move east")
                return false
            end
            x = x + 1
            print("Current X position:", x)
        end
    elseif x > targetX then
        turnToDirection(WEST)
        while x > targetX do
            if not moveForward() then
                print("Failed to move west")
                return false
            end
            x = x - 1
            print("Current X position:", x)
        end
    end
    
    -- Move in Z direction (fixed direction logic)
    if z < targetZ then
        turnToDirection(SOUTH)
        while z < targetZ do
            if not moveForward() then
                print("Failed to move south")
                return false
            end
            z = z + 1
            print("Current Z position:", z)
        end
    elseif z > targetZ then
        turnToDirection(NORTH)
        while z > targetZ do
            if not moveForward() then
                print("Failed to move north")
                return false
            end
            z = z - 1
            print("Current Z position:", z)
        end
    end
    
    print("Final position reached:", x, y, z)
    return true
end

-- Replace redstone torch check function with redstone block check
local function hasRedstoneBlock()
    for slot = 1, 16 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if item and (item.name == "minecraft:redstone_block" or item.name == "redstone_block") then
            return true, slot
        end
    end
    return false, nil
end

-- Update TNT placement function to place TNT in a 3D pattern
local function placeTNTWithRedstone(amount, tx, ty, tz)
    print("Checking for redstone block...")
    local hasBlock, blockSlot = hasRedstoneBlock()
    if not hasBlock then
        print("Error: No redstone block found!")
        return 0, tx, ty, tz
    end

    -- Track our position relative to the starting point
    local currentX = 0
    local currentY = 0
    local currentZ = 0
    
    -- Track placed TNT count
    local placed = 0
    
    -- Direction offsets for the 4 sides
    local directions = {
        {x=1, z=0},  -- East
        {x=0, z=1},  -- South
        {x=-1, z=0}, -- West
        {x=0, z=-1}  -- North
    }
    
    -- Calculate how many full layers we need
    local fullLayers = math.floor(amount / 4)
    local remainingTNT = amount % 4
    
    print("Placing TNT in a 3D pattern...")
    print("Full layers: " .. fullLayers .. ", Remaining TNT: " .. remainingTNT)
    
    -- Place TNT in layers
    for layer = 1, fullLayers + (remainingTNT > 0 and 1 or 0) do
        print("Working on layer " .. layer)
        
        -- For each layer, place TNT on all 4 sides (or fewer for the last layer)
        local sidesThisLayer = (layer <= fullLayers) and 4 or remainingTNT
        
        for side = 1, sidesThisLayer do
            -- Turn to face the direction for this side
            if side == 1 then
                -- Starting direction is already correct
            else
                turtle.turnRight()
            end
            
            -- Clear path and move forward
            if turtle.detect() then
                print("Clearing path for side " .. side)
                if not turtle.dig() then
                    print("Failed to clear path!")
                    -- Return to original orientation
                    for i = side, 4 do
                        turtle.turnLeft()
                    end
                    return placed, tx + currentX, ty + currentY, tz + currentZ
                end
                sleep(0.5)
            end
            
            if not turtle.forward() then
                print("Failed to move forward for side " .. side)
                -- Return to original orientation
                for i = side, 4 do
                    turtle.turnLeft()
                end
                return placed, tx + currentX, ty + currentY, tz + currentZ
            end
            
            -- Update our relative position
            currentX = currentX + directions[side].x
            currentZ = currentZ + directions[side].z
            
            -- Clear space for TNT if needed
            if turtle.detectDown() then
                print("Clearing space for TNT on side " .. side)
                if not turtle.digDown() then
                    print("Failed to clear space for TNT!")
                    -- Move back to center
                    turtle.back()
                    -- Update position
                    currentX = currentX - directions[side].x
                    currentZ = currentZ - directions[side].z
                    -- Return to original orientation
                    for i = side, 4 do
                        turtle.turnLeft()
                    end
                    return placed, tx + currentX, ty + currentY, tz + currentZ
                end
                sleep(0.5)
            end
            
            -- Place TNT
            for slot = 1, 16 do
                turtle.select(slot)
                local item = turtle.getItemDetail()
                if item and (item.name == "minecraft:tnt" or item.name == "TNT" or item.name == "tnt") then
                    if turtle.placeDown() then
                        placed = placed + 1
                        print(string.format("Placed TNT %d/%d on side %d of layer %d", 
                              placed, amount, side, layer))
                        break
                    else
                        print("Failed to place TNT on side " .. side)
                        -- Move back to center
                        turtle.back()
                        -- Update position
                        currentX = currentX - directions[side].x
                        currentZ = currentZ - directions[side].z
                        -- Return to original orientation
                        for i = side, 4 do
                            turtle.turnLeft()
                        end
                        return placed, tx + currentX, ty + currentY, tz + currentZ
                    end
                end
            end
            
            -- Move back to center
            turtle.back()
            
            -- Update position
            currentX = currentX - directions[side].x
            currentZ = currentZ - directions[side].z
        end
        
        -- Return to original orientation after placing all sides
        turtle.turnRight()
        
        -- Move up to the next layer if needed
        if layer < fullLayers + (remainingTNT > 0 and 1 or 0) then
            -- Clear space above if needed
            if turtle.detectUp() then
                print("Clearing space to move up to next layer")
                if not turtle.digUp() then
                    print("Failed to clear space above!")
                    return placed, tx + currentX, ty + currentY, tz + currentZ
                end
                sleep(0.5)
            end
            
            if not turtle.up() then
                print("Failed to move up to next layer!")
                return placed, tx + currentX, ty + currentY, tz + currentZ
            end
            
            -- Update Y position
            currentY = currentY + 1
        end
    end
    
    if placed > 0 then
        -- Now place redstone block at the center of the bottom layer
        print("Moving down to place redstone block...")
        
        -- Move down to the bottom
        for i = 1, currentY do
            if not turtle.down() then
                print("Failed to move down!")
                return placed, tx + currentX, ty + currentY, tz + currentZ
            end
        end
        
        -- Update position
        currentY = 0
        
        -- Clear space for redstone block if needed
        if turtle.detectDown() then
            print("Clearing space for redstone block...")
            if not turtle.digDown() then
                print("Failed to clear space for redstone block!")
                return placed, tx + currentX, ty + currentY, tz + currentZ
            end
            sleep(0.5)
        end
        
        -- Select and place redstone block
        turtle.select(blockSlot)
        print("TNT pattern ready - placing redstone block!")
        if not turtle.placeDown() then
            print("Failed to place redstone block!")
            return placed, tx + currentX, ty + currentY, tz + currentZ
        end
        
        print("TNT pattern armed! Waiting 10 seconds before returning...")
        
        -- Stay in place and wait 10 seconds
        for i = 10, 1, -1 do
            print("Returning in " .. i .. " seconds...")
            sleep(1)
        end
    end
    
    return placed, tx + currentX, ty + currentY, tz + currentZ
end

-- Fix the return to start function to be more reliable
local function returnToStart(startX, startY, startZ, currentX, currentY, currentZ)
    print("Returning to start position...")
    print(string.format("Current: %d, %d, %d -> Start: %d, %d, %d", 
          currentX, currentY, currentZ, startX, startY, startZ))
    
    -- Ensure we have valid coordinates
    if not currentX or not currentY or not currentZ or
       not startX or not startY or not startZ then
        print("Error: Invalid coordinates for return journey!")
        return false
    end
    
    -- Move in X direction first
    if currentX > startX then
        turnToDirection(WEST)
        local distance = currentX - startX
        print("Moving west " .. distance .. " blocks")
        for i = 1, distance do
            if not moveForward() then
                print("Clearing path west...")
                turtle.dig()
                sleep(0.5)
                if not turtle.forward() then
                    print("Failed to move west! Continuing anyway...")
                end
            end
            print("X position: " .. (currentX - i))
        end
        currentX = startX
    elseif currentX < startX then
        turnToDirection(EAST)
        local distance = startX - currentX
        print("Moving east " .. distance .. " blocks")
        for i = 1, distance do
            if not moveForward() then
                print("Clearing path east...")
                turtle.dig()
                sleep(0.5)
                if not turtle.forward() then
                    print("Failed to move east! Continuing anyway...")
                end
            end
            print("X position: " .. (currentX + i))
        end
        currentX = startX
    end
    
    -- Move in Z direction
    if currentZ > startZ then
        turnToDirection(NORTH)
        local distance = currentZ - startZ
        print("Moving north " .. distance .. " blocks")
        for i = 1, distance do
            if not moveForward() then
                print("Clearing path north...")
                turtle.dig()
                sleep(0.5)
                if not turtle.forward() then
                    print("Failed to move north! Continuing anyway...")
                end
            end
            print("Z position: " .. (currentZ - i))
        end
    elseif currentZ < startZ then
        turnToDirection(SOUTH)
        local distance = startZ - currentZ
        print("Moving south " .. distance .. " blocks")
        for i = 1, distance do
            if not moveForward() then
                print("Clearing path south...")
                turtle.dig()
                sleep(0.5)
                if not turtle.forward() then
                    print("Failed to move south! Continuing anyway...")
                end
            end
            print("Z position: " .. (currentZ + i))
        end
    end
    
    -- Finally adjust Y level
    if currentY > startY then
        local distance = currentY - startY
        print("Moving down " .. distance .. " blocks")
        for i = 1, distance do
            if not moveDown() then
                print("Clearing path down...")
                turtle.digDown()
                sleep(0.5)
                if not turtle.down() then
                    print("Failed to move down! Continuing anyway...")
                end
            end
        end
    elseif currentY < startY then
        local distance = startY - currentY
        print("Moving up " .. distance .. " blocks")
        for i = 1, distance do
            if not moveUp() then
                print("Clearing path up...")
                turtle.digUp()
                sleep(0.5)
                if not turtle.up() then
                    print("Failed to move up! Continuing anyway...")
                end
            end
        end
    end
    
    print("Reached start position!")
    return true
end

-- Main program
print("=== TNT Placer Program ===")
print("Enter turtle's current coordinates:")
write("Current X: ")
local currentX = tonumber(read())
write("Current Y: ")
local currentY = tonumber(read())
write("Current Z: ")
local currentZ = tonumber(read())

print("\nEnter turtle's current facing direction:")
print("0 = North, 1 = East, 2 = South, 3 = West")
write("Direction: ")
local inputDirection = tonumber(read())
if inputDirection and inputDirection >= 0 and inputDirection <= 3 then
    currentDirection = inputDirection
else
    print("Error: Invalid direction! Must be 0-3")
    return
end

print("\nEnter target coordinates:")
write("Target X: ")
local targetX = tonumber(read())
write("Target Y: ")
local targetY = tonumber(read())
write("Target Z: ")
local targetZ = tonumber(read())
write("Number of TNT blocks to place: ")
local tntAmount = tonumber(read())

-- Validate inputs
if not (currentX and currentY and currentZ and targetX and targetY and targetZ and tntAmount) then
    print("Error: Invalid input! Please enter numbers only.")
    return
end

-- Check TNT availability
if not checkTNTAmount(tntAmount) then
    print("Error: Not enough TNT in inventory!")
    print(string.format("Required: %d blocks", tntAmount))
    return
end

-- Safety confirmation
print("\nWARNING: This will place TNT at the specified location!")
print("Type 'CONFIRM' to proceed:")
local confirmation = read()
if confirmation ~= "CONFIRM" then
    print("Operation cancelled.")
    return
end

-- Navigate to target
print("\nMoving to target location...")
if not goToCoordinates(currentX, currentY, currentZ, targetX, targetY, targetZ) then
    print("Failed to reach target location!")
    return
end

-- Replace the TNT placement section with:
print("Placing TNT with redstone block...")
local placed, finalX, finalY, finalZ = placeTNTWithRedstone(tntAmount, targetX, targetY, targetZ)

if placed > 0 then
    print("TNT placed and lit! Returning to start quickly...")
    print(string.format("Current position after TNT placement: %d, %d, %d", finalX, finalY, finalZ))
    returnToStart(currentX, currentY, currentZ, finalX, finalY, finalZ)
else
    print("Failed to place TNT! Returning to start...")
    returnToStart(currentX, currentY, currentZ, targetX, targetY, targetZ)
end

print("\nOperation complete!")
print(string.format("Successfully placed %d/%d TNT blocks", placed, tntAmount))