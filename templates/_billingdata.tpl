{{/*
  Reports billing relevant data to an S3 bucket.
*/}}
{{- define "azoth.billingdata" -}}
{{- $billing := (fromYaml (include "azoth.values" .)).billing -}}
{{- $metadata := deepCopy ($billing.metadata | default dict) -}}
{{- /* Injected by chrysopoeia as a platform value. */ -}}
{{- with dig "io.vshn.cluster/v1alpha1" "name" "" (index .Values "__platform__" | default dict) }}
{{- $_ := set $metadata "cluster" . -}}
{{- end }}
apiVersion: libra.helmetica.io/v1
kind: BillingData
metadata:
  name: billing
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  {{- if $billing.items }}
  items:
    {{- range $name, $value := $billing.items }}
    - name: {{ $name }}
      value: {{ $value | quote }}
    {{- end }}
  {{- end }}
  {{- if $metadata }}
  metadata: {{- toYaml $metadata | nindent 4 }}
  {{- end }}
{{- end }}
