
get_csrf_token(){
  curl --location 'http://localhost:8088/v1/esignet/csrf/token' \
  --header 'Cookie: XSRF-TOKEN=12462981-e4d9-49cd-a94f-1ec41ffa8f1d' \
  -o ../../postman_responses/csrfToken.json

  echo $(jq -r '.token' ../../postman_responses/csrfToken.json)
}

create_oidc_client(){
  length=${1:-32}
  codeVerifier=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c "$length")
  codeChallenge=$(echo -n "$codeVerifier" | openssl dgst -sha256 -binary | base64 | tr -d '=' | tr '+/' '-_' | tr -d '\n')
  codeChallengeMethod="S256"

  #redirectionUrl=$(jq -r '.values[] | select(.key == "redirectionUrl") | .value' inji-certify-with-mock-identity.postman_environment.json)

  clientId=$(jq -r '.values[] | select(.key == "clientId") | .value' inji-certify-with-mock-identity.postman_environment.json)
  redirectionUrl="http://localhost:3001"
  relayingPartyId=$(jq -r '.values[] | select(.key == "relayingPartyId") | .value' inji-certify-with-mock-identity.postman_environment.json)
  clientName="https://cloudflare-ipfs.com/ipfs/Qmd3W5DuhgHirLHGVixi6V76LhCkZUz6pnFt5AJBiyvHye/avatar/597.jpg"

  #curl --location 'http://localhost:8088/v1/esignet/oauth/.well-known/jwks.json' --header 'Cookie: XSRF-TOKEN=679a9380-6d1f-4665-90b8-1ad1ca9d2781' -o ../../output.json
  #publicKey=$(jq '.keys[0]' ../../output.json)

  privateKey_jwt='{
    "kty": "RSA",
    "n": "nBngN0_E_y4WQzO3sKvTRLhopLOfAwC-pPk30X-sBJ_Opje6byiIHvya-8L382sWUNQotpGNKNbfSfBJJuYmbrGb3CUFBBVfpnFbJN1dyecAHtL7GIbcvWDYZwE7eD4lf3g0aCRp2rrPzptY8fh7if5_yfqV_ekVIhfUNmBci06wosqroFPe5ypuFTToNPLHjRHNNATZPG_KytUw0wBSSBpdE9RqEu4fFu3DqLQZ7Yp8WOT7V8mNcqEz1XyJ-SzMw_xmluPVZZKbiJW3c-kR13kP-xejj0dchH9W9f-WtvLEp15cOaN_oGoHRv_ETdS8YlwqsW_5zimuGctbHUqNoQ",
    "e": "AQAB",
    "d": "MNBuqx1IzzuMPquXj6nLwTuhjY-V9AxxkYlViS_RjQikSJo4tLYKCxaXKI-JlhcwvUn7CUxuxgyberWnSoDCF-92e9sfvG0qohPkmpyWzaJtCTaUytCxio8UXPGntSxJ8ZiXWtG4QGwWu9ccc15u03JAZ9ryuJoAv86P0AlGJ1GNvtQQ_HvxFRoGlJ-ZbVULE-BzeMSceH7WXjrzDEcvl85lxEFKHtd8Shc-4xpifcO7EDKOEm6fjFIfwspEHPwJekUqQfDiCzruol3tiSdEfXS-v-7-Kolw3jZ0eXforS6RM7YEm2RfE11ZNVol8xeQweIz2AF2XskBSHfMaLtzOQ",
    "p": "_GH4UCjQdtLF094HbOW3uenUMwhEPfDAqfVC3PKlmPv5dVw59781dc3ldsVEeD_8D5IHu0eCuQS3zCRWi-6-TJQM4Cf2fzCKhR5id4QAE1RLlYlc7BOQWSkWIbJKV-w2FE9zI328VtiTvBxlQkly78TWGwMM_k0Ai5XZPRNE0Ic",
    "q": "nlaiV6meEZnJtlaUNfhiWKZekBZqeZrWsL9ezAEBD80D-vIma9RwMljNbalihUU_99uODQ-kt0Mx7fBUcwUoivN4DNpDs_EQ27a3Qr8ojiFUP80FKiLBcDyqWt1fhu3Ska-X-XwPM3oCjmL_f2Df9wSqiit8HE3UHfmgdlJ5gpc",
    "dp": "ATSSlAdt33NoQHfJ_0olk3y7Z7b9ZHJW6Tjjpdx-z_k8GsRi_nzqS3K9StDsX8qmcIiZAtr3k9yi6BWwWCC-xezbFuL5-WeI8dPQUpPN0EnRxpgOWo5JXTOmCGkqk7rsEzLB8QRzttJ3-ikEjsl9BAojn6NnF3vUqdYAYJtL89c",
    "dq": "WOAkC7SnhxWdhX2ff5PGECCCX7pVVaC19UvVuAiwQeA_5bHaIxiBSaFS3cUACfJO758LYwVu3XcYJYiKvm0czrHOptg0vGIJpmou_4YxC2Zl1dIMnhQYJBnJPWuY3THMyf2X_m_GUIyhtq6W3zbPP-Ycm6XA6lo9P_4INaIhlk0",
    "qi": "L9VU-TKmus1j0xrJkBmakm0kKHbgHjhOodSbKm6NhkumOF7GbP6Zxmbhn5_JJWj2NttbSfFMTvHc5cEJUG0D3O11ktZTQ7CbdGlPaZ2X2vDeaLG8as8Q5AxBzU8VAtGcl97aOhTcb5OcOvZzJ6lmsTUXJLsr10rjaJ-cqkL9cac"
  }'

  publicKey_jwt='{
    "kty": "RSA",
    "n": "nBngN0_E_y4WQzO3sKvTRLhopLOfAwC-pPk30X-sBJ_Opje6byiIHvya-8L382sWUNQotpGNKNbfSfBJJuYmbrGb3CUFBBVfpnFbJN1dyecAHtL7GIbcvWDYZwE7eD4lf3g0aCRp2rrPzptY8fh7if5_yfqV_ekVIhfUNmBci06wosqroFPe5ypuFTToNPLHjRHNNATZPG_KytUw0wBSSBpdE9RqEu4fFu3DqLQZ7Yp8WOT7V8mNcqEz1XyJ-SzMw_xmluPVZZKbiJW3c-kR13kP-xejj0dchH9W9f-WtvLEp15cOaN_oGoHRv_ETdS8YlwqsW_5zimuGctbHUqNoQ",
    "e": "AQAB",
    "kid": "UgEY6L5zrUcfHwBhx4tkHoE5yCyCPHaGRtTi3E2Hy-I"
  }'

  isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
  curl --location 'http://localhost:8088/v1/esignet/client-mgmt/oidc-client' \
  --header "X-XSRF-TOKEN: $csrfToken" \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI1SmZabW90aFRxanFGV0EzSFM1WEk1Q1MxRHQxYTBRUnVFWE1KZW5xTXFVIn0.eyJleHAiOjE3MjMxMzQ0NzcsImlhdCI6MTcyMzA5ODQ3NywianRpIjoiOGNiYzY3ZTAtMzg4Zi00ZDQ5LThkNGQtZWYxNTEyYWY5YjQzIiwiaXNzIjoiaHR0cHM6Ly9pYW0ucWEtaW5qaS5tb3NpcC5uZXQvYXV0aC9yZWFsbXMvbW9zaXAiLCJhdWQiOiJhY2NvdW50Iiwic3ViIjoiNTNkMDJiMmEtYmM2Yy00Y2IyLWIxYWEtNmNhZjA5ZTBjZmVjIiwidHlwIjoiQmVhcmVyIiwiYXpwIjoibW9zaXAtcG1zLWNsaWVudCIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsiUEFSVE5FUiIsIlBVQkxJU0hfTUlTUF9MSUNFTlNFX1VQREFURURfR0VORVJBTCIsIlBVQkxJU0hfUEFSVE5FUl9VUERBVEVEX0dFTkVSQUwiLCJERVZJQ0VfUFJPVklERVIiLCJQVUJMSVNIX01JU1BfTElDRU5TRV9HRU5FUkFURURfR0VORVJBTCIsImRlZmF1bHQtcm9sZXMtbW9zaXAiLCJQVUJMSVNIX0FQSUtFWV9BUFBST1ZFRF9HRU5FUkFMIiwiUkVHSVNUUkFUSU9OX1BST0NFU1NPUiIsIlBVQkxJU0hfT0lEQ19DTElFTlRfVVBEQVRFRF9HRU5FUkFMIiwiUFVCTElTSF9BUElLRVlfVVBEQVRFRF9HRU5FUkFMIiwiWk9OQUxfQURNSU4iLCJQTVNfQURNSU4iLCJQVUJMSVNIX0NBX0NFUlRJRklDQVRFX1VQTE9BREVEX0dFTkVSQUwiLCJQVUJMSVNIX1BPTElDWV9VUERBVEVEX0dFTkVSQUwiLCJQTVNfVVNFUiIsIkNSRUFURV9TSEFSRSIsIm9mZmxpbmVfYWNjZXNzIiwiUEFSVE5FUl9BRE1JTiIsIlBVQkxJU0hfT0lEQ19DTElFTlRfQ1JFQVRFRF9HRU5FUkFMIiwidW1hX2F1dGhvcml6YXRpb24iLCJTVUJTQ1JJQkVfQ0FfQ0VSVElGSUNBVEVfVVBMT0FERURfR0VORVJBTCJdfSwicmVzb3VyY2VfYWNjZXNzIjp7Im1vc2lwLXBtcy1jbGllbnQiOnsicm9sZXMiOlsidW1hX3Byb3RlY3Rpb24iXX0sImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSB1cGRhdGVfb2lkY19jbGllbnQgYWRkX29pZGNfY2xpZW50IHVwbG9hZF9jZXJ0aWZpY2F0ZSBnZXRfY2VydGlmaWNhdGUiLCJjbGllbnRIb3N0IjoiMTAuNDIuMS4xMjAiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImNsaWVudElkIjoibW9zaXAtcG1zLWNsaWVudCIsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1tb3NpcC1wbXMtY2xpZW50IiwiY2xpZW50QWRkcmVzcyI6IjEwLjQyLjEuMTIwIn0.KMLWpFpZhGvKVupRkg52gTiwMGv6M2sBIciOebE_oCoNC9XG9fwNG89cuN1EI9GdZaDaRDxX6suHm1eWsbrFz6U9f73IalH_WcotuAuS-7qkP_9lHt5q4B0fhUQzmkcVHH6ivxnFVUEmF9i2gHq0IqBbOQatspZ-yZNQFMznAgQEF6WwkYLFfuu7hwLwTuOm1m8f-D3NATZxAsqhb__YgywVDKuti46IV7Nr47qsM2YGL46Q-KPLaDy4GgptXg4eiOGaGWpGuAROEt2nile9kKadrX3JGENWQ_mgfpc26qtnfsng4DwR0e6ssFxffdp_jsyjLenPvT9K4xONugu78w' \
  --header "Cookie: XSRF-TOKEN=$csrfToken" \
  --data '{
      "requestTime": "'"$isoTimestamp"'",
      "request": {
          "clientId": "'"$clientId"'",
          "clientName": "$clientName",
          "publicKey": '"$publicKey_jwt"',
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
  }' -o ../../postman_responses/mockOidcResponse.json
}

create_mock_identity(){
  isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
  curl --location 'http://localhost:8082/v1/mock-identity-system/identity' \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "requestTime": "'"$isoTimestamp"'",
      "request": {
          "individualId": "8267411571",
          "pin": "111111",
          "fullName": [
              {
                  "language": "fra",
                  "value": "Alheri Bobby"
              },
              {
                  "language": "ara",
                  "value": "تتگلدكنسَزقهِقِفل دسييسيكدكنوڤو"
              },
              {
                  "language": "eng",
                  "value": "Alheri Bobby"
              }
          ],
          "gender": [
              {
                  "language": "eng",
                  "value": "female"
              },
              {
                  "language": "fra",
                  "value": "female"
              },
              {
                  "language": "ara",
                  "value": "ذكر"
              }
          ],
          "dateOfBirth": "2000/10/21",
          "streetAddress": [
              {
                  "language": "fra",
                  "value": "yuan⥍"
              },
              {
                  "language": "ara",
                  "value": "$لُنگᆑ"
              },
              {
                  "language": "eng",
                  "value": "Slung"
              }
          ],
          "locality": [
              {
                  "language": "fra",
                  "value": "yuān 2"
              },
              {
                  "language": "ara",
                  "value": "يَُانꉛ⥍"
              },
              {
                  "language": "eng",
                  "value": "yuan wee"
              }
          ],
          "region": [
              {
                  "language": "fra",
                  "value": "yuān 3"
              },
              {
                  "language": "ara",
                  "value": "$لُنگᆑ"
              },
              {
                  "language": "eng",
                  "value": "yuan wee 3"
              }
          ],
          "postalCode": "45009",
          "country": [
              {
                  "language": "fra",
                  "value": "CMattye"
              },
              {
                  "language": "ara",
                  "value": "دسييسيكدك"
              },
              {
                  "language": "eng",
                  "value": "Cmattey"
              }
          ],
          "encodedPhoto": "data:image/jpeg;base64,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",
          "individualBiometrics": {
              "format": "cbeff",
              "version": 1,
              "value": "individualBiometrics_bio_CBEFF"
          },
          "email": "siwer.km@gmail.com",
          "phone": "+919427357934"
      }
  }'
}

authorize_request_v2(){
  nonce=$(jq -r '.values[] | select(.key == "nonce") | .value' inji-certify-with-mock-identity.postman_environment.json)
  state=$(jq -r '.values[] | select(.key == "state") | .value' inji-certify-with-mock-identity.postman_environment.json)

  isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
  curl --location 'http://localhost:8088/v1/esignet/authorization/v2/oauth-details' --header "X-XSRF-TOKEN: $csrfToken" --header 'Content-Type: application/json' --header "Cookie: XSRF-TOKEN=$csrfToken" --data '{
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
  }' -o ../../postman_responses/mockAuthorizeRequest.json

  echo $(jq -r '.response.transactionId' ../../postman_responses/mockAuthorizeRequest.json)

}

send_otp(){
  isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

   curl --location 'http://localhost:8088/v1/esignet/authorization/send-otp' --header "X-XSRF-TOKEN: $csrfToken" --header "oauth-details-key: $transactionId" --header "oauth-details-hash: $oauthHash" --header 'Content-Type: application/json' --header "Cookie: XSRF-TOKEN=$csrfToken" --data '{
      "requestTime": "'"$isoTimestamp"'",
      "request": {
          "transactionId": "'"$transactionId"'",
          "individualId": "'"$individualId"'",
          "otpChannels" : ["email","phone"],
          "captchaToken" : "dummy"
      }
  }' \
  -o ../../postman_responses/sendOTP.json
}

authenticate_user(){
  isoTimestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")

  curl --location 'http://localhost:8088/v1/esignet/authorization/v3/authenticate' \
  --header "X-XSRF-TOKEN: $csrfToken" \
  --header "oauth-details-key: $transactionId" \
  --header "oauth-details-hash: $oauthHash" \
  --header 'Content-Type: application/json' \
  --header "Cookie: XSRF-TOKEN=$csrfToken" \
  --data '{
      "requestTime": "'"$isoTimestamp"'",
      "request": {
          "transactionId": "'"$transactionId"'",
          "individualId": "'"$individualId"'",
          "challengeList" : [
              {
                  "authFactorType" : "OTP",
                  "challenge" : "111111",
                  "format" : "alpha-numeric"
              }
          ]
      }
  }' \
  -o ../../postman_responses/authenticateUser.json
}

authorization_code(){
  curl --location 'http://localhost:8088/v1/esignet/authorization/auth-code' \
  --header "X-XSRF-TOKEN: $csrfToken" \
  --header "oauth-details-key: $transactionId" \
  --header "oauth-details-hash: $oauthHash" \
  --header 'Content-Type: application/json' \
  --header "Cookie: XSRF-TOKEN=$csrfToken" \
  --data '{
      "requestTime": "'"$isoTimestamp"'",
      "request": {
          "transactionId": "'"$transactionId"'",
          "acceptedClaims": [],
          "permittedAuthorizeScopes" : []
      }
  }' \
  -o ../../postman_responses/authorizeCode.json

  echo $(jq -r '.response.code' ../../postman_responses/authorizeCode.json)
}

sed -i "/^  esignet:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml
sed -i "/^  certify:/,/^  [^ ]/s/   - active_profile_env=.*$/   - active_profile_env=default,mock-identity/" docker-compose.yml

./install.sh > 2

mkdir postman_responses
cd docs/postman-collections/

csrfToken=$(get_csrf_token);

echo  $csrfToken;

create_oidc_client;

create_mock_identity;

jq '.values[] |= if .key == "individual_id" then .value = "8267411571" else . end' inji-certify-with-mock-identity.postman_environment.json > temp.json && mv temp.json inji-certify-with-mock-identity.postman_environment.json

transactionId=$(authorize_request_v2);

echo $transactionId;

individualId="8267411571"

responseData=$(jq -c '.response' ../../postman_responses/mockAuthorizeRequest.json)
echo -n "$responseData" | openssl dgst -sha256 -binary | base64 | tr '+/' '-_' | tr -d '=' > hash.txt
oauthHash=$(cat hash.txt)

send_otp;

authenticate_user;

codeToken=$(authorization_code);

echo $codeToken;

