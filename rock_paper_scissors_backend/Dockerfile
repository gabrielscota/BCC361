# Use uma imagem base Node.js
FROM node:20.5

# Diretório de trabalho no contêiner
WORKDIR /app

# Copie o package.json e package-lock.json para o diretório de trabalho
COPY package*.json tsconfig.json ./

# Instale as dependências
RUN npm install

# Copie todos os arquivos do diretório local para o diretório de trabalho no contêiner
COPY . .

# Compile o código TypeScript
RUN npm run build

# Exponha a porta 3000 (a mesma porta usada no backend)
EXPOSE 3000

# Comando para iniciar o servidor Node.js
CMD ["node", "dist/server.js"]
