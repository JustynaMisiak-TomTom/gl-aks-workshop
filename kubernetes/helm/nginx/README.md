# Helm Examples

This directory contains example charts to help you get started with Helm Chart development.

## Alpine

The `alpine` chart is very simple, and is a good starting point.

It simply deploys a single pod running Alpine Linux.

## Nginx

The `nginx` chart shows how to compose several resources into one chart,
and it illustrates more complex template usage.

It deploys a `deployment` (which creates a `replica set`), a `config
map`, and a `service`. The replica set starts an nginx pod. The config
map stores the files that the nginx server can serve.


# nginx: An advanced example chart

 Helm chart provides examples of some of Helm's more powerful
features.

**This is not a production-grade chart. It is an example.**

The chart installs a simple nginx server according to the following
pattern:

- A `ConfigMap` is used to store the files the server will serve.
  ([templates/configmap.yaml](templates/configmap.yaml))
- A `Deployment` is used to create a Replica Set of nginx pods.
  ([templates/deployment.yaml](templates/deployment.yaml))
- A `Service` is used to create a gateway to the pods running in the
  replica set ([templates/svc.yaml](templates/svc.yaml))

The [values.yaml](values.yaml) exposes a few of the configuration options in the
charts, though there are some that are not exposed there (like
`.image`).

The [templates/_helpers.tpl](templates/_helpers.tpl) file contains helper templates. The leading
underscore (`_`) on the filename is semantic. It tells the template renderer
that this file does not contain a manifest. That file declares some
templates that are used elsewhere in the chart.

Helpers (usually called "partials" in template languages) are an
advanced way for developers to structure their templates for optimal
reuse.

You can deploy this chart with `helm install docs/examples/nginx`. Or
you can see how this chart would render with `helm install --dry-run
--debug docs/examples/nginx`.