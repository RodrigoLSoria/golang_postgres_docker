postgres:
	docker run --name postgres12   -e POSTGRES_USER=admin   -e POSTGRES_PASSWORD=mypassword   -e POSTGRES_DB=mydb   -p 1234:5432   -d postgres:12-alpine

createdb:
	docker exec -it postgres12 createdb --username=admin --owner=admin simple_bank

dropdb:
	docker exec -it postgres12 psql -U admin -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='mydb';"
	docker exec -it postgres12 dropdb --username=admin simple_bank

migrateup:
	migrate -path db/migration -database "postgresql://admin:mypassword@localhost:1234/simple_bank?sslmode=disable" -verbose up

migrateup1:
	migrate -path db/migration -database "postgresql://admin:mypassword@localhost:1234/simple_bank?sslmode=disable" -verbose up 1

migratedown:
	migrate -path db/migration -database "postgresql://admin:mypassword@localhost:1234/simple_bank?sslmode=disable" -verbose down

migratedown1:
	migrate -path db/migration -database "postgresql://admin:mypassword@localhost:1234/simple_bank?sslmode=disable" -verbose down 1

sqlc:
	sqlc generate

reset:
	docker stop postgres12 || true
	docker rm postgres12 || true
	make postgres
	sleep 3
	make createdb
	make migrateup

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/rodrigoLSoria/simplebank/db/sqlc Store


.PHONY: postgres createdb dropdb migrateup migrateup1 migratedown migratedown1 sqlc reset test server mock
	