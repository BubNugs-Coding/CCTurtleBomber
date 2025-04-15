print("Simple movement test - will move forward 5 blocks")
print("Press Enter to begin")
read()

-- Check and handle fuel first
local fuelLevel = turtle.getFuelLevel()
if fuelLevel < 5 then
    print("Low fuel! Current level: " .. fuelLevel)
    print("Attempting to refuel...")
    turtle.refuel()
    fuelLevel = turtle.getFuelLevel()
    if fuelLevel < 5 then
        print("Failed to get enough fuel! Need at least 5 fuel.")
        return
    end
    print("Successfully refueled. New fuel level: " .. fuelLevel)
end

-- Try to move forward 5 times
for i = 1, 5 do
    print("Attempting move " .. i)
    
    -- First check if there's a block in front
    if turtle.detect() then
        print("Block detected, trying to dig")
        if not turtle.dig() then
            print("Failed to dig block! Might be unbreakable or need different tool")
            break
        end
        sleep(0.5)
    end
    
    -- Try to move with retry logic
    local tries = 0
    local maxTries = 3
    local success = false
    
    while tries < maxTries and not success do
        success = turtle.forward()
        if not success then
            print("Move attempt " .. (tries + 1) .. " failed, retrying...")
            sleep(0.5)
        end
        tries = tries + 1
    end
    
    if success then
        print("Successfully moved forward")
    else
        print("Failed to move forward after " .. maxTries .. " attempts!")
        break
    end
    
    sleep(0.5) -- Short pause between moves
end

print("Test complete")