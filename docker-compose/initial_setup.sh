cd ./docker-compose-certify
VALUE=$(sed -n "80p" docker-compose.yml | awk -F '=' '{print $2}')
sed -i '' "80s/active_profile_env=$VALUE/active_profile_env=default,mock-identity/" docker-compose.yml
VALUE=$(sed -n "104p" docker-compose.yml | awk -F '=' '{print $2}')
sed -i '' "104s/active_profile_env=$VALUE/active_profile_env=default,mock-identity/" docker-compose.yml
mkdir loader_path
sed -i '' "83s/^/# /" docker-compose.yml
cd loader_path
mkdir esignet
cd esignet
curl -o "eSignet.jar" "https://repo1.maven.org/maven2/io/mosip/esignet/mock/mock-esignet-integration-impl/0.9.2/mock-esignet-integration-impl-0.9.2.jar"
cd ../..
sed -i '' "107s/^#//" docker-compose.yml
sed -i '' "114s/^#//" docker-compose.yml
cd loader_path
mkdir certify
cd certify
curl -o "certify.jar" "https://github.com/mosip/digital-credential-plugins/tree/develop/mock-certify-plugin"
cd ../../../
./install.sh
BASE_URL="./docker-compose/docker-compose-certify/postman-collections/mock"
COLLECTION_FILE="${BASE_URL}/certify\ with\ mock\ identity\ flow.postman_collection.json"
ENVIRONMENT_FILE="${BASE_URL}/certify\ with\ mock\ identity\ flow.postman_environment.json"
newman run "$COLLECTION_FILE" -e "$ENVIRONMENT_FILE"