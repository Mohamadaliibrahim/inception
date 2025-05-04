all :
	docker compose -f srcs/docker-compose.yml up --build -d
clean :
	docker compose -f srcs/docker-compose.yml down -v
fclean : clean
	docker compose -f srcs/docker-compose.yml stop
	docker system prune -af

re : clean all