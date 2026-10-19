{{/*
  Template for default alerting over email.
*/}}
{{- define "azoth.alerting.email" -}}
{{- $alerting := (fromYaml (include "azoth.values" .)).alerting -}}
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: email-alerting
  labels:
    {{- include "azoth.labels" . | nindent 4 }}
spec:
  receivers:
  - name: "null"
  - name: service_operator
    {{- if empty ($alerting.serviceOperator).emailAddresses | not }}
    emailConfigs:
    {{- range $alerting.serviceOperator.emailAddresses }}
    - to: {{ . | quote }}
    {{- end }}
    {{- end }}
  - name: service_user
    {{- if empty ($alerting.serviceUser).emailAddresses | not }}
    emailConfigs:
    {{- range $alerting.serviceUser.emailAddresses }}
    - to: {{ . | quote }}
    {{- end }}
    {{- end }}
  - name: service_maintainer
    {{- if empty ($alerting.serviceMaintainer).emailAddresses | not }}
    emailConfigs:
    {{- range $alerting.serviceMaintainer.emailAddresses }}
    - to: {{ . | quote }}
    {{- end }}
    {{- end }}
  route:
    groupBy:
    - alertname
    - audience
    groupInterval: 5s
    groupWait: 0s
    receiver: "null"
    repeatInterval: 4h
    routes:
    - matchers:
      - matchType: "="
        name: audience
        value: service_operator
      receiver: service_operator
    - matchers:
      - matchType: "="
        name: audience
        value: service_user
      receiver: service_user
    - matchers:
      - matchType: "="
        name: audience
        value: service_maintainer
      receiver: service_maintainer
{{- end }}
