rednet.open("left")

print("eCoin SERVER (ID=" .. os.getComputerID() ..")")

function getAccounts()
    accounts = {}
    accounts_file = fs.open("accounts","r")
    if accounts_file then
        for line in file:lines() do
            local username, password, balance = line:match("([^,]+),([^,]+),([^,]+)")
            if username and password and balance then
                balance = tonumber(balance)
                local account = {username = username, password = password, balance = balance}
                table.insert(accounts, account)
            else
                print("Invalid line:", line)
            end
        end
        file:close()
    else
        print("Failed to open accounts file")
        return nil
    end

end


accounts = getAccounts()
if accounts == nil then
    print("ERROR failed to retrieve accounts!")
    sleep(3)
    os.shutdown()
end

while true do
    senderID,message = rednet.receive()
    if message == "accounts":
        print(account)
    end
end