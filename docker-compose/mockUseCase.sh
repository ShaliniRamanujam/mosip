sed -i "/^  esignet:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml
sed -i "/^  certify:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml
./install.sh > 2
cd ../docs/postman-collections/
clientId=$(jq -r '.values[] | select(.key == "clientId") | .value' inji-certify-with-sunbird-insurance.postman_environment.json)
redirectionUrl="http://localhost:3001"
relayingPartyId=$(jq -r '.values[] | select(.key == "relayingPartyId") | .value' inji-certify-with-sunbird-insurance.postman_environment.json)
clientName="https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/597.jpg"
curl --location 'http://localhost:8088/v1/esignet/oauth/.well-known/jwks.json' --header 'Cookie: XSRF-TOKEN=679a9380-6d1f-4665-90b8-1ad1ca9d2781' -o ../../output.json
publicKey=$(jq '.keys[0]' ../../output.json)
isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
curl --location 'http://localhost:8088/v1/esignet/client-mgmt/oidc-client' \
--header 'X-XSRF-TOKEN: 52f066b6-da32-4e45-9972-5ae369cc8374' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI1SmZabW90aFRxanFGV0EzSFM1WEk1Q1MxRHQxYTBRUnVFWE1KZW5xTXFVIn0.eyJleHAiOjE3MjMxMzQ0NzcsImlhdCI6MTcyMzA5ODQ3NywianRpIjoiOGNiYzY3ZTAtMzg4Zi00ZDQ5LThkNGQtZWYxNTEyYWY5YjQzIiwiaXNzIjoiaHR0cHM6Ly9pYW0ucWEtaW5qaS5tb3NpcC5uZXQvYXV0aC9yZWFsbXMvbW9zaXAiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiNTNkMDJiMmEtYmM2Yy00Y2IyLWIxYWEtNmNhZjA5ZTBjZmVjIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoibW9zaXAtcG1zLWNsaWVudCIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiUEFSVE5FUiIsIlBVQkxJU0hfTUlTUF9MSUNFTlNFX1VQREFURURfR0VORVJBTCIsIlBVQkxJU0hfUEFSVE5FUl9VUERBVEVEX0dFTkVSQUwiLCJERVZJQ0VfUFJPVklERVIiLCJQVUJMSVNIX01JU1BfTElDRU5TRV9HRU5FUkFURURfR0VORVJBTCIsImRlZmF1bHQtcm9sZXMtbW9zaXAiLCJQVUJMSVNIX0FQSUtFWV9BUFBST1ZFRF9HRU5FUkFMIiwiUkVHSVNUUkFUSU9OX1BST0NFU1NPUiIsIlBVQkxJU0hfT0lEQ19DTElFTlRfVVBEQVRFRF9HRU5FUkFMIiwiUFVCTElTSF9BUElLRVlfVVBEQVRFRF9HRU5FUkFMIiwiWk9OQUxfQURNSU4iLCJQTVNfQURNSU4iLCJQVUJMSVNIX0NBX0NFUlRJRklDQVRFX1VQTE9BREVEX0dFTkVSQUwiLCJQVUJMSVNIX1BPTElDWV9VUERBVEVEX0dFTkVSQUwiLCJQTVNfVVNFUiIsIkNSRUFURV9TSEFSRSIsIm9mZmxpbmVfYWNjZXNzIiwiUEFSVE5FUl9BRE1JTiIsIlBVQkxJU0hfT0lEQ19DTElFTlRfQ1JFQVRFRF9HRU5FUkFMIiwidW1hX2F1dGhvcml6YXRpb24iLCJTVUJTQ1JJQkVfQ0FfQ0VSVElGSUNBVEVfVVBMT0FERURfR0VORVJBTCJdfSwicmVzb3VyY2VfYWNjZXNzIjp7Im1vc2lwLXBtcy1jbGllbnQiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSB1cGRhdGVfb2lkY19jbGllbnQgYWRkX29pZGNfY2xpZW50IHVwbG9hZF9jZXJ0aWZpY2F0ZSBnZXRfY2VydGlmaWNhdGUiLCJjbGllbnRIb3N0IjoiMTAuNDIuMS4xMjAiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImNsaWVudElkIjoibW9zaXAtcG1zLWNsaWVudCIsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1tb3NpcC1wbXMtY2xpZW50IiwiY2xpZW50QWRkcmVzcyI6IjEwLjQyLjEuMTIwIn0.KMLWpFpZhGvKVupRkg52gTiwMGv6M2sBIciOebE_oCoNC9XG9fwNG89cuN1EI9GdZaDaRDxX6suHm1eWsbrFz6U9f73IalH_WcotuAuS-7qkP_9lHt5q4B0fhUQzmkcVHH6ivxnFVUEmF9i2gHq0IqBbOQatspZ-yZNQFMznAgQEF6WwkYLFfuu7hwLwTuOm1m8f-D3NATZxAsqhb__YgywVDKuti46IV7Nr47qsM2YGL46Q-KPLaDy4GgptXg4eiOGaGWpGuAROEt2nile9kKadrX3JGENWQ_mgfpc26qtnfsng4DwR0e6ssFxffdp_jsyjLenPvT9K4xONugu78w' \
--header 'Cookie: XSRF-TOKEN=ca1bd6fa-503e-49a6-9a86-c836aaad9a61' \
--data '{
    "requestTime": "'"$isoTimestamp"'",
    "request": {
        "clientId": "'"$clientId"'",
        "clientName": "$clientName",
        "publicKey": '"$publicKey"',
        "relyingPartyId": "$relayingPartyId",
        "userClaims": [
            "name",
            "email",
            "gender",
            "phone_number",
            "picture",
            "birthdate"
        ],
        "authContextRefs": [
            "mosip:idp:acr:generated-code",
            "mosip:idp:acr:biometrics",
            "mosip:idp:acr:linked-wallet"
        ],
        "logoUri": "https://avatars.githubusercontent.com/u/60199888",
        "redirectUris": [
             "'"$redirectionUrl"'",
             "io.mosip.residentapp://oauth"
        ],
        "grantTypes": [
            "authorization_code"
        ],
        "clientAuthMethods": [
            "private_key_jwt"
        ]
    }
}' -o mockOidcResponse.json
