const amplifyconfig = {
  "UserAgent": "aws-amplify-cli/2.0",
  "Version": "1.0",
  "auth": {
    "plugins": {
      "awsCognitoAuthPlugin": {
        "IdentityManager": {"Default": {}},
        "CredentialsProvider": {
          "CognitoIdentity": {
            "Default": {"PoolId": "us-east-1_j98gSG2tO", "Region": "us-east-1"}
          }
        },
        "CognitoUserPool": {
          "Default": {
            "PoolId": "us-east-1_j98gSG2tO",
            "AppClientId": "15mjsf0n271084mbqe2e5h7t9s",
            "Region": "us-east-1"
          }
        },
        "Auth": {
          "Default": {
            "authenticationFlowType": "USER_SRP_AUTH",
            "OAuth": {
              "WebDomain": "[YOUR COGNITO DOMAIN]",
              "AppClientId": "15mjsf0n271084mbqe2e5h7t9s",
              "SignInRedirectURI":
                  "[CUSTOM REDIRECT SCHEME AFTER SIGN IN, e.g., myapp://]",
              "SignOutRedirectURI":
                  "[CUSTOM REDIRECT SCHEME AFTER SIGN OUT, e.g., myapp://]",
              "Scopes": ["phone", "email"]
            }
          }
        }
      }
    }
  },
  // "API": {
  //   "plugins": {
  //     "awsAPIPlugin": {
  //       "ecommerce-dev-frontend-api": {
  //         "endpointType": "GraphQL",
  //         "endpoint":
  //             "https://tvthp5gsdbbeblyw3nbnjvc2oi.appsync-api.us-east-1.amazonaws.com/graphql",
  //         "region": "us-east-1",
  //         "authorizationType": "API_KEY",
  //         "apiKey": "da2-pklbqf6dxvffxmdvtitafdhkmy"
  //       }
  //     }
  //   }
  // }
};
