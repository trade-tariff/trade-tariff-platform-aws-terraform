import boto3
import os
from pprint import pprint
import time

logs = boto3.client('logs')
ssm = boto3.client('ssm')

EXPORT_LAG_MS = 12 * 60 * 60 * 1000


def get_parameter(name):
    try:
        return ssm.get_parameter(Name=name)['Parameter']['Value']
    except ssm.exceptions.ParameterNotFound:
        return None


def export_task_status(task_id):
    tasks = logs.describe_export_tasks(taskId=task_id)['exportTasks']
    return tasks[0]['status']['code'] if tasks else "NOT_FOUND"

def lambda_handler(event, context):
    extra_args = {}
    log_groups = []
    log_groups_to_export = []

    if 'S3_BUCKET' not in os.environ:
        print("Error: S3_BUCKET not defined")
        return

    print("--> S3_BUCKET=%s" % os.environ["S3_BUCKET"])

    while True:
        response = logs.describe_log_groups(**extra_args)
        log_groups = log_groups + response['logGroups']

        if not 'nextToken' in response:
            break
        extra_args['nextToken'] = response['nextToken']

    for log_group in log_groups:
        response = logs.list_tags_log_group(logGroupName=log_group['logGroupName'])
        log_group_tags = response['tags']
        if 'ExportToS3' in log_group_tags and log_group_tags['ExportToS3'] == 'true':
            log_groups_to_export.append(log_group['logGroupName'])

    for log_group_name in log_groups_to_export:
        ssm_parameter_name = ("/log-exporter-last-export/%s" % log_group_name).replace("//", "/")
        pending_parameter_name = ("/log-exporter-pending-export/%s" % log_group_name).replace("//", "/")
        last_export = int(get_parameter(ssm_parameter_name) or "0")

        print("--> Exporting %s to %s" % (log_group_name, os.environ['S3_BUCKET']))

        pending = get_parameter(pending_parameter_name)
        if pending:
            task_id, task_to = pending.split(":")
            status = export_task_status(task_id)
            if status in ("PENDING", "PENDING_CANCEL", "RUNNING"):
                print("    Skipped until export task %s is finished (%s)" % (task_id, status))
                continue
            if status == "COMPLETED":
                last_export = int(task_to)
                ssm.put_parameter(Name=ssm_parameter_name, Type="String", Value=str(last_export), Overwrite=True)
                print("    Export task %s completed. Last export is now %s" % (task_id, last_export))
            else:
                print("    Export task %s did not complete (%s). Exporting the same period again" % (task_id, status))
            ssm.delete_parameter(Name=pending_parameter_name)

        # CloudWatch can take up to 12 hours to make log data exportable
        export_to_time = int(round(time.time() * 1000)) - EXPORT_LAG_MS

        if export_to_time - last_export < (24 * 60 * 60 * 1000):
            # Haven't been 24hrs from the last export of this log group
            print("    Skipped until 24hrs from last export is completed")
            continue

        max_retries = 10
        while max_retries > 0:
            try:
                response = logs.create_export_task(
                    logGroupName=log_group_name,
                    fromTime=last_export,
                    to=export_to_time,
                    destination=os.environ['S3_BUCKET'],
                    destinationPrefix=os.environ['AWS_ACCOUNT'] + '/' + log_group_name.strip('/')
                )
                print("    Task created: %s" % response['taskId'])
                ssm.put_parameter(
                    Name=pending_parameter_name,
                    Type="String",
                    Value="%s:%s" % (response['taskId'], export_to_time),
                    Overwrite=True)

                break

            except logs.exceptions.LimitExceededException:
                max_retries = max_retries - 1
                print("    Need to wait until all tasks are finished (LimitExceededException). Continuing %s additional times" % (max_retries))
                time.sleep(5)
                continue

            except Exception as e:
                print("    Error exporting %s: %s" % (log_group_name, getattr(e, 'message', repr(e))))
                break
