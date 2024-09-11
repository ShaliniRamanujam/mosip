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
#./destroy.sh
./install.sh < 2
cd ../docs/postman-collections/
jq '.values[] |= if .key == "aud" then .value = "http://localhost:8088/v1/esignet/oauth/v2/token" else . end' inji-certify-with-sunbird-insurance.postman_environment.json > temp.json && mv temp.json inji-certify-with-sunbird-insurance.postman_environment.json
jq '.values[] |= if .key == "audUrl" then .value = "http://localhost:8090" else . end' inji-certify-with-sunbird-insurance.postman_environment.json > temp.json && mv temp.json inji-certify-with-sunbird-insurance.postman_environment.json
clientId=$(jq -r '.values[] | select(.key == "clientId") | .value' inji-certify-with-sunbird-insurance.postman_environment.json)
redirectionUrl="http://localhost:3001"
relayingPartyId=$(jq -r '.values[] | select(.key == "relayingPartyId") | .value' inji-certify-with-sunbird-insurance.postman_environment.json)
clientName="https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/597.jpg"
curl --location 'http://localhost:8088/v1/esignet/oauth/.well-known/jwks.json' --header 'Cookie: XSRF-TOKEN=679a9380-6d1f-4665-90b8-1ad1ca9d2781' -o ../../output.json
publicKey=$(jq '.keys[0]' ../../output.json)
isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl --location 'http://localhost:8088/v1/esignet/client-mgmt/oidc-client' --header 'X-XSRF-TOKEN: 679a9380-6d1f-4665-90b8-1ad1ca9d2781' --header 'Content-Type: application/json' --header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICIxRXRCWFVCYmJBUXFfcG9XcDZ4V3RmaURiRDc2cllvT2pvX3hMMzlsclNVIn0.eyJleHAiOjE3MjQ4Nzk1NzIsImlhdCI6MTcyNDg0MzU3MiwianRpIjoiOGY3YzFkMGEtYmFmYy00YmJiLTliYjAtM2FlMjVhMWUzOWJhIiwiaXNzIjoiaHR0cHM6Ly9pYW0uZGV2MS5tb3NpcC5uZXQvYXV0aC9yZWFsbXMvbW9zaXAiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiYWMwZjQ5YjItNWIwYi00Y2E0LWI5NzQtOTJlNzRmYTc0MjM2IiwidHlwIjoiQmVhcmVyIiwiYXpwIjoibW9zaXAtcG1zLWNsaWVudCIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiUEFSVE5FUiIsIlBVQkxJU0hfTUlTUF9MSUNFTlNFX1VQREFURURfR0VORVJBTCIsIlBVQkxJU0hfUEFSVE5FUl9VUERBVEVEX0dFTkVSQUwiLCJERVZJQ0VfUFJPVklERVIiLCJQVUJMSVNIX01JU1BfTElDRU5TRV9HRU5FUkFURURfR0VORVJBTCIsImRlZmF1bHQtcm9sZXMtbW9zaXAiLCJQVUJMSVNIX0FQSUtFWV9BUFBST1ZFRF9HRU5FUkFMIiwiUkVHSVNUUkFUSU9OX1BST0NFU1NPUiIsIlBVQkxJU0hfT0lEQ19DTElFTlRfVVBEQVRFRF9HRU5FUkFMIiwiUFVCTElTSF9BUElLRVlfVVBEQVRFRF9HRU5FUkFMIiwiWk9OQUxfQURNSU4iLCJQTVNfQURNSU4iLCJQVUJMSVNIX0NBX0NFUlRJRklDQVRFX1VQTE9BREVEX0dFTkVSQUwiLCJQVUJMSVNIX1BPTElDWV9VUERBVEVEX0dFTkVSQUwiLCJQTVNfVVNFUiIsIkNSRUFURV9TSEFSRSIsIm9mZmxpbmVfYWNjZXNzIiwiUEFSVE5FUl9BRE1JTiIsIlBVQkxJU0hfT0lEQ19DTElFTlRfQ1JFQVRFRF9HRU5FUkFMIiwidW1hX2F1dGhvcml6YXRpb24iLCJTVUJTQ1JJQkVfQ0FfQ0VSVElGSUNBVEVfVVBMT0FERURfR0VORVJBTCJdfSwicmVzb3VyY2VfYWNjZXNzIjp7Im1vc2lwLXBtcy1jbGllbnQiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgZ2V0X2NlcnRpZmljYXRlIHVwZGF0ZV9vaWRjX2NsaWVudCBhZGRfb2lkY19jbGllbnQgcHJvZmlsZSB1cGxvYWRfY2VydGlmaWNhdGUiLCJjbGllbnRIb3N0IjoiMTAuNDIuMy4xMjAiLCJjbGllbnRJZCI6Im1vc2lwLXBtcy1jbGllbnQiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1tb3NpcC1wbXMtY2xpZW50IiwiY2xpZW50QWRkcmVzcyI6IjEwLjQyLjMuMTIwIn0.Om9g8OqJBmPDddVASIYjY9wyu_3gTDr-6kzLn5OHSAFUFm0ss0jIF-7sslDyupAMtmDI5Bpz5p2a7ZEW6fuze1IX4WrUsqeYhKSD7emfcaSC_Ok402UUrAjlPyzk6-eEBDHeyPDp3QxkZjlbQDX4JPlz69Q1BSry6OCk7ns3P1Ynljh5G1WAJZQi50xV4emavd7s_ULnhWQ2mp8_yPv5ipGG2rlsxBTGLVmBAwi3RhBwlZgzmvFDaAxeAm8iuFrlNjV7VEQCFPcuXf1N8lx7X1izt5bszEMIVcI0K1Yw1KCTXgIwObfrYcFKFC_RRYp-rS69M_-rl-F19UfydPy5Kg' --header 'Cookie: XSRF-TOKEN=52f066b6-da32-4e45-9972-5ae369cc8374' --data '{
    "requestTime": "'"$isoTimestamp"'",
    "request": {
        "clientId": "'"$clientId"'",
        "clientName": "$clientName",
        "publicKey": '"$publicKey"',
        "relyingPartyId": "$relayingPartyId",
        "userClaims": [
            "name"
        ],
        "authContextRefs": [
            "mosip:idp:acr:knowledge"
        ],
        "logoUri": "https://avatars.githubusercontent.com/u/60199888",
        "redirectUris": [
            "'"$redirectionUrl"'",
            "http://localhost:3001"
        ],
        "grantTypes": [
            "authorization_code"
        ],
        "clientAuthMethods": [
            "private_key_jwt"
        ]
    }
}'
nonce=$(jq -r '.values[] | select(.key == "nonce") | .value' inji-certify-with-sunbird-insurance.postman_environment.json)
state=$(jq -r '.values[] | select(.key == "state") | .value' inji-certify-with-sunbird-insurance.postman_environment.json)
length=${1:-32}
codeVerifier=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length")
codeChallenge=$(echo -n "$code_verifier" | openssl dgst -sha256 -binary | base64 | tr -d '=' | tr '+/' '-_' | tr -d '\n')
codeChallengeMethod="S256"
isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl --location 'http://localhost:8088/v1/esignet/authorization/v2/oauth-details' --header 'X-XSRF-TOKEN: 52f066b6-da32-4e45-9972-5ae369cc8374' --header 'Content-Type: application/json' --header 'Cookie: XSRF-TOKEN=52f066b6-da32-4e45-9972-5ae369cc8374' --data '{
    "requestTime": "'"$isoTimestamp"'",
    "request": {
        "clientId": "'"$clientId"'",
        "scope": "sunbird_rc_insurance_vc_ldp",
        "responseType": "code",
        "redirectUri": "'"$redirectionUrl"'",
        "display": "popup",
        "prompt": "login",
        "acrValues": "mosip:idp:acr:knowledge",
        "nonce" : "$nonce",
        "state" : "$state",
        "claimsLocales" : "en",
        "codeChallenge" : "$codeChallenge",
        "codeChallengeMethod" : "'"$codeChallengeMethod"'"
    }
}' -o ../../authorizeResponse.json





