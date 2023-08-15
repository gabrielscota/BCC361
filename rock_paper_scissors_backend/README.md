# BCC361 - TP - Rock, Paper, Scissors

## Integrantes
- [Gabriel Scotá](https://github.com/gabrielscota)
  
## Docker Commands
- Build: `docker build -t bcc361-tp-rock-paper-scissors .`
- Run: `docker run -it -p 3000:3000 -d bcc361-tp-rock-paper-scissors`

## Deploy to GCP
```bash
gcloud auth login
```
```bash
gcloud auth configure-docker southamerica-east1-docker.pkg.dev
```
### Apagar todos volumes e imagens
```bash
docker system prune -a --volumes
```
### Ver logs do container
```bash
docker logs -f CONTAINER_ID
```