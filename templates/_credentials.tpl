{{/*
  The connection details this service hands out. Arcana resolves every entry of the
  mapping and writes the results into one secret in the instance namespace; the framework
  itself never reads the values.

  The mapping comes out of the reagent's values.yaml. Helm does not template that file, so
  arcana's own expressions (`{{.ClaimName}}` and friends) pass through untouched.
*/}}
{{- define "azoth.credentials" -}}
{{- $credentials := (fromYaml (include "azoth.values" .)).credentials -}}
apiVersion: arcana.helmetica.io/v1
kind: Arcanum
metadata:
  name: credentials
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  target:
    name: {{ $credentials.targetSecret | default (printf "%s-credentials" .Release.Name) | quote }}
  {{- /*
    An empty mapping renders as an empty object rather than a bare `credentials:` key,
    which is YAML null and rejected by the API. That is how a reagent declares the secret
    before it knows what goes in it.
  */}}
  {{- with $credentials.valueMapping }}
  credentials:
    valueMapping:
      {{- toYaml . | nindent 6 }}
  {{- else }}
  credentials: {}
  {{- end }}
{{- end }}
