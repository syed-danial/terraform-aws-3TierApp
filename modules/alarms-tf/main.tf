resource "aws_cloudwatch_metric_alarm" "scale_out_alarm" {
    alarm_name = "scale_out_alarm"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    namespace = "AWS/EC2"
    metric_name = "CPUUtilization"
    period = 60
    evaluation_periods = 1
    threshold = 50
    statistic = "Minimum"
    alarm_description = "Alarm for scaling out instances"
    treat_missing_data = "notBreaching"
    dimensions = {
        AutoScalingGroupName = var.web_asg_info.web_asg_name
    }
    alarm_actions = [aws_autoscaling_policy.scaling_out_policy.arn]
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-alarm1"})
}

resource "aws_cloudwatch_metric_alarm" "scale_in_alarm" {
    alarm_name = "scale_in_alarm"
    comparison_operator = "LessThanOrEqualToThreshold"
    namespace = "AWS/EC2"
    metric_name = "CPUUtilization"
    period = 60
    evaluation_periods = 1
    threshold = 50
    statistic = "Minimum"
    alarm_description = "Alarm for scaling out instances"
    treat_missing_data = "notBreaching"
    dimensions = {
        AutoScalingGroupName = var.web_asg_info.web_asg_name
    }
    alarm_actions = [aws_autoscaling_policy.scaling_in_policy.arn]
    tags = merge("${var.tags}",{environment = "${terraform.workspace}"}, {Name = "${var.name}-alarm2"})
}

resource "aws_autoscaling_policy" "scaling_in_policy" {
    name = "scaling_in_policy"
    autoscaling_group_name = var.web_asg_info.web_asg_name
    policy_type = "StepScaling"
    step_adjustment {
        scaling_adjustment = -1
        metric_interval_upper_bound = 0
    }
    adjustment_type = "ChangeInCapacity"
}

resource "aws_autoscaling_policy" "scaling_out_policy" {
    name = "scaling_out_policy"
    autoscaling_group_name = var.web_asg_info.web_asg_name
    policy_type = "StepScaling"
    step_adjustment {
        scaling_adjustment = 1
        metric_interval_lower_bound = 0
    }
    adjustment_type = "ChangeInCapacity"
}