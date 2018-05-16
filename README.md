
# Cloud Foundry Blue Green Deploy Resource

An output only resource that will deploy an application to Cloud Foundry using blue-green pattern.

This resource focuses a robust deployement of the application. The current crop of zero-downtime cf CLI plugins fails when applications are bound to CF services such as Service Registry (Eureka) and Identity Service (UAA).

## Source Configuration

- `api` : *Required*. The adress of Cloud Foundry Cloud Controller.
- `username` : *Required*. The username used to authenticate.
- `password` : *Required*. The password used to authenticate.
- `organization` : *Required*. The organization to push the application to.
- `space` : *Required*. The space to push the application to.
- `skip_cert_check` : *Optional*. Check the validity of the CF SSL cert. Defaults to false.

## out. Deploy application to Cloud Foundry

The application is pushed to Cloud Foundry using the blue-green deployment pattern.

The application is always pushed with the app name suffixed by either `-blue`or `-green`. The *active* application always have the `name` route. The process first determine which of blue or green is currently active and then deploy the new application using the other suffix. The application is deployed once using the suffixed route and the health check script is run. The script receives the `APP` (application name), HOSTNAME (application base hostname), `NEXT` (blue or green) and `DOMAIN` (application domain) as environment variables. The hostname for healthchecking the new application is `${HOSTNAME}-${NEXT}.${DOMAIN}`. If the script exit with an error level, it the new application will be stopped and left in that state. If the script exit with 0. The new application will be deleted and pushed again with the *normal* route. At this time, both the new and current appications will receive requests. The current application route is unmapped and the it is stopped.

### Parameters

- `name` : *Required*. The name of the application. This is also used for the always available route to the app.
- `manifest` : *Required*. The application manifest.
- `path` : *Required*. Path to the application to deploy.
- `domain` : The domain which should be used for the apps. By default the first domain is used.

## Example

```
resource_types: 

- name: cf-blue-green-resource
  type: docker-image
  source:
    repository: emeraldsquad/cf-blue-green-resource

resources:
- name: pcf
  type: cf-blue-green-resource
  source:
    api: {{pcf-api}}
    username: {{pcf-user}}
    password: ((pcf-passwd))
    organization: {{pcf-org}}
    space: {{pcf-space}}

jobs:
  - name: blue-green-deploy
    serial: true
    public: false
    plan:
    - get: myapp
    - put: pcf
      params:
        name: myapp
        manifest: myapp/ci/manifest.yml
        path: myapp/annuaire-service-*.jar
        hostname: myapp
```
