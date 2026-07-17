param (
    [string]$Token,
    [string]$Owner = "Cyberboyone",
    [string]$Repo = "gst-cbt-app",
    [string]$Branch = "main",
    [string]$SourceFolder = "c:\Users\bayum\Desktop\cbt app"
)

$Headers = @{
    "Authorization" = "Bearer $Token"
    "Accept"        = "application/vnd.github.v3+json"
    "X-GitHub-Api-Version" = "2022-11-28"
}

$BaseUrl = "https://api.github.com/repos/$Owner/$Repo"

# 1. Get the current commit SHA of the branch (to handle empty repo, we might need to check if it's empty)
Write-Host "Checking repository status..."
$BranchInfo = Invoke-RestMethod -Uri "$BaseUrl/git/refs/heads/$Branch" -Headers $Headers -ErrorAction SilentlyContinue

if ($null -eq $BranchInfo) {
    # If main branch doesn't exist, we'll need an initial commit via the contents API to create the branch
    Write-Host "Branch '$Branch' not found. Creating initial commit..."
    $Body = @{
        message = "Initial commit"
        content = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes("# GST CBT App`n`nAuto-generated Flutter project."))
    } | ConvertTo-Json
    $InitialCommit = Invoke-RestMethod -Uri "$BaseUrl/contents/README.md" -Method Put -Headers $Headers -Body $Body
    $LatestCommitSha = $InitialCommit.commit.sha
    $BaseTreeSha = $InitialCommit.commit.tree.sha
} else {
    $LatestCommitSha = $BranchInfo.object.sha
    $CommitInfo = Invoke-RestMethod -Uri "$BaseUrl/git/commits/$LatestCommitSha" -Headers $Headers
    $BaseTreeSha = $CommitInfo.tree.sha
}

# 2. Get all files in the directory recursively (ignoring certain folders)
Write-Host "Finding files to upload..."
$FilesToUpload = Get-ChildItem -Path $SourceFolder -File -Recurse | Where-Object {
    $relativePath = $_.FullName.Substring($SourceFolder.Length + 1)
    -not ($relativePath -match "^(build|\.dart_tool|\.git|\.idea)\\")
}

$TreeNodes = @()

# 3. Create Blobs for each file
Write-Host "Uploading blobs..."
foreach ($File in $FilesToUpload) {
    $relativePath = $File.FullName.Substring($SourceFolder.Length + 1).Replace('\', '/')
    Write-Host "  -> $relativePath"
    
    $fileBytes = [System.IO.File]::ReadAllBytes($File.FullName)
    $base64 = [Convert]::ToBase64String($fileBytes)
    
    $BlobBody = @{
        content = $base64
        encoding = "base64"
    } | ConvertTo-Json
    
    $BlobResponse = Invoke-RestMethod -Uri "$BaseUrl/git/blobs" -Method Post -Headers $Headers -Body $BlobBody
    
    $TreeNodes += @{
        path = $relativePath
        mode = "100644"
        type = "blob"
        sha  = $BlobResponse.sha
    }
}

# 4. Create a Tree
Write-Host "Creating tree..."
$TreeBody = @{
    base_tree = $BaseTreeSha
    tree = $TreeNodes
} | ConvertTo-Json -Depth 10
$TreeResponse = Invoke-RestMethod -Uri "$BaseUrl/git/trees" -Method Post -Headers $Headers -Body $TreeBody

# 5. Create a Commit
Write-Host "Creating commit..."
$CommitBody = @{
    message = "Upload project files"
    tree = $TreeResponse.sha
    parents = @($LatestCommitSha)
} | ConvertTo-Json
$CommitResponse = Invoke-RestMethod -Uri "$BaseUrl/git/commits" -Method Post -Headers $Headers -Body $CommitBody

# 6. Update Branch Reference
Write-Host "Updating reference..."
$RefBody = @{
    sha = $CommitResponse.sha
    force = $true
} | ConvertTo-Json
Invoke-RestMethod -Uri "$BaseUrl/git/refs/heads/$Branch" -Method Patch -Headers $Headers -Body $RefBody

Write-Host "Successfully pushed all files to GitHub!"
