# Node Sandboxed SH

Supply chain attacks are on the rise, and this makes the Node ecosystem a scary place, as any package you install (Or installs as a dependency of those packages) could run malicious code upon installation using `post_install` or could contain malicious code that would infect you maching upon running your application.
Some of thos risks can be mitigate by running `node`/`yarn`/`npm` commands inside a sandboxed container. 
It mounts the current directory as the working directory of the container, so this is the only thing files from the host this can access
Optinally the hosts `.npmrc` and `.yarnrc` can be exposed as read-only to the sandbox, to allow for authenticated commands

## Usage

````
- RC=1 ns.sh yarn install
- ENV=\"NODE_ENV\" ns.sh npm run build
- PORTS=\"80,445\" ns.sh node ./src/server.js
- IMAGE=node NETWORK=host ns.sh npm start
- ns.sh /bin/sh # Gives you and interactive shell for running multible commands inside the same container
```

**Note**: This only mount your current directory inside the sandbox, so if your application writes to places outside of that that data would not be preserved between commands

**Supported environment variables**:

* **RC**: Set to "1" to expose the hosts `.npmrc` and `.yarnrc` to the sandbox
* **PORTS**: comma seperated list of ports to expose to the host (For simplicities sake, only one-to-one port mapping is supported)
* **NETWORK**: docker network mode: `host`, `none`, `bridge` (default)
* **ENV**: comma sperated list of environment variables from the host that should be available to the sandbox
* **IMAGE**: use a different base image for the commands (default is `node:alpine`)

## Is the node ecosustem now safe?

Well NO, this does offer a degree of protection from malicious packages doing bad behaviour on the machine running the commands, but if the package attacks the network, encrypts your database or cross site injects your users, steal your NPM tokens etc. this will not help in the least, so using this does not remove the need to do security vetting, it just limits one attack vector
