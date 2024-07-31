# Find the first parent directory containing the VERSION file
$AppHome=(Get-Item -Path $MyInvocation.MyCommand.Path).Directory
while ($AppHome -ne $null -and !(Test-Path "$AppHome/VERSION")) {
  $AppHome=$AppHome.Parent
}
cd $AppHome

Write-Host "Deploy the project ..."
Write-Host "Changing version ..."

# Maven command and options
$MVNW = Join-Path $AppHome '.\mvnw.cmd'

$SNAPSHOT_VERSION = Get-Content "$AppHome\VERSION" -TotalCount 1
$VERSION =$SNAPSHOT_VERSION -replace "-SNAPSHOT", ""
$VERSION | Set-Content "$AppHome\VERSION"

Get-ChildItem -Path "$AppHome" -Depth 2 -Filter 'pom.xml' -Recurse | ForEach-Object {
  (Get-Content $_.FullName) -replace $SNAPSHOT_VERSION, $VERSION | Set-Content $_.FullName
}

& $MVNW clean
& $MVNW deploy

$exitCode =$LastExitCode
if ($exitCode -eq 0) {
  Write-Host "Build successfully"
} else {
  exit $exitCode
}

Write-Host "Artifacts are staged remotely, you should close and release the staging manually:"
Write-Host "https://oss.sonatype.org/#stagingRepositories"
Write-Host "Hit the following link to check if the artifacts are synchronized to the maven center: "
Write-Host "https://repo1.maven.org/maven2/ai/platon/platon"
