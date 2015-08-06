build:
	docker build -t gonz/textonapage-tools -f ./Dockerfile ..

run: build
	docker run --link=webrouter_db_1:db -it gonz/textonapage-tools:latest
