"""Evaluate the production response-time alarm policy without AWS access.

Run with: python3 -m unittest discover -s tests -p 'test_response_time_alarm.py'
Requires Terraform on PATH. No provider installation or remote state is used.
"""

import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import unittest


class ResponseTimeAlarmTest(unittest.TestCase):
    def test_admin_budget_does_not_change_other_target_groups(self):
        root = Path(__file__).resolve().parents[1]
        source = (root / 'environments/production/common/slack-notify.tf').read_text()
        resource = re.search(
            r'resource "aws_cloudwatch_metric_alarm" "long_response_times" \{(.*?)^\}',
            source, re.S | re.M,
        ).group(1)
        fields = ('threshold', 'comparison_operator', 'period', 'evaluation_periods',
                  'statistic', 'unit', 'treat_missing_data')
        expressions = {
            field: re.search(r'^\s*' + field + r'\s*=\s*(.+)$', resource, re.M).group(1)
            for field in fields
        }
        targets = ['admin-https', 'frontend-https', 'backend-uk-https',
                   'backend-xi-https', 'new-service-https']
        properties = ', '.join(
            field + ' = ' + value.replace('each.value.name', 'name')
            for field, value in expressions.items()
        )
        expression = ('jsonencode({for name in ' + json.dumps(targets)
                      + ' : name => {' + properties + '}})')
        with tempfile.TemporaryDirectory() as directory:
            result = subprocess.run(
                [os.environ.get('TERRAFORM_BINARY', 'terraform'), 'console', '-no-color'], cwd=directory,
                input=expression + '\n', capture_output=True, text=True, check=True,
            )
        alarms = json.loads(json.loads(result.stdout.strip()))
        for target, alarm in alarms.items():
            with self.subTest(target=target):
                self.assertEqual(alarm['threshold'], 5 if target == 'admin-https' else 1.5)
                self.assertEqual(alarm['comparison_operator'], 'GreaterThanOrEqualToThreshold')
                self.assertEqual(int(alarm['period']), 300)
                self.assertEqual(int(alarm['evaluation_periods']), 2)
                self.assertEqual(alarm['statistic'], 'Average')
                self.assertEqual(alarm['unit'], 'Seconds')
                self.assertEqual(alarm['treat_missing_data'], 'notBreaching')


if __name__ == '__main__':
    unittest.main()
