cd ./docker-compose-certify
sed -i "/^  esignet:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml
sed -i "/^  certify:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml
sed -i "s|- esignet_wrapper_url_env|#&|" docker-compose.yml
sed -i "s|#      - enable_certify_artifactory|      - enable_certify_artifactory|" docker-compose.yml
sed -i "s|#      - ./loader_path/certify|      - ./loader_path/certify|" docker-compose.yml
cd ..
./install.sh < 1
cd ..
curl -X POST http://localhost:8000/identity/did/generate -H "Content-Type: application/json" -d '{
    "content":
        [
            {
                "alsoKnownAs": ["testUUID", "test@gmail.com"],
                "services": [
                    {
                        "id": "IdentityHub",
                        "type": "IdentityHub",
                        "serviceEndpoint": {
                            "@context": "schema.identity.foundation/hub",
                            "@type": "UserServiceEndpoint",
                            "instance": [
                                "did:test:hub.id"
                            ]
                        }
                    }
                ],
                "method": "web"
            }
        ]

}' \
> -o response.json
jq . response.json > formatted_response.json
AUTHOR_ID=$(jq -r ".[0].id" response.json)
curl -X POST http://localhost:8000/schema/credential-schema -H "Content-Type: application/json" -d '{
                                                                                                          "schema": {
                                                                                                              "type": "https://w3c-ccg.github.io/vc-json-schemas/",
                                                                                                              "version": "1.0.0",
                                                                                                              "name": "Proof of Medical Insurance Credential",
                                                                                                              "author": "$AUTHOR_ID",
                                                                                                              "authored": "2023-11-19T09:22:23.064Z",
                                                                                                              "schema": {
                                                                                                                  "$id": "Proof-of-Medical-Insurance-Credential-1.0",
                                                                                                                  "$schema": "https://json-schema.org/draft/2019-09/schema",
                                                                                                                  "description": "The holder is holding the certificate of Insurance",
                                                                                                                  "type": "object",
                                                                                                                  "properties": {
                                                                                                                      "policyNumber": {
                                                                                                                          "type": "string"
                                                                                                                      },
                                                                                                                      "policyName": {
                                                                                                                          "type": "string"
                                                                                                                      },
                                                                                                                      "policyExpiresOn": {
                                                                                                                          "type": "string"
                                                                                                                      },
                                                                                                                      "policyIssuedOn": {
                                                                                                                          "type": "string"
                                                                                                                      },
                                                                                                                      "benefits": {
                                                                                                                          "type": "array",
                                                                                                                          "items": {
                                                                                                                              "type": "string"
                                                                                                                          }
                                                                                                                      },
                                                                                                                      "fullName": {
                                                                                                                          "type": "string",
                                                                                                                          "title": "Full Name"
                                                                                                                      },
                                                                                                                      "dob": {
                                                                                                                          "type": "string"
                                                                                                                      },
                                                                                                                      "gender": {
                                                                                                                          "type": "string",
                                                                                                                          "enum": [
                                                                                                                              "Male",
                                                                                                                              "Female",
                                                                                                                              "Other"
                                                                                                                          ]
                                                                                                                      }
                                                                                                                  },
                                                                                                                  "required": [
                                                                                                                      "policyNumber",
                                                                                                                      "policyName",
                                                                                                                      "policyExpiresOn",
                                                                                                                      "policyIssuedOn",
                                                                                                                      "fullName",
                                                                                                                      "dob"
                                                                                                                  ],
                                                                                                                  "additionalProperties": true
                                                                                                              }
                                                                                                          },
                                                                                                          "tags": [
                                                                                                              "InsuranceCertificate"
                                                                                                          ],
                                                                                                          "status": "DRAFT"
                                                                                                      }' -o responseSchema.json
SCHEMA_AUTHOR=$(jq -r ".schema.author" responseSchema.json)
SCHEMA_ID=$(jq -r ".schema.id" responseSchema.json)
cp response.json responseCopy.json
cd ..
mkdir temp
cd ./inji-certify
mv response.json ../temp/
cd ../temp
GITHUB_FOLDER_NAME=$(jq -r '.[0].id | split(":")[5]' response.json
source ../inji-certify/docker-compose/docker-compose-sunbird/.env
git clone $WEB_DID_BASE_URL
cd did-resolve/
mkdir $GITHUB_FOLDER_NAME
mv ../response.json ./$GITHUB_FOLDER_NAME
git add ./$GITHUB_FOLDER_NAME
git commit -m "Add. response.json"
git push
cd ../../inji-certify/docker-compose/docker-compose-certify/
sed -i "/^  esignet:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,sunbird-insurance/" docker-compose.yml
sed -i "/^  certify:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,sunbird-insurance/" docker-compose.yml
cd ../../
AUTHOR_ID=$(jq -r ".[0].id" responseCopy.json)
sed -i -e 's|\(mosip.esignet.vciplugin.sunbird-rc.credential-type\.[^.]*\.static-value-map\.issuerId=\)[^ ]*|\1'$AUTHOR_ID'|g' ./docker-compose/docker-compose-certify/config/esignet-sunbird-insurance.properties
SCHEMA_ID=$(jq -r ".schema.id" responseSchema.json)
sed -i -e 's|\(mosip.esignet.vciplugin.sunbird-rc.credential-type\.[^.]*\.cred-schema-id=\)[^ ]*|\1'$SCHEMA_ID'|g' ./docker-compose/docker-compose-certify/config/esignet-sunbird-insurance.properties
cd docker-compose
./destroy.sh
./install.sh < 2




