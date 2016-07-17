MKDIR = mkdir -p

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
	now=`date +"%Y-%m-%d_%H-%M-%S"` \
		&& $(MKDIR) backup/$$now/mongodb \
		&& docker exec infolis-mongo mongodump --out /backup/$$now/mongodb \
		&& cp -r data/uploads ./backup/$$now/uploads

restore:
	@if [ -z "$$BACKUP" ];then echo "Usage: make restore BACKUP=<backup-timestamp>"; exit 1;fi
	@if [ ! -e "./backup/$$BACKUP" ];then echo "No such folder ./backup/$$BACKUP"; exit 2;fi
	docker exec infolis-mongo mongorestore ./backup/$$BACKUP/mongodb
	cp -v ./backup/$$BACKUP/uploads/* data/uploads

clear:
	@echo -e "This will completely wipe all uploads and the DB.\n<CTRL-C> to cancel <Enter> to continue" \
		&& read confirm\
		&& docker exec infolis-mongo mongo infolis-web --eval "db.dropDatabase()" \
		&& rm -rvf data/uploads/*

