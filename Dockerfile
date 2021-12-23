FROM node:latest

# Install docker bin & prepare volume for docker sock mount (Docker-out-of-docker)
RUN apt-get update -q && apt-get install -yq ca-certificates curl gnupg lsb-release nano
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -yq docker-ce docker-ce-cli containerd.io

# install package locally from packages.json as root
COPY ./package.json .
COPY ./package-lock.json .
RUN npm ci
# move locally installed package to global scope as root
RUN npm install --global

# Setup ssh key & config for remote ssh
RUN mkdir /home/node/.ssh /home/node/.secure
VOLUME /home/node/.ssh/known_hosts
COPY ssh_config /home/node/.ssh/config
RUN chmod 644 /home/node/.ssh/config
VOLUME /home/node/.secure/rsa

WORKDIR /home/node/app
VOLUME /home/node/app

# volumes for the ssh private key & known hosts
CMD npx semantic-release
