--Deposit
--Withdraw

serverID = 0

function drawStartScreen(selectedOption)
    term.clear()
    term.setCursorPos(2,2)
    if selectedOption == 0 then
        term.write("-> Deposit")
        term.setCursorPos(3,2)
        term.write("   Withdraw")
    elseif selectedOption == 1 then
        term.write("   Deposit")
        term.setCursorPos(3,2)
        term.write("-> Withdraw")
    end
end

function drawDepositScreen()
    term.clear()
    term.setCursorPos(2,2)
    term.write("Please deposit your items in the chest to the right. Once you are done press enter.")
    term.setCursorPos(3,1)
    term.write("-> Done")
end

function drawDepositProcessingScreen(itemNumber,amount) --Progress from 0 to 10 
    term.clear()
    term.setCursorPos(2,2)
    term.write("Processing your deposit. This may take a while")
    term.setCursorPos(3,2)
    term.write("depending on the amount of items you deposited")
    term.setCursorPos(5,2)
    term.write("Processed items: " .. itemNumber)
    term.setCursorPos(6,2)
    term.write("Money equivalent: " .. amount .. "eC")
end

function drawDepositConfirmationScreen(itemCount,amount,selectedOption)
    term.clear()
    term.setCursorPos(2,2)
    term.write("The system detected the following:")
    term.setCursorPos(4,2)
    term.write(itemCount .. " items")
    term.setCursorPos(5,2)
    term.write("worth" .. amount .. "eC")
    term.setCursorPos(7,2)
    term.write("Do you wish to proceed?")
    term.setCursorPos(9,2)
    if selectedOption == 0 then
        term.write("-> Confirm")
        term.setCursorPos(10,2)
        term.write("   Cancel")
    elseif selectedOption == 1 then
        term.write("   Confirm")
        term.setCursorPos(10,2)
        term.write("-> Cancel")
    end
end

function drawCompletedScreen()
    term.clear()
    term.setCursorPos(2,2)
    term.write("Deposit completed successfully!")
    term.setCursorPos(4,2)
    term.write("Thank you for using eCoin")
end

function drawCancelingScreen()
    term.clear()
    term.setCursorPos(2,2)
    term.write("Transaction canceled! The deposit is being returned...")
end

function drawCanceledScreen()
    term.clear()
    term.setCursorPos(2,2)
    term.write("Deposit canceled successfully!")
    term.setCursorPos(4,2)
    term.write("Thank you for using eCoin")
end


function decomposeMessage(message)
    words = {}
    for word in message:gmatch("[^_]+") do
        table.insert(words,word)
    end
    return words
end


selectedOption = 0
while true do
    drawStartScreen(selectedOption)
    local event, key = os.pullEvent("key")
    if key == keys.up and selectedOption > 0 then
        selectedOption = selectedOption - 1
    elseif key == keys.down and selectedOption < 1 then
        selectedOption = selectedOption + 1
    elseif key == keys.enter then
        break
    end
end

if selectedOption == 0 then
    drawDepositScreen()
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.enter then
            break
        end
    end
    drawDepositProcessingScreen(0)
    rednet.send(serverID,"process_deposit")
    item_count = 0
    amount = 0
    while true do
        senderID, message = rednet.recv()
        message = decomposeMessage(message)
        if senderID == serverID and message[1] == "deposit" and message[2] == "status" then
            drawDepositProcessingScreen()
        end
        if senderID == serverID and message[1] == "deposit" and message[2] == "completed" then
            item_count = message[3]
            amount = message[4]
            break
        end
    end
    
    selectedOption = 0
    while true do
        drawDepositConfirmationScreen(item_count,amount,selectedOption)
        local event, key = os.pullEvent("key")
        if key == keys.up and selectedOption > 0 then
            selectedOption = selectedOption -1
        elseif key == keys.down and selectedOption < 1 then
            selectedOption = selectedOption + 1
        elseif key == keys.enter then
            break
        end
    end
    if selectedOption == 0 then
        rednet.send(serverID,"confirm_deposit")
        senderID, message = rednet.recv()
        if senderID == serverID and message == "deposit_confirmed" then
            drawCompletedScreen()
            sleep(2)
        end
    elseif selectedOption == 1 then
        rednet.send(serverID,"cancel_deposit")
        drawCancelingScreen()
        senderID, message = rednet.recv()
        if senderID == serverID and message == "deposit_canceled" then
            drawCanceledScreen()
            sleep(2)
        end
    end
elseif selectedOption == 1 then
    drawRetrievingItemsScreen()
    rednet.send(serverID,"withdraw_item_list")
    senderID,message = rednet.recv()
    message = decomposeMessage(message)
    if senderID == serverID and message[1] == "withdraw" and message[2] == "item" and message[3] == "list" then
        options = {}
        quantities = {}
        options_count = 0
        for i = 4, #message, 1 do
            options_count += 1
            options[options_count] = message[i]
            quantities[options_count] = message[i+1]
        end

        options_start_index = 0
    end
end

--                   ########
--                 ###      ###
--   ########      ###      ###
-- ####    ####    ###
--###        ###   ###
--##############   ###
--###              ###
--#####    ####    ###      ###
--   #######         ########
