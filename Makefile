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

backup:
	$(MKDIR) backup
	now="$(BACKUP_NAME)" \
		&& $(MKDIR) backup/$$now/mongodb \
		&& docker exec infolis-mongo mongodump --out /backup/$$now/mongodb \
		&& cp -r data/uploads ./backup/$$now/uploads

backup-to-server: backup
	@if [ -z "$(BACKUP_SERVER)" ];then echo "Usage: make backup-to-server BACKUP_SERVER=user@server:/path"; exit 1;fi
	rsync -Prz --progress backup/$(BACKUP_NAME) $(BACKUP_SERVER)

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

restore:
	@if [ -z "$$BACKUP" ];then echo "Usage: make restore BACKUP=<backup-timestamp>"; exit 1;fi
	@if [ ! -e "./backup/$$BACKUP" ];then echo "No such folder ./backup/$$BACKUP"; exit 2;fi
	docker exec infolis-mongo mongorestore --noIndexRestore ./backup/$$BACKUP/mongodb
	cp -v ./backup/$$BACKUP/uploads/* data/uploads

clear:
	@echo "This will completely wipe all uploads and the DB.\n<CTRL-C> to cancel <Enter> to continue" \
		&& read confirm\
		&& docker exec infolis-mongo mongo infolis-web --eval "db.dropDatabase()" \
		&& rm -rvf data/uploads/*

