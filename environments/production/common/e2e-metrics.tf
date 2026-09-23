#----------------------------------------------------------#
# CloudWatch alarms for the end-to-end test journey metrics
#----------------------------------------------------------#
# The Playwright suite in trade-tariff-e2e-tests publishes to the
# TradeTariff/E2E namespace at the end of each production run. The e2e
# scheduler dispatches that run every 10 minutes, so each alarm below sees one
# new datapoint per metric every 10 minutes.
#
# Two dimension schemas exist in this namespace and they do not overlap:
#   run metrics  (RunDuration, RunResult, TestsCompleted, TestsFailed,
#                 TestsSkipped, TestRetries) carry Environment only
#   test metrics (TestDuration, TestResult) carry Environment, Spec and Test
#
# The two per-journey alarms use SEARCH so that a new test is covered the first
# time it publishes and a deleted test drops out on its own. A hard-coded list
# of tests would need a change here for every change to the suite, and would
# sit in ALARM after a test was renamed.
#
# An alarm watches one time series, so each SEARCH is collapsed with MIN or
# MAX. The per-journey statistic is applied BEFORE that collapse, which is the
# part that matters: see the pass rate alarm below.

locals {
  # 1800 seconds is three dispatches. A journey is judged over three runs, not
  # over one, so a single flaky run cannot raise an alarm.
  e2e_journey_period = 1800

  e2e_test_metric_schema = "{TradeTariff/E2E,Environment,Spec,Test}"
}

# A journey that failed the majority of the last three runs.
#
# The per-journey Average over 1800 seconds is a pass rate: a journey that
# failed one of three runs scores 0.67, one that failed all three scores 0.
# MIN then takes the worst journey. A threshold of 0.5 therefore fires for one
# genuinely broken journey and stays quiet for one flaky run. Two DIFFERENT
# journeys failing once each in the window both score 0.67 and stay quiet,
# which is the intent — that is flake, not a broken journey.
#
# A skipped test publishes no TestResult at all (see buildMetricDatums in the
# e2e suite), so the eight tests skipped against production do not drag the
# pass rate down.
resource "aws_cloudwatch_metric_alarm" "e2e_journey_consistently_failing" {
  alarm_name          = "e2e-journey-consistently-failing-${var.environment}"
  alarm_description   = "An end-to-end journey has failed the majority of the last three production runs. Open the alarm graph to see which journey: CloudWatch → Alarms → this alarm. The alarm cannot name the journey because CloudWatch collapses the per-journey series before it evaluates."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  threshold           = 0.5
  treat_missing_data  = "notBreaching" # no runs at all is the no-metrics alarm below, not this one

  metric_query {
    id          = "worst_journey"
    label       = "Lowest per-journey pass rate"
    expression  = "MIN(SEARCH('${local.e2e_test_metric_schema} MetricName=\"TestResult\" Environment=\"${var.environment}\"', 'Average', ${local.e2e_journey_period}))"
    period      = local.e2e_journey_period
    return_data = true
  }

  alarm_actions = local.alert_actions
}

# A journey approaching the Playwright timeout.
#
# The suite sets a 30 second timeout per test, so a journey above 20 seconds is
# close to failing outright. This is a coarse safety net, not a tight one: one
# absolute threshold has to clear the slowest journey (the duty calculator, at
# about 9 seconds) while staying under that timeout, so a 1 second test would
# have to grow twentyfold to trip it. The run duration alarm below is the real
# slowness signal; this one catches a single journey degrading on its own.
resource "aws_cloudwatch_metric_alarm" "e2e_journey_slow" {
  alarm_name          = "e2e-journey-slow-${var.environment}"
  alarm_description   = "An end-to-end journey has averaged more than 20 seconds over the last three production runs, against a 30 second Playwright timeout. Open the alarm graph to see which journey."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  threshold           = 20000 # milliseconds
  treat_missing_data  = "notBreaching"

  metric_query {
    id          = "slowest_journey"
    label       = "Slowest journey (ms)"
    expression  = "MAX(SEARCH('${local.e2e_test_metric_schema} MetricName=\"TestDuration\" Environment=\"${var.environment}\"', 'Average', ${local.e2e_journey_period}))"
    period      = local.e2e_journey_period
    return_data = true
  }

  alarm_actions = local.observability_alert_actions
}

# The whole suite running slower than normal.
#
# Measured runs sit between 18 and 27 seconds. The threshold is set well above
# that because the baseline is short: metrics began on 2026-09-17 and this was
# set from the first seven runs. Review it once a full week of data exists.
# Three consecutive breaching periods are required so that one slow run, or one
# slow GitHub Actions runner, does not raise an alarm.
resource "aws_cloudwatch_metric_alarm" "e2e_run_slow" {
  alarm_name          = "e2e-run-slow-${var.environment}"
  alarm_description   = "The end-to-end suite has taken more than 45 seconds on three consecutive production runs (normal is 18 to 27 seconds). The site is slow, or a journey is retrying. Check the frontend and backend latency alarms first."
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  metric_name         = "RunDuration"
  namespace           = "TradeTariff/E2E"
  period              = 600 # matches the dispatch cadence, so each period holds one run
  statistic           = "Average"
  threshold           = 45000 # milliseconds
  treat_missing_data  = "notBreaching"

  dimensions = {
    Environment = var.environment
  }

  alarm_actions = local.observability_alert_actions
}

# No run metrics at all.
#
# The reporter logs and swallows its own publish errors on purpose, so a broken
# publisher is silent. A run that dies in globalSetup never reaches onEnd and
# publishes nothing either. Nothing else notices either case, which is what
# this alarm is for.
#
# treat_missing_data is "breaching" because absence IS the failure here. The
# window holds three expected dispatches, so a single delayed GitHub Actions
# run does not raise an alarm.
resource "aws_cloudwatch_metric_alarm" "e2e_no_metrics" {
  alarm_name          = "e2e-no-metrics-${var.environment}"
  alarm_description   = "No end-to-end test metrics have arrived for 30 minutes (expected every 10 minutes). The scheduler, the GitHub Actions run, or the CloudWatch reporter is broken. Check the check-production workflow in trade-tariff-e2e-tests and the e2e scheduler dispatcher alarms."
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "TestsCompleted"
  namespace           = "TradeTariff/E2E"
  period              = local.e2e_journey_period
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "breaching"

  dimensions = {
    Environment = var.environment
  }

  alarm_actions = local.alert_actions
}
