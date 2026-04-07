# Access token

Make a ruby script that executes this request and prints the result :
```
curl --location --request POST 'https://acces-pp.nuonet.fr/api-pp/oauth/token?grant_type=client_credentials' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --header 'Authorization: Basic xxxxxxx'
```

xxxxxxx must be replaced by the string "CNOUS_CLIENT_ID:CNOUS_CLIENT_SECRET" (It's 2 env vars separated by ":") encoded in base 64.


# Create a file

I moved the file in docs/cnous_test/. And added a variable.

We are going to use the API documented in docs/cnous_test/swagger_api_boursier_cnous.json.

We want to use the generated access_token 
