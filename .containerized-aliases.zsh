alias npx='docker run --rm --tty --interactive --volume $PWD:/host --volume npm_cache:/home/node --workdir /host --user node --name npx node:alpine npx'
alias npm='docker run --rm --tty --interactive --volume $PWD:/host --volume npm_cache:/home/node --workdir /host --user node --publish 3000:3000 --name npx node:alpine npm'
# alias artillery='docker run --rm --tty --interactive --volume $PWD:/host --workdir /host --name artillery artilleryio/artillery:v1.7.9'

alias terraform='docker run --rm --tty --interactive --volume $PWD:/host --workdir /host --name terraform terraform terraform'

alias psql='docker run --rm --tty --interactive --network host --name postgres postgres:alpine psql'
