class AmplifyConfigurationBuilder {
  static String build({
    required String cognitoIdentityPoolId,
    required String cognitoIdentityRegion,
    required String cognitoUserPoolId,
    required String cognitoUserPoolAppClientId,
    required String cognitoUserPoolRegion,
    required String authenticationFlowType,
    required String apiName,
    required String graphqlEndpoint,
    required String graphqlRegion,
    required String graphqlapiKey,
  }) {
    return '''
{
    "auth": {
        "plugins": {
            "awsCognitoAuthPlugin": {
                "IdentityManager": {
                    "Default": {}
                },
                "CredentialsProvider": {
                    "CognitoIdentity": {
                        "Default": {
                            "PoolId": "$cognitoIdentityPoolId",
                            "Region": "$cognitoIdentityRegion"
                        }
                    }
                },
                "CognitoUserPool": {
                    "Default": {
                        "PoolId": "$cognitoUserPoolId",
                        "AppClientId": "$cognitoUserPoolAppClientId",
                        "Region": "$cognitoUserPoolRegion"
                    }
                },
                "Auth": {
                    "Default": {
                        "authenticationFlowType": "$authenticationFlowType"
                    }
                }
            }
        }
    },
    "api": {
        "plugins": {
            "awsAPIPlugin": {
                "api": {
                    "endpointType": "GraphQL",
                    "endpoint": "$graphqlEndpoint",
                    "region": "$graphqlRegion",
                    "authorizationType": "API_KEY",
                    "apiKey": "$graphqlapiKey"
                }
            }
        }
    }
}
''';
  }
}
