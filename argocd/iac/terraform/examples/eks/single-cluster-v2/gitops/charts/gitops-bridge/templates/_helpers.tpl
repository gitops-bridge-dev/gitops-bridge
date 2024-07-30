{{/*
Expand the name of the chart.
*/}}
{{- define "gitops-bridge.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "gitops-bridge.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "gitops-bridge.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common Helm and Kubernetes labels
*/}}
{{- define "gitops-bridge.labels" -}}
helm.sh/chart: {{ include "gitops-bridge.chart" . }}
app.kubernetes.io/name: {{ include "gitops-bridge.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.labels }}
{{ toYaml .Values.labels }}
{{- end }}
{{- end }}

{{/*
Common Helm and Kubernetes Annotations
*/}}
{{- define "gitops-bridge.annotations" -}}
helm.sh/chart: {{ include "gitops-bridge.chart" . }}
{{- if .Values.annotations }}
{{ toYaml .Values.annotations }}
{{- end }}
{{- end }}


{{- define "toValidName" -}}
{{- printf "%s" . | regexReplaceAll "[^a-z0-9.-]" "-" | lower -}}
{{- end -}}