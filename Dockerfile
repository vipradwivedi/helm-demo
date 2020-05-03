FROM tinyurl_base:latest

COPY . .

EXPOSE 3000

CMD [ "npm", "start" ]
