{{/*
  Who may reach this service. Sigillum reads the seal off the instance and writes the
  network policies behind it.
*/}}
{{- define "azoth.seal" -}}
{{- $network := (fromYaml (include "azoth.values" .)).network -}}
apiVersion: seals.helmetica.io/v1
kind: Seal
metadata:
  name: networkconfig
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  {{- /* the claim namespace is always allowed */}}
  allowedNamespaces: {{- toYaml $network.allowedNamespaces | nindent 4 }}
  allowAllNamespaces: {{ $network.allowAllNamespaces }}
{{- end }}
