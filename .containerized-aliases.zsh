alias npx='docker run --rm --tty --interactive --volume $PWD:/host --volume npm_cache:/home/node --workdir /host --user node --name npx node:alpine npx'
alias npm='docker run --rm --tty --interactive --volume $PWD:/host --volume npm_cache:/home/node --workdir /host --user node --name npx node:alpine npm'

alias terraform='docker run --rm --tty --interactive --volume $PWD:/host --workdir /host --name terraform terraform terraform'
