#!/usr/bin/env python3

from prefect.filesystems import S3
from prefect_aws.ecs import ECSTask

# session = boto3.Session()
# credentials = session.get_credentials()
#
# # Credentials are refreshable, so accessing your access key / secret key separately
# can
# # lead to a race condition. Use this to get an actual matched set.
# credentials = credentials.get_frozen_credentials()
# access_key = credentials.access_key
# secret_key = credentials.secret_key
# session_key = credentials.session_key
#
# if session_key:
#     aws_credentials_block = AwsCredentials(
#         aws_access_key_id=access_key,
#         aws_secret_access_key=secret_key,
#         aws_session_token=session_key
#     )
# else:
#     aws_credentials_block = AwsCredentials(
#         aws_access_key_id=access_key,
#         aws_secret_access_key=secret_key,
#     )

ecs = ECSTask(
    task_definition_arn="arn:aws:ecs:us-west-2:518075716045:task-definition/"
                        "prefect-play-flow:1"
)
ecs.save("play", overwrite=True)

s3 = S3(bucket_path="prefect-play-data")
s3.save("play", overwrite=True)
