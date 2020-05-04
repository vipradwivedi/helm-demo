NodeJS TinyURL Service
---

### About app

1. Used Node.js, Express.js, and MongoDB.
1. Takes input url and converts into tinyurl.
1. Check [screenshots](public/images) in `public/images` directory.
1. Uses mongo db for persistence.
1. Setup `config/config.js` for DB connection params.
1. Use `npm install` to install nodejs dependencies.
1. `npm start` to start local dev server and hit http://localhost:3000  

### What we want to do

1. An attempt to dockerise a simple node js app which connects to mongo db.
1. Setup deployment configurations using helm charts for kubernetes environment.
1. Use all best practices possible to create build, release and deploy pipeline.
1. Persistence layer deployment(mongo) is NOT in the scope of this work.

### Things to be considered

1. Security
    1. Docker Image Security.
        1. non root user setup.
        1. minimum user permission for process execution.
        1. proper permissions for files/directories inside docker.
    1. Kubernetes security
        1. dedicated namespace for app
        1. use service account and rbac.
        1. setup network policies.
        1. setup security context for pods and containers.
        1. Define resource quotas for containers.
        1. secret handling
        
1. Scalability
    1. setup service object to access deployment.
    1. setup nginx-ingress to access above service.
    1. define hpa, min and max pod limits
    1. configure liveness and readiness probes

1. Others
    1. proper naming convention for objects.
    1. documentation and appropriate comments.

1. Future
    1. static test cases and security analysis of app/docker image.
    1. sidecar for logging
    1. sidecar for application metrics 
