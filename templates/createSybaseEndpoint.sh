aws dms create-endpoint \
           --endpoint-identifier sourceSybaseEndpoint \
           --endpoint-type source \
           --engine-name sybase \
           --sybase-settings file://sybase-settings.json
