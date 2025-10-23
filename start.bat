@echo off
echo === Uruchamianie backendu w Docker Compose ===
docker compose up -d --build

echo === Oczekiwanie na backend ===
timeout /t 5

echo === Uruchamianie Flutter ===
cd the_basics
flutter run
