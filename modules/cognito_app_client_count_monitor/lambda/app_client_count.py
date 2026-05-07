"""Publish Cognito user pool app client count as a custom CloudWatch metric."""

import os

import boto3

METRIC_NAMESPACE = os.environ["METRIC_NAMESPACE"]
METRIC_NAME = os.environ.get("METRIC_NAME", "AppClientCount")
USER_POOL_ID = os.environ["USER_POOL_ID"]
ENVIRONMENT = os.environ.get("ENVIRONMENT", "unknown")


def lambda_handler(event, context):
    cognito = boto3.client("cognito-idp")
    paginator = cognito.get_paginator("list_user_pool_clients")

    total = 0
    for page in paginator.paginate(UserPoolId=USER_POOL_ID, PaginationConfig={"PageSize": 60}):
        total += len(page["UserPoolClients"])

    cloudwatch = boto3.client("cloudwatch")
    cloudwatch.put_metric_data(
        Namespace=METRIC_NAMESPACE,
        MetricData=[
            {
                "MetricName": METRIC_NAME,
                "Dimensions": [
                    {"Name": "UserPoolId", "Value": USER_POOL_ID},
                    {"Name": "Environment", "Value": ENVIRONMENT},
                ],
                "Value": float(total),
                "Unit": "Count",
            }
        ],
    )

    return {"statusCode": 200, "client_count": total}
