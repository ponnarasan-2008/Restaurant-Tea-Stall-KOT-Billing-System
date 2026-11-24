$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

# 1. Login as Waiter
$loginRes = Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/login' -Method Post -ContentType 'application/json' -Body '{"username":"waiter","password":"waiter123"}' -WebSession $session
Write-Host "1. Waiter Logged In:" $loginRes.name "Role:" $loginRes.role

# 2. Get Menu Items
$items = Invoke-RestMethod -Uri 'http://localhost:8080/api/items' -Method Get -WebSession $session
$masalaTea = $items | Where-Object { $_.itemName -like "*Masala Tea*" }
$samosa = $items | Where-Object { $_.itemName -like "*Samosa*" }

# 3. Create Order
$orderBody = @{
    tableNumber = "T-5"
    orderType = "DINE_IN"
    customerName = "Kanishkar"
    customerPhone = "9876543210"
    specialInstructions = "Less sugar in tea"
    items = @(
        @{ itemId = $masalaTea.itemId; quantity = 2; specialInstruction = "Less sugar" },
        @{ itemId = $samosa.itemId; quantity = 1; specialInstruction = "Extra chutney" }
    )
} | ConvertTo-Json -Depth 5

$order = Invoke-RestMethod -Uri 'http://localhost:8080/api/orders' -Method Post -ContentType 'application/json' -Body $orderBody -WebSession $session
Write-Host "2. Order Created ID:" $order.orderId "Status:" $order.orderStatus "Table:" $order.tableNumber

# 4. Check Generated KOT in Kitchen
$kots = Invoke-RestMethod -Uri 'http://localhost:8080/api/kots/active' -Method Get -WebSession $session
$newKot = $kots | Where-Object { $_.order.orderId -eq $order.orderId }
Write-Host "3. KOT Auto-Generated Number:" $newKot.kotNumber "Priority:" $newKot.priority "Status:" $newKot.kotStatus

# 5. Kitchen Staff Accepts KOT & Marks READY
$loginKitchen = Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/login' -Method Post -ContentType 'application/json' -Body '{"username":"kitchen","password":"kitchen123"}' -WebSession $session
$statusBody = @{ status = "PREPARING" } | ConvertTo-Json
$updatedKot = Invoke-RestMethod -Uri "http://localhost:8080/api/kots/$($newKot.kotId)/status" -Method Put -ContentType 'application/json' -Body $statusBody -WebSession $session
Write-Host "4. Kitchen Updated KOT Status to:" $updatedKot.kotStatus

$statusReady = @{ status = "READY" } | ConvertTo-Json
$updatedKot2 = Invoke-RestMethod -Uri "http://localhost:8080/api/kots/$($newKot.kotId)/status" -Method Put -ContentType 'application/json' -Body $statusReady -WebSession $session
Write-Host "5. Kitchen Updated KOT Status to:" $updatedKot2.kotStatus

# 6. Cashier Generates Bill & Checkout
$loginCashier = Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/login' -Method Post -ContentType 'application/json' -Body '{"username":"cashier","password":"cashier123"}' -WebSession $session
$billBody = @{
    orderId = $order.orderId
    discount = 10.0
    serviceCharge = 5.0
    paymentMethod = "UPI"
} | ConvertTo-Json

$bill = Invoke-RestMethod -Uri 'http://localhost:8080/api/bills' -Method Post -ContentType 'application/json' -Body $billBody -WebSession $session
Write-Host "6. Bill Generated Invoice #:" $bill.invoiceNumber "Subtotal:" $bill.subtotal "Total:" $bill.total "Status:" $bill.paymentStatus

# 7. Download PDF Invoice
$pdfBytes = Invoke-RestMethod -Uri "http://localhost:8080/api/bills/$($bill.billId)/pdf" -Method Get -WebSession $session
Write-Host "7. PDF Invoice Downloaded Successfully! Bytes size:" $pdfBytes.Length
