{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{define "name"}}{{default "nginx" .Values.nameOverride | trunc 24 }}{{end}}

{{/*
Create a default fully qualified app name.

We truncate at 24 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{define "fullname"}}
{{- $name := default "nginx" .Values.nameOverride | trunc 24 -}}
{{end}}

{{define "namespace"}}
{{- $name := default "nginx" .Values.nameOverride | trunc 24 -}}
{{end}}
