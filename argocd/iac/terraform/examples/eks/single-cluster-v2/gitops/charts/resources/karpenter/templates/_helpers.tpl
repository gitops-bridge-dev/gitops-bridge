{{/*Define headroom sizes*/}}
{{- define "headroom.sizing" -}}
{{- range $key, $val := .Args }}
{{- if eq $val "small" }}
cpu: "1"
memory: "4Gi"
{{- end }}
{{- if eq $val "medium" }}
cpu: "2"
memory: "8Gi"
{{- end }}
{{- if eq $val "large" }}
cpu: "4"
memory: "16Gi"
{{- end }}
{{- if eq $val "xlarge" }}
cpu: "8"
memory: "32Gi"
{{- end }}
{{- end }}
{{- end }}
