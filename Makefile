# Edit login before launching !
LOGIN =		pcervill
DOMAIN =	${LOGIN}.42.fr
DATA_PATH = /Home/${LOGIN}/data
ENV =		LOGIN=${LOGIN} DATA_PATH=${DATA_PATH} DOMAIN=${LOGIN}.42.fr 

all: up

up: setup
	${ENV} docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	${ENV} docker compose -f ./srcs/docker-compose.yml down

start:
	${ENV} docker compose -f ./srcs/docker-compose.yml start

stop:
	${ENV} docker compose -f ./srcs/docker-compose.yml stop

status:
	cd srcs && docker compose ps && cd ..

logs:
	cd srcs && docker compose logs && cd ..

setup:
	sudo mkdir -p ${DATA_PATH}
	sudo mkdir -p ${DATA_PATH}/mariadb-data
	sudo mkdir -p ${DATA_PATH}/wordpress-data

clean:
	@echo "[*] Limpiando datos de volúmenes..."
	sudo rm -rf ${DATA_PATH}
	@echo "[✓] Datos removidos"

fclean: down clean
	@echo "[*] Limpieza profunda en progreso..."
	@echo "[*] Removiendo volúmenes Docker..."
	docker volume rm srcs_mariadb-data srcs_wordpress-data 2>/dev/null || true
	@echo "[*] Prunning del sistema Docker..."
	docker system prune -f -a --volumes
	@echo "[✓] Limpieza completa finalizada"

.PHONY: all up down start stop status logs prune clean fclean
