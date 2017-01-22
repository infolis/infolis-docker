MKDIR = mkdir -p
COPY_TO    = cp -vt

DATA_PATH       = data
BACKUP         := $(shell date +"%Y-%m-%d_%H-%M-%S")
BACKUP_PATH     = backup/$(BACKUP)
MONGODB_DATA    = $(DATA_PATH)/mongodb
UPLOADS_DATA    = $(DATA_PATH)/uploads
MONGODB_BACKUP  = $(BACKUP_PATH)/mongodb
UPLOADS_BACKUP  = $(BACKUP_PATH)/uploads

help:
	@echo "See README.md#utilities"

.PHONY: backup dirs

dirs:
	mkdir -p \
		$(DATA_PATH)/logs/ \
		$(DATA_PATH)/mongodb/ \
		$(DATA_PATH)/uploads/ \
		$(dir BACKUP_PATH)

build: dirs
	docker-compose pull mongo
	docker-compose build infolis-web
	docker-compose build infolink

#
# Create backups
#

backup: backup-files backup-mongodb

backup-files:
	$(MKDIR) $(UPLOADS_BACKUP)
	find $(UPLOADS_DATA) -type f -exec $(COPY_TO) "$(UPLOADS_BACKUP)" {} \;

backup-mongodb:
	$(MKDIR) $(MONGODB_BACKUP)
	docker exec infolis-mongo mongodump --out $(MONGODB_BACKUP)

#
# Restore backups
#

restore: restore-files restore-mongodb

restore-files:
	@if [ ! -e "$(UPLOADS_BACKUP)" ];then echo "No such folder $(UPLOADS_BACKUP)\nUsage: make $@ BACKUP=<backup-timestamp>" ; exit 2 ;fi
	find "$(UPLOADS_BACKUP)" -type f -exec $(COPY_TO) "$(UPLOADS_DATA)" {} \;

restore-mongodb: dropIndexes
	@if [ ! -e "$(MONGODB_BACKUP)" ];then echo "No such folder $(MONGODB_BACKUP)\nUsage: make $@ BACKUP=<backup-timestamp>" ; exit 2 ;fi
	docker exec infolis-mongo mongorestore --noIndexRestore $(MONGODB_BACKUP)

#
# Delete database or remove uploads
#

clear: clear-mongodb clear-files

clear-mongodb:
	@echo "This will completely wipe the DB.\n<CTRL-C> to cancel <Enter> to continue" \
		&& read confirm\
		&& docker exec infolis-mongo mongo infolis-web --eval "db.dropDatabase()"

clear-files:
	@echo "This will completely wipe all files.\n<CTRL-C> to cancel <Enter> to continue" \
		&& read confirm\
		&& find "$(UPLOADS_DATA)" -type f -exec rm -f {} \;

#
# XXX Disabled for now, cronjob not active anyway
# Backup to server
# - This only backs up the DB!
#
# backup-to-server: backup-mongodb
#     @if [ -z "$(BACKUP_SERVER)" ];then echo "Usage: make backup-to-server BACKUP_SERVER=user@server:/path"; exit 1;fi
#     rsync -Prz --progress backup/$(BACKUP) $(BACKUP_SERVER)
#     # rm -rf "$(BACKUP)"

dropIndexes:
	docker exec infolis-mongo mongo infolis-web --eval \
	"db.getCollectionNames().forEach(function(col) { \
		db.runCommand({'dropIndexes': col, 'index': '*'}); \
	});"

listIndexes:
	docker exec infolis-mongo mongo infolis-web --eval \
	"db.getCollectionNames().forEach(function(collection) { \
		indexes = db[collection].getIndexes(); \
		print('Indexes for ' + collection + ':'); \
		printjson(indexes); \
	});"
