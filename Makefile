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

clear:
	@echo -e "This will completely wipe all uploads and the DB.\n<CTRL-C> to cancel <Enter> to continue" \
		&& read confirm\
		&& docker exec infolis-mongo mongo infolis-web --eval "db.dropDatabase()" \
		&& rm -rvf data/uploads/*

