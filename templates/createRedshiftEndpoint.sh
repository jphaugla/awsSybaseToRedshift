aws dms create-endpoint \
           --endpoint-identifier targetRedshiftEndpoint \
           --endpoint-type target \
           --engine-name redshift \
           --redshift-settings file://redshift-settings.json
