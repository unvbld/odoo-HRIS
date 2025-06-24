# HRIS REST API Test Script
# PowerShell script untuk testing HRIS REST API

param(
    [string]$BaseUrl = "http://localhost:8069",
    [string]$Username = "apitest@test.com",
    [string]$Password = "test123"
)

Write-Host ""
Write-Host "HRIS REST API Testing Script" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Green
Write-Host "Base URL: $BaseUrl" -ForegroundColor Yellow
Write-Host "Username: $Username" -ForegroundColor Yellow
Write-Host ""

# Global variables
$sessionToken = ""
$testResults = @()

# Function to add test result
function Add-TestResult {
    param(
        [string]$TestName,
        [bool]$Success,
        [string]$Message = "",
        [object]$Data = $null
    )
    
    $script:testResults += @{
        TestName = $TestName
        Success = $Success
        Message = $Message
        Data = $Data
        Timestamp = Get-Date
    }
      if ($Success) {
        Write-Host "[PASS] $TestName`: $Message" -ForegroundColor Green
    } else {
        Write-Host "[FAIL] $TestName`: $Message" -ForegroundColor Red
    }
}

# Test 1: Health Check
Write-Host "1. Testing Health Check..." -ForegroundColor Cyan
try {
    $health = Invoke-RestMethod -Uri "$BaseUrl/api/health" -Method GET -TimeoutSec 30
    
    if ($health.status -eq "ok") {
        Add-TestResult -TestName "Health Check" -Success $true -Message "$($health.status) - $($health.message)"
    } else {
        Add-TestResult -TestName "Health Check" -Success $false -Message "Unexpected status: $($health.status)"
    }
} catch {
    Add-TestResult -TestName "Health Check" -Success $false -Message $_.Exception.Message
    Write-Host "Cannot connect to API. Make sure Docker containers are running." -ForegroundColor Yellow
    Write-Host "   Run: docker-compose up -d" -ForegroundColor Gray
    exit 1
}

# Test 2: Login
Write-Host "`n2. Testing Authentication..." -ForegroundColor Cyan
try {
    $loginData = @{
        username = $Username
        password = $Password
    } | ConvertTo-Json
    
    $loginResponse = Invoke-RestMethod -Uri "$BaseUrl/api/auth/login" -Method POST -ContentType "application/json" -Body $loginData -TimeoutSec 30
    
    if ($loginResponse.success -eq $true) {
        $sessionToken = $loginResponse.data.session_token
        Add-TestResult -TestName "Login" -Success $true -Message "User ID: $($loginResponse.data.user_id)" -Data $loginResponse.data
        Write-Host "   Session Token: $($sessionToken.Substring(0,20))..." -ForegroundColor Gray
    } else {
        Add-TestResult -TestName "Login" -Success $false -Message $loginResponse.message
    }
} catch {
    Add-TestResult -TestName "Login" -Success $false -Message $_.Exception.Message
    Write-Host "Login failed. Check if test user exists:" -ForegroundColor Yellow
    Write-Host "   docker exec -it hris_backend-db-1 psql -U odoo -d odoo -c `"SELECT id, login FROM res_users WHERE login = '$Username';`"" -ForegroundColor Gray
}

# Test 3: Profile (if login successful)
if ($sessionToken) {
    Write-Host "`n3. Testing Profile Endpoint..." -ForegroundColor Cyan
    try {
        $headers = @{"Cookie" = "session_id=$sessionToken"}
        $profile = Invoke-RestMethod -Uri "$BaseUrl/api/auth/profile" -Method GET -Headers $headers -TimeoutSec 10
        
        if ($profile.success -eq $true) {
            Add-TestResult -TestName "Profile" -Success $true -Message "Retrieved: $($profile.data.name)" -Data $profile.data
        } else {
            Add-TestResult -TestName "Profile" -Success $false -Message $profile.message
        }
    } catch {
        Add-TestResult -TestName "Profile" -Success $false -Message $_.Exception.Message
    }
} else {
    Add-TestResult -TestName "Profile" -Success $false -Message "Skipped - No session token"
}

# Test 4: Employees
if ($sessionToken) {
    Write-Host "`n4. Testing Employees Endpoint..." -ForegroundColor Cyan
    try {
        $headers = @{"Cookie" = "session_id=$sessionToken"}
        $employees = Invoke-RestMethod -Uri "$BaseUrl/api/employees" -Method GET -Headers $headers -TimeoutSec 10
        
        if ($employees.success -eq $true) {
            Add-TestResult -TestName "Employees" -Success $true -Message "Retrieved successfully"
        } else {
            Add-TestResult -TestName "Employees" -Success $false -Message $employees.message
        }
    } catch {
        # This might fail due to permissions, which is expected
        $errorMsg = $_.Exception.Message
        if ($errorMsg -match "401|Unauthorized") {
            Add-TestResult -TestName "Employees" -Success $false -Message "Permission denied (expected for basic user)"
        } else {
            Add-TestResult -TestName "Employees" -Success $false -Message $errorMsg
        }
    }
} else {
    Add-TestResult -TestName "Employees" -Success $false -Message "Skipped - No session token"
}

# Test 5: Logout
if ($sessionToken) {
    Write-Host "`n5. Testing Logout..." -ForegroundColor Cyan
    try {
        $headers = @{"Cookie" = "session_id=$sessionToken"}
        $logout = Invoke-RestMethod -Uri "$BaseUrl/api/auth/logout" -Method POST -Headers $headers -TimeoutSec 10
        
        if ($logout.success -eq $true) {
            Add-TestResult -TestName "Logout" -Success $true -Message $logout.message
        } else {
            Add-TestResult -TestName "Logout" -Success $false -Message $logout.message
        }
    } catch {
        Add-TestResult -TestName "Logout" -Success $false -Message $_.Exception.Message
    }
} else {
    Add-TestResult -TestName "Logout" -Success $false -Message "Skipped - No session token"
}

# Test Summary
Write-Host "`n" + "="*50 -ForegroundColor Blue
Write-Host "TEST SUMMARY" -ForegroundColor Blue
Write-Host "="*50 -ForegroundColor Blue

$successCount = ($script:testResults | Where-Object { $_.Success -eq $true }).Count
$totalCount = $script:testResults.Count

Write-Host "Total Tests: $totalCount" -ForegroundColor White
Write-Host "Passed: $successCount" -ForegroundColor Green
Write-Host "Failed: $($totalCount - $successCount)" -ForegroundColor Red
Write-Host "Success Rate: $([math]::Round(($successCount / [math]::Max($totalCount, 1)) * 100, 1))%" -ForegroundColor Yellow

Write-Host "`nDetailed Results:" -ForegroundColor White
foreach ($result in $script:testResults) {
    $status = if ($result.Success) { "[PASS]" } else { "[FAIL]" }
    $color = if ($result.Success) { "Green" } else { "Red" }
    Write-Host "$status $($result.TestName): $($result.Message)" -ForegroundColor $color
}

# Final recommendations
Write-Host "`n" + "="*50 -ForegroundColor Blue
Write-Host "RECOMMENDATIONS" -ForegroundColor Blue
Write-Host "="*50 -ForegroundColor Blue

if ($successCount -eq $totalCount) {    Write-Host "All tests passed! API is working correctly." -ForegroundColor Green
    Write-Host "   Ready for Flutter integration." -ForegroundColor Green
} else {
    Write-Host "Some tests failed. Common fixes:" -ForegroundColor Yellow
    
    if (-not ($script:testResults | Where-Object { $_.TestName -eq "Health Check" -and $_.Success })) {
        Write-Host "   • Start Docker: docker-compose up -d" -ForegroundColor Gray
    }
    
    if (-not ($script:testResults | Where-Object { $_.TestName -eq "Login" -and $_.Success })) {
        Write-Host "   • Create test user (see TESTING.md)" -ForegroundColor Gray
        Write-Host "   • Check module installation" -ForegroundColor Gray
    }
    
    Write-Host "   • Check logs: docker logs hris_backend-web-1 --tail 20" -ForegroundColor Gray
    Write-Host "   • See TESTING.md for detailed troubleshooting" -ForegroundColor Gray
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "   • Read README.md for API documentation" -ForegroundColor White
Write-Host "   • Check TESTING.md for more testing methods" -ForegroundColor White
Write-Host "   • Use session token for authenticated requests" -ForegroundColor White

Write-Host "`nHappy coding!" -ForegroundColor Green
Write-Host ""
