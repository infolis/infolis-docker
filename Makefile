MKDIR = mkdir -p
BACKUP_NAME := $(shell date +"%Y-%m-%d_%H-%M-%S")

.PHONY: backup dirs

dirs:
	mkdir -p \
		./data/logs/ \
		./data/mongodb/ \
		./data/uploads/ \
		./backup/

build: dirs
	$(MKDIR) data/logs data/mongodb data/uploads
	docker-compose pull mongo
	docker-compose build infolis-web
	docker-compose build infolink

#
# Create backups
#

backup: backup-files backup-mongodb

backup-files:
	$(MKDIR) backup/$($BACKUP_NAME)/mongodb
	cp -r data/uploads ./backup/$$now/uploads

backup-mongodb:
	$(MKDIR) backup/$(BACKUP_NAME)/mongodb
	docker exec infolis-mongo mongodump --out /backup/$(BACKUP_NAME)/mongodb \

#
# Restore backups
#

restore: restore-files restore-mongodb

restore-files:
	@if [ -z "$$BACKUP" ];then echo "Usage: make $@ BACKUP=<backup-timestamp>"; exit 1;fi
	@if [ ! -e "./backup/$$BACKUP" ];then echo "No such folder ./backup/$$BACKUP"; exit 2;fi
	@if [ -e ./backup/$$BACKUP/uploads/* ];then cp -v ./backup/$$BACKUP/uploads/* data/uploads; fi

restore-mongodb:
	@if [ -z "$$BACKUP" ];then echo "Usage: make $@ BACKUP=<backup-timestamp>"; exit 1;fi
	@if [ ! -e "./backup/$$BACKUP" ];then echo "No such folder ./backup/$$BACKUP"; exit 2;fi
	docker exec infolis-mongo mongorestore --noIndexRestore ./backup/$$BACKUP/mongodb

#
# Backup to server
# - This only backs up the DB!
#
backup-to-server: backup-mongodb
	@if [ -z "$(BACKUP_SERVER)" ];then echo "Usage: make backup-to-server BACKUP_SERVER=user@server:/path"; exit 1;fi
	rsync -Prz --progress backup/$(BACKUP_NAME) $(BACKUP_SERVER)
	rm -rf $(BACKUP_NAME)

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

clear-db:
	@echo "This will completely wipe the DB.\n<CTRL-C> to cancel <Enter> to continue" \
		&& read confirm\
		&& docker exec infolis-mongo mongo infolis-web --eval "db.dropDatabase()"

clear-uploads:
	@echo "This will completely wipe all uploads.\n<CTRL-C> to cancel <Enter> to continue" \
		rm -rvf data/uploads/*
