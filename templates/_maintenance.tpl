{{/*
  When this service's maintenance runs. The adept reads this off the instance.
*/}}
{{- define "azoth.maintenance" -}}
{{- $maintenance := (fromYaml (include "azoth.values" .)).maintenance -}}
apiVersion: rituals.helmetica.io/v1
kind: Maintenance
metadata:
  name: default
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  window: {{ $maintenance.window | quote }}
  suspend: {{ $maintenance.suspend }}
{{- end }}
