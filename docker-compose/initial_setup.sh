cd ./docker-compose-certify
sed -i "/^  esignet:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml
sed -i "/^  certify:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml
sed -i "s|- esignet_wrapper_url_env|#&|" docker-compose.yml
sed -i "s|#      - enable_certify_artifactory|      - enable_certify_artifactory|" docker-compose.yml
sed -i "s|#      - ./loader_path/certify|      - ./loader_path/certify|" docker-compose.yml
cd ..
./install.sh
BASE_URL="./docker-compose/docker-compose-certify/postman-collections/mock"
COLLECTION_FILE="${BASE_URL}/certify\ with\ mock\ identity\ flow.postman_collection.json"
ENVIRONMENT_FILE="${BASE_URL}/certify\ with\ mock\ identity\ flow.postman_environment.json"
newman run "$COLLECTION_FILE" -e "$ENVIRONMENT_FILE"