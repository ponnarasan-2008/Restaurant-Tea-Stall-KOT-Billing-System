$body = @{ username = 'admin'; password = 'admin123' } | ConvertTo-Json
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

Write-Host "--- 1. Testing Login API ---"
$loginRes = Invoke-RestMethod -Uri 'http://localhost:8080/api/auth/login' -Method Post -ContentType 'application/json' -Body $body -WebSession $session
Write-Host "Login Status:" $loginRes.success "Role:" $loginRes.role "User:" $loginRes.name

Write-Host "`n--- 2. Testing Menu Items API ---"
$items = Invoke-RestMethod -Uri 'http://localhost:8080/api/items' -Method Get -WebSession $session
Write-Host "Total Menu Items:" $items.Count

Write-Host "`n--- 3. Testing Active KOTs API ---"
$kots = Invoke-RestMethod -Uri 'http://localhost:8080/api/kots/active' -Method Get -WebSession $session
Write-Host "Active KOTs Count:" $kots.Count
foreach ($k in $kots) {
    Write-Host "  ->" $k.kotNumber "Status:" $k.kotStatus "Priority:" $k.priority "Order Type:" $k.order.orderType
}

Write-Host "`n--- 4. Testing AI Sales Trend & Forecast API ---"
$trend = Invoke-RestMethod -Uri 'http://localhost:8080/api/analytics/sales-trend' -Method Get -WebSession $session
Write-Host "Predicted Tomorrow Revenue:" $trend.predictedTomorrowRevenue
Write-Host "Forecast Range:" $trend.forecastRange
Write-Host "AI Insight:" $trend.insight

Write-Host "`n--- 5. Testing Business Health Score API ---"
$health = Invoke-RestMethod -Uri 'http://localhost:8080/api/analytics/health-score' -Method Get -WebSession $session
Write-Host "Health Score:" $health.score "/ 100" "Status:" $health.status

Write-Host "`n--- 6. Testing Kitchen Workload Metrics API ---"
$kitchen = Invoke-RestMethod -Uri 'http://localhost:8080/api/kitchen/metrics' -Method Get -WebSession $session
Write-Host "Workload Pct:" $kitchen.workloadPercentage "%" "Pending Items:" $kitchen.pendingItemCount "Delay:" $kitchen.warningMessage

Write-Host "`n--- 7. Testing Daily AI Executive Summary API ---"
$summary = Invoke-RestMethod -Uri 'http://localhost:8080/api/analytics/daily-summary' -Method Get -WebSession $session
Write-Host $summary.summary
