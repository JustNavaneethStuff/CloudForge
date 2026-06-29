# RDS Module

Creates a PostgreSQL 16 RDS instance with encryption, backups, and Performance Insights.

## Key Inputs

- `instance_class`, `multi_az`, `backup_retention_period`
- `subnet_ids`, `security_group_ids`

## Key Outputs

- `db_endpoint`, `db_port`, `db_instance_id`
