data "databricks_node_type" "this" {
  category              = lookup(nodemapping[var.service_category],"category",null)
  local_disk            = lookup(nodemapping[var.service_category],"local_disk",null)
  min_cores             = lookup(nodemapping[var.service_category],"min_cores",null)
  min_memory_gb         = lookup(nodemapping[var.service_category],"min_memory_gb",null)
  gb_per_core           = lookup(nodemapping[var.service_category],"gb_per_core",null)
  min_gpus              = lookup(nodemapping[var.service_category],"min_gpus",null)
  local_disk_min_size   = lookup(nodemapping[var.service_category],"local_disk_min_size",null)
}

data "databricks_spark_version" "this" {
  gpu = lookup(nodemapping[var.service_category],"min_gpus",null) > 0 ? true : false
  ml  = strcontains(lower(var.service_category), "ml") # returns true or false depending on whether the service key contain ml
}

module "databricks_cluster" {
  source                  = "git::https://github.com/parts-unlimited/terraform-aws-databricks-cluster?ref=v3.7"
  cluster_name            = "dbcluster-${var.env}-${var.name}"
  spark_version           = data.databricks_spark_version.this.id
  node_type_id            = data.databricks_node_type.this.id
  autotermination_minutes = lookup(nodemapping[var.service_category],"autotermination_minutes",null)
  autoscale {
    min_workers = var.service_category == "default" || lookup(nodemapping[var.service_category],"idle",false) ? 0 : 1
    max_workers = lookup(nodemapping[var.service_category],"max_workers",1)
  }
}

resource "aws_sns_topic_subscription" "sns-topic" {
  topic_arn = data.alert_notifcation.arn
  protocol  = "email"
  endpoint  = var.supportescalation
}