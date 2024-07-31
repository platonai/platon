#bin

# Find the first parent directory that contains a pom.xml file
APP_HOME=$(cd "$(dirname "$0")">/dev/null || exit; pwd)
while [[ "$APP_HOME" != "/" ]]; do
  if [[ -f "$APP_HOME/pom.xml" ]]; then
    break
  fi
  APP_HOME=$(dirname "$APP_HOME")
done

echo "Deploy the project ..."
echo "Changing version ..."

SNAPSHOT_VERSION=$(head -n 1 "$APP_HOME/VERSION")
VERSION=${SNAPSHOT_VERSION//"-SNAPSHOT"/""}
echo "$VERSION" > "$APP_HOME"/VERSION

find "$APP_HOME" -name 'pom.xml' -exec sed -i "s/$SNAPSHOT_VERSION/$VERSION/" {} \;

"$APP_HOME"/mvnw clean
"$APP_HOME"/mvn deploy -Pplaton-release -Possrh

exitCode=$?
[ $exitCode -eq 0 ] && echo "Build successfully" || exit 1

echo "Artifacts are staged remotely, you should close and release the staging manually:"
echo "https://oss.sonatype.org/#stagingRepositories"
echo "Hit the following link to check if the artifacts are synchronized to the maven center: "
echo "https://repo1.maven.org/maven2/ai/platon/pulsar"
