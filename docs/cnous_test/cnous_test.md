# Access token

Make a ruby script that executes this request and prints the result :
```
curl --location --request POST 'https://acces-pp.nuonet.fr/api-pp/oauth/token?grant_type=client_credentials' --header 'Content-Type: application/x-www-form-urlencoded' --header 'Accept: application/json' --header 'Authorization: Basic xxxxxxx'
```

xxxxxxx must be replaced by the string "CNOUS_CLIENT_ID:CNOUS_CLIENT_SECRET" (It's 2 env vars separated by ":") encoded in base 64.


# Create a file

I moved the file in docs/cnous_test/. And added a variable.

We are going to use the API documented in docs/cnous_test/swagger_api_boursier_cnous.json.

We want to use the generated access_token to request a file creation with the route /v1/scholarship-holder-api-export/create.

- use the cogCodes `[92040]` (store it in a variable upfront).
- use the minScholarshipLevel `[ 0Bis, 1, 2, 3, 4, 5, 6, 7 ]` (store it in a variable upfront)
- leave campaignYear null

Retreive the id of the created file and print it.


# Get the file

I updated the routes with the correct ones, the swagger was wrong.

Now I want to make another file that makes a request to /v1/export/{export_id}/download to download the file with the given id