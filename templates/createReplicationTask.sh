aws dms create-replication-task --replication-task-identifier 'sybase-to-redshift' --source-endpoint-arn arn:aws:dms:us-east-1:xxxxxxxxxxx:endpoint:PZM2EY5UO57GCESAVBNVXD7ZIGU2HEBRPTCM5LI --target-endpoint-arn arn:aws:dms:us-east-1:xxxxxxxxxxx:endpoint:IDIQGNP357LXKK3DSGJ3MN5X33YBEBRHJSDNRTQ --replication-instance-arn arn:aws:dms:us-east-1:xxxxxxxxxxx:rep:3LY3AT64BQTKMF7NS43MAHNZ5FBT5UZGJ5U5CFQ --migration-type full-load-and-cdc --table-mappings file://table-mapping.json --replication-task-settings file://replication-task-settings.json
