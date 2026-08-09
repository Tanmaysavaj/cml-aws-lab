resource "aws_budgets_budget" "monthly" {
  name         = "${var.project_name}-monthly-budget"
  budget_type  = "COST"
  limit_amount = var.monthly_budget_usd
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  # Alert when actual spending reaches 50% of budget.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                   = 50
    threshold_type              = "PERCENTAGE"
    notification_type           = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]
  }

  # Alert when actual spending reaches 80% of budget.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                   = 80
    threshold_type              = "PERCENTAGE"
    notification_type           = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]
  }

  # Alert when AWS forecasts that spending will exceed 100%.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                   = 100
    threshold_type              = "PERCENTAGE"
    notification_type           = "FORECASTED"
    subscriber_email_addresses = [var.budget_email]
  }

  # Alert when actual spending exceeds the budget.
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                   = 100
    threshold_type              = "PERCENTAGE"
    notification_type           = "ACTUAL"
    subscriber_email_addresses = [var.budget_email]
  }
}