{{/*
  Who may reach this service. Sigillum reads the network config off the instance and writes the
  network policies behind it.
*/}}
{{- define "azoth.networkconfig" -}}
{{- $network := (fromYaml (include "azoth.values" .)).network -}}
apiVersion: sigillum.helmetica.io/v1
kind: NetworkConfig
metadata:
  name: networkconfig
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  {{- /* the claim namespace is always allowed */}}
  allowedNamespaces: {{- toYaml $network.allowedNamespaces | nindent 4 }}
  allowAllNamespaces: {{ $network.allowAllNamespaces }}
  {{- /* the claim turns exposure on, the reagent says what gets exposed */}}
  {{- if and $network.expose $network.exposures }}
  expose: {{- toYaml $network.exposures | nindent 4 }}
  {{- end }}
{{- end }}
